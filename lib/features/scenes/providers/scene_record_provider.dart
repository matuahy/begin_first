import 'package:flutter_riverpod/flutter_riverpod.dart';

class SceneRecordSession {
  const SceneRecordSession({
    required this.sceneId,
    required this.itemIds,
    required this.currentIndex,
  });

  final String sceneId;
  final List<String> itemIds;
  final int currentIndex;

  String? get currentItemId =>
      itemIds.isEmpty || currentIndex >= itemIds.length ? null : itemIds[currentIndex];
  bool get hasNext => currentIndex + 1 < itemIds.length;

  SceneRecordSession copyWith({
    List<String>? itemIds,
    int? currentIndex,
  }) {
    return SceneRecordSession(
      sceneId: sceneId,
      itemIds: itemIds ?? this.itemIds,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

final sceneRecordSessionProvider = StateNotifierProvider<SceneRecordSessionNotifier, SceneRecordSession?>(
  (ref) => SceneRecordSessionNotifier(),
);

class SceneRecordSessionNotifier extends StateNotifier<SceneRecordSession?> {
  SceneRecordSessionNotifier() : super(null);

  String? start({required String sceneId, required List<String> itemIds}) {
    if (itemIds.isEmpty) {
      state = null;
      return null;
    }
    state = SceneRecordSession(
      sceneId: sceneId,
      itemIds: List<String>.from(itemIds),
      currentIndex: 0,
    );
    return state!.currentItemId;
  }

  String? advance() {
    final session = state;
    if (session == null) {
      return null;
    }
    if (!session.hasNext) {
      state = null;
      return null;
    }
    state = session.copyWith(currentIndex: session.currentIndex + 1);
    return state!.currentItemId;
  }

  void end() {
    state = null;
  }
}
