import 'package:begin_first/data/local/hive_initializer.dart';
import 'package:begin_first/domain/models/scene.dart';
import 'package:begin_first/domain/repositories/scene_repository.dart';

class SceneRepositoryImpl implements SceneRepository {
  SceneRepositoryImpl(this._boxes);

  final HiveBoxes _boxes;

  @override
  Future<List<Scene>> getAllScenes() async {
    final scenes = _boxes.scenes.values.toList();
    scenes.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return scenes;
  }

  @override
  Future<Scene?> getSceneById(String id) async {
    return _boxes.scenes.get(id);
  }

  @override
  Future<void> createScene(Scene scene) async {
    await _boxes.scenes.put(scene.id, scene);
  }

  @override
  Future<void> updateScene(Scene scene) async {
    await _boxes.scenes.put(scene.id, scene);
  }

  @override
  Future<void> deleteScene(String id) async {
    await _boxes.scenes.delete(id);
  }

  @override
  Future<void> updateSceneItems(String sceneId, List<String> itemIds) async {
    final scene = _boxes.scenes.get(sceneId);
    if (scene == null) {
      return;
    }
    final updated = scene.copyWith(defaultItemIds: itemIds);
    await _boxes.scenes.put(sceneId, updated);
  }
}
