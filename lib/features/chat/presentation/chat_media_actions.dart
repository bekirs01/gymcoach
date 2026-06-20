import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/chat_attachment.dart';
import '../domain/chat_message.dart';

Future<void> saveChatMediaLocally({
  required ChatMessage message,
  required String fallbackFileName,
}) async {
  final attachment = message.attachments.isNotEmpty ? message.attachments.first : null;
  final bytes = message.localPreviewBytes;
  final localPath = message.localVoicePath;

  Uint8List? payload = bytes;
  var fileName = fallbackFileName;

  if (payload == null && localPath != null && localPath.isNotEmpty) {
    final file = File(localPath);
    if (await file.exists()) {
      payload = await file.readAsBytes();
      fileName = localPath.split('/').last;
    }
  }

  if (payload == null && attachment != null) {
    final url = attachment.signedUrl ?? message.mediaUrl;
    if (url != null && url.isNotEmpty) {
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse(url));
        final response = await request.close();
        if (response.statusCode == 200) {
          payload = Uint8List.fromList(await consolidateHttpClientResponseBytes(response));
          fileName = attachment.originalFileName ?? fallbackFileName;
        }
      } finally {
        client.close();
      }
    }
  }

  if (payload == null) return;

  final directory = await getApplicationDocumentsDirectory();
  final folder = Directory('${directory.path}/GymCoach/chat');
  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }
  final target = File('${folder.path}/$fileName');
  await target.writeAsBytes(payload, flush: true);
}

Future<void> shareChatMessage({
  required ChatMessage message,
}) async {
  if (message.hasCopyableText) {
    await Clipboard.setData(ClipboardData(text: message.body.trim()));
    return;
  }

  final attachment = message.attachments.isNotEmpty ? message.attachments.first : null;
  final url = attachment?.signedUrl ?? message.mediaUrl ?? message.primaryImageUrl;
  if (url != null && url.isNotEmpty) {
    await Clipboard.setData(ClipboardData(text: url));
  }
}

String attachmentFileName(ChatMessage message, ChatAttachment? attachment) {
  if (attachment?.originalFileName?.isNotEmpty == true) {
    return attachment!.originalFileName!;
  }
  if (message.isVoice) return 'voice.m4a';
  return 'photo.jpg';
}
