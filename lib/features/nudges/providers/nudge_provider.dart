import 'dart:math';

import 'package:begin_first/app/providers.dart';
import 'package:begin_first/data/local/hive_initializer.dart';
import 'package:begin_first/domain/models/intent.dart';
import 'package:begin_first/domain/repositories/intent_repository.dart';
import 'package:begin_first/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final randomNudgeProvider = FutureProvider<Intent?>((ref) async {
  return ref.read(nudgeActionsProvider).pickRandomIntent();
});

final pendingNudgesProvider = FutureProvider<List<PendingNudge>>((ref) async {
  final notificationService = ref.read(notificationServiceProvider);
  return notificationService.getPendingNudges();
});

final nudgeHistoryIdsProvider = StreamProvider<List<String>>((ref) {
  final box = ref.read(hiveBoxesProvider).nudgeHistory;

  List<String> buildList() {
    final keys = box.keys.whereType<int>().toList()..sort();
    final ordered = keys.reversed
        .map((key) => box.get(key))
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList();
    return ordered;
  }

  Stream<List<String>> stream() async* {
    yield buildList();
    yield* box.watch().map((_) => buildList());
  }

  return stream();
});

final nudgeActionsProvider = Provider<NudgeActions>((ref) {
  return NudgeActions(
    repository: ref.read(intentRepositoryProvider),
    notificationService: ref.read(notificationServiceProvider),
    boxes: ref.read(hiveBoxesProvider),
  );
});

class NudgeActions {
  NudgeActions({
    required this.repository,
    required this.notificationService,
    required this.boxes,
  });

  final IntentRepository repository;
  final NotificationService notificationService;
  final HiveBoxes boxes;
  final Random _random = Random();

  Future<Intent?> pickRandomIntent({int historyLimit = 5}) async {
    final intents = await repository.getActiveIntents();
    if (intents.isEmpty) {
      return null;
    }
    final recent = _recentHistory(historyLimit).toSet();
    final candidates = intents.where((intent) => !recent.contains(intent.id)).toList();
    final pool = candidates.isEmpty ? intents : candidates;
    return pool[_random.nextInt(pool.length)];
  }

  Future<bool> scheduleNudge({
    required Intent intent,
    required DateTime scheduledTime,
  }) async {
    await notificationService.initialize();
    final permission = await notificationService.requestNotificationPermission();
    if (!permission) {
      return false;
    }
    final id = _buildNotificationId();
    await notificationService.scheduleNudgeNotification(
      id: id,
      title: intent.title,
      body: intent.nextStep ?? '顺手提醒',
      scheduledTime: scheduledTime,
    );
    await _addToHistory(intent.id);
    return true;
  }

  Future<void> _addToHistory(String intentId, {int max = 10}) async {
    final box = boxes.nudgeHistory;
    await box.add(intentId);
    if (box.length <= max) {
      return;
    }
    final keys = box.keys.whereType<int>().toList()..sort();
    final removeCount = box.length - max;
    for (var i = 0; i < removeCount; i++) {
      await box.delete(keys[i]);
    }
  }

  List<String> _recentHistory(int limit) {
    final box = boxes.nudgeHistory;
    final keys = box.keys.whereType<int>().toList()..sort();
    final recentKeys = keys.length <= limit ? keys : keys.sublist(keys.length - limit);
    return recentKeys.map((key) => box.get(key) ?? '').where((id) => id.isNotEmpty).toList();
  }

  int _buildNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
  }
}
