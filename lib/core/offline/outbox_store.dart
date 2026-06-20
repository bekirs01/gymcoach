import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'outbox_item.dart';

final class OutboxStore {
  OutboxStore._();

  static OutboxStore? _instance;
  static OutboxStore get instance => _instance ??= OutboxStore._();

  static const _fileName = 'queue.json';
  static const _folderName = 'gymcoach_outbox';

  List<OutboxItem> _items = [];
  var _loaded = false;
  File? _file;

  Future<File> _ensureFile() async {
    if (_file != null) return _file!;
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/$_folderName');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    _file = File('${folder.path}/$_fileName');
    return _file!;
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final file = await _ensureFile();
    if (!await file.exists()) {
      _items = [];
      _loaded = true;
      return;
    }
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        _items = [];
      } else {
        final list = jsonDecode(raw) as List<dynamic>;
        _items = list
            .map((e) => OutboxItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .map(
              (item) => item.status == OutboxItemStatus.syncing
                  ? item.copyWith(status: OutboxItemStatus.pending)
                  : item,
            )
            .toList();
      }
    } catch (_) {
      _items = [];
    }
    _loaded = true;
  }

  List<OutboxItem> get items => List.unmodifiable(_items);

  List<OutboxItem> pendingItems() {
    return _items
        .where(
          (item) =>
              item.status == OutboxItemStatus.pending ||
              item.status == OutboxItemStatus.failed,
        )
        .where((item) => !item.nextRetryAt.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  OutboxItem? findByLocalId(String localId) {
    for (final item in _items) {
      if (item.localId == localId) return item;
    }
    return null;
  }

  OutboxItem? findByClientTempId(String clientTempId) {
    for (final item in _items) {
      final payloadId = item.payload['client_temp_id'] as String?;
      if (payloadId == clientTempId) return item;
    }
    return null;
  }

  Future<OutboxItem> enqueue(OutboxItem item) async {
    await ensureLoaded();
    _items.removeWhere((existing) => existing.localId == item.localId);
    _items.add(item);
    await _persist();
    return item;
  }

  Future<void> upsert(OutboxItem item) async {
    await ensureLoaded();
    final index = _items.indexWhere((existing) => existing.localId == item.localId);
    if (index >= 0) {
      _items[index] = item;
    } else {
      _items.add(item);
    }
    await _persist();
  }

  Future<void> remove(String localId) async {
    await ensureLoaded();
    _items.removeWhere((item) => item.localId == localId);
    await _persist();
  }

  Future<void> _persist() async {
    final file = await _ensureFile();
    final encoded = jsonEncode(_items.map((item) => item.toJson()).toList());
    await file.writeAsString(encoded, flush: true);
  }
}
