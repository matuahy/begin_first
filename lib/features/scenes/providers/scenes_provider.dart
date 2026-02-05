import 'dart:math';

import 'package:begin_first/app/providers.dart';
import 'package:begin_first/core/utils/id_generator.dart';
import 'package:begin_first/domain/models/enums/scene_type.dart';
import 'package:begin_first/domain/models/scene.dart';
import 'package:begin_first/domain/repositories/scene_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scenesStreamProvider = StreamProvider<List<Scene>>((ref) {
  final box = ref.read(hiveBoxesProvider).scenes;
  List<Scene> buildList() {
    final scenes = box.values.toList();
    scenes.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return scenes;
  }

  Stream<List<Scene>> stream() async* {
    yield buildList();
    yield* box.watch().map((_) => buildList());
  }

  return stream();
});

final sceneActionsProvider = Provider<SceneActions>((ref) {
  return SceneActions(ref.read(sceneRepositoryProvider));
});

class SceneActions {
  SceneActions(this._repository);

  final SceneRepository _repository;

  Future<Scene> createScene({
    required String name,
    required SceneType type,
    required String iconName,
    List<String> defaultItemIds = const [],
    bool isActive = true,
  }) async {
    final scenes = await _repository.getAllScenes();
    final maxSort = scenes.isEmpty ? -1 : scenes.map((scene) => scene.sortOrder).reduce(max);
    final scene = Scene(
      id: IdGenerator.newId(),
      name: name,
      type: type,
      iconName: iconName,
      defaultItemIds: defaultItemIds,
      isActive: isActive,
      sortOrder: maxSort + 1,
    );
    await _repository.createScene(scene);
    return scene;
  }

  Future<void> updateScene(Scene scene) async {
    await _repository.updateScene(scene);
  }

  Future<void> deleteScene(String id) async {
    await _repository.deleteScene(id);
  }

  Future<void> updateSceneItems(String id, List<String> itemIds) async {
    await _repository.updateSceneItems(id, itemIds);
  }
}
