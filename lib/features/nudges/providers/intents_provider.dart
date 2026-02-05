import 'package:begin_first/app/providers.dart';
import 'package:begin_first/core/utils/id_generator.dart';
import 'package:begin_first/domain/models/intent.dart';
import 'package:begin_first/domain/repositories/intent_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final intentsStreamProvider = StreamProvider<List<Intent>>((ref) {
  final box = ref.read(hiveBoxesProvider).intents;
  List<Intent> buildList() {
    final intents = box.values.toList();
    intents.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return intents;
  }

  Stream<List<Intent>> stream() async* {
    yield buildList();
    yield* box.watch().map((_) => buildList());
  }

  return stream();
});

final intentDetailProvider = Provider.family<Intent?, String>((ref, intentId) {
  final intents = ref.watch(intentsStreamProvider).valueOrNull ?? const <Intent>[];
  for (final intent in intents) {
    if (intent.id == intentId) {
      return intent;
    }
  }
  return null;
});

final intentActionsProvider = Provider<IntentActions>((ref) {
  return IntentActions(ref.read(intentRepositoryProvider));
});

class IntentActions {
  IntentActions(this._repository);

  final IntentRepository _repository;

  Future<Intent> createIntent({
    required String title,
    String? nextStep,
    List<String> tags = const [],
  }) async {
    final now = DateTime.now();
    final intent = Intent(
      id: IdGenerator.newId(),
      title: title,
      nextStep: nextStep,
      tags: tags,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.createIntent(intent);
    return intent;
  }

  Future<void> updateIntent(Intent intent) async {
    await _repository.updateIntent(intent);
  }

  Future<void> deleteIntent(String id) async {
    await _repository.deleteIntent(id);
  }

  Future<void> setCompleted(Intent intent, bool isCompleted) async {
    final updated = intent.copyWith(
      isCompleted: isCompleted,
      updatedAt: DateTime.now(),
    );
    await _repository.updateIntent(updated);
  }
}
