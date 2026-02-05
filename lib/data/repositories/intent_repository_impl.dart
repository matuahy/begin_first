import 'dart:math';

import 'package:begin_first/data/local/hive_initializer.dart';
import 'package:begin_first/domain/models/intent.dart';
import 'package:begin_first/domain/repositories/intent_repository.dart';

class IntentRepositoryImpl implements IntentRepository {
  IntentRepositoryImpl(this._boxes);

  final HiveBoxes _boxes;
  final Random _random = Random();

  @override
  Future<List<Intent>> getAllIntents() async {
    return _boxes.intents.values.toList();
  }

  @override
  Future<List<Intent>> getActiveIntents() async {
    return _boxes.intents.values
        .where((intent) => !intent.isCompleted)
        .toList();
  }

  @override
  Future<Intent?> getIntentById(String id) async {
    return _boxes.intents.get(id);
  }

  @override
  Future<void> createIntent(Intent intent) async {
    await _boxes.intents.put(intent.id, intent);
  }

  @override
  Future<void> updateIntent(Intent intent) async {
    await _boxes.intents.put(intent.id, intent);
  }

  @override
  Future<void> deleteIntent(String id) async {
    await _boxes.intents.delete(id);
  }

  @override
  Future<void> markAsCompleted(String id) async {
    final intent = _boxes.intents.get(id);
    if (intent == null) {
      return;
    }
    final updated = intent.copyWith(
      isCompleted: true,
      updatedAt: DateTime.now(),
    );
    await _boxes.intents.put(id, updated);
  }

  @override
  Future<Intent?> getRandomActiveIntent() async {
    final active = await getActiveIntents();
    if (active.isEmpty) {
      return null;
    }
    final index = _random.nextInt(active.length);
    return active[index];
  }
}
