import 'package:begin_first/data/local/hive_initializer.dart';
import 'package:begin_first/domain/models/record.dart';
import 'package:begin_first/domain/repositories/record_repository.dart';

class RecordRepositoryImpl implements RecordRepository {
  RecordRepositoryImpl(this._boxes);

  final HiveBoxes _boxes;

  @override
  Future<List<Record>> getRecordsByItemId(String itemId) async {
    final records = _boxes.records.values
        .where((record) => record.itemId == itemId)
        .toList();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  @override
  Future<Record?> getLatestRecordByItemId(String itemId) async {
    final records = await getRecordsByItemId(itemId);
    if (records.isEmpty) {
      return null;
    }
    return records.first;
  }

  @override
  Future<List<Record>> getRecordsBySceneId(String sceneId) async {
    final records = _boxes.records.values
        .where((record) => record.sceneId == sceneId)
        .toList();
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  @override
  Future<List<Record>> getRecordsByDateRange(DateTime start, DateTime end) async {
    return _boxes.records.values
        .where((record) {
          final time = record.timestamp;
          return !time.isBefore(start) && !time.isAfter(end);
        })
        .toList();
  }

  @override
  Future<void> createRecord(Record record) async {
    await _boxes.records.put(record.id, record);
  }

  @override
  Future<void> updateRecord(Record record) async {
    await _boxes.records.put(record.id, record);
  }

  @override
  Future<void> deleteRecord(String id) async {
    await _boxes.records.delete(id);
  }

  @override
  Future<int> getRecordCountByItemId(String itemId) async {
    return _boxes.records.values
        .where((record) => record.itemId == itemId)
        .length;
  }

  @override
  Future<int> getTotalRecordCount() async {
    return _boxes.records.length;
  }
}
