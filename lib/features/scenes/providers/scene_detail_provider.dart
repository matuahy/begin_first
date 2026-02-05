import 'package:begin_first/domain/models/scene.dart';
import 'package:begin_first/features/scenes/providers/scenes_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sceneDetailProvider = Provider.family<Scene?, String>((ref, sceneId) {
  final scenes = ref.watch(scenesStreamProvider).valueOrNull ?? const <Scene>[];
  for (final scene in scenes) {
    if (scene.id == sceneId) {
      return scene;
    }
  }
  return null;
});
