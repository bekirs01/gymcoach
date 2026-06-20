import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

final class OutboxMediaStore {
  OutboxMediaStore._();

  static OutboxMediaStore? _instance;
  static OutboxMediaStore get instance => _instance ??= OutboxMediaStore._();

  static const _folderName = 'gymcoach_outbox_media';
  static const _uuid = Uuid();

  Directory? _directory;

  Future<Directory> directory() async {
    if (_directory != null) return _directory!;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/$_folderName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _directory = dir;
    return dir;
  }

  Future<String> copyFromPath({
    required String sourcePath,
    required String extension,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('Source media file does not exist');
    }
    final dir = await directory();
    final fileName = '${_uuid.v4()}.$extension';
    final target = File('${dir.path}/$fileName');
    await source.copy(target.path);
    return target.path;
  }

  Future<String> saveBytes({
    required Uint8List bytes,
    required String extension,
  }) async {
    final dir = await directory();
    final fileName = '${_uuid.v4()}.$extension';
    final target = File('${dir.path}/$fileName');
    await target.writeAsBytes(bytes, flush: true);
    return target.path;
  }

  Future<void> deleteIfExists(String? path) async {
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String extensionFromName(String name, {String fallback = 'bin'}) {
    final parts = name.split('.');
    if (parts.length < 2) return fallback;
    final ext = parts.last.toLowerCase();
    if (ext.isEmpty || ext.length > 6) return fallback;
    return ext;
  }
}
