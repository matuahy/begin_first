import 'package:begin_first/domain/models/record.dart';

abstract class RecordRepository {
  Future<List<Record>> getRecordsByItemId(String itemId);
  Future<Record?> getLatestRecordByItemId(String itemId);
  Future<List<Record>> getRecordsBySceneId(String sceneId);
  Future<List<Record>> getRecordsByDateRange(DateTime start, DateTime end);

  Future<void> createRecord(Record record);
  Future<void> updateRecord(Record record);
  Future<void> deleteRecord(String id);

  Future<int> getRecordCountByItemId(String itemId);
  Future<int> getTotalRecordCount();
}
