import 'package:begin_first/domain/models/intent.dart';

abstract class IntentRepository {
  Future<List<Intent>> getAllIntents();
  Future<List<Intent>> getActiveIntents();
  Future<Intent?> getIntentById(String id);
  Future<void> createIntent(Intent intent);
  Future<void> updateIntent(Intent intent);
  Future<void> deleteIntent(String id);
  Future<void> markAsCompleted(String id);
  Future<Intent?> getRandomActiveIntent();
}
