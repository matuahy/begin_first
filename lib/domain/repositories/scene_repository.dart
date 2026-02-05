import 'package:begin_first/domain/models/scene.dart';

abstract class SceneRepository {
  Future<List<Scene>> getAllScenes();
  Future<Scene?> getSceneById(String id);
  Future<void> createScene(Scene scene);
  Future<void> updateScene(Scene scene);
  Future<void> deleteScene(String id);
  Future<void> updateSceneItems(String sceneId, List<String> itemIds);
}
