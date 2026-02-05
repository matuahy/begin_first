import 'package:begin_first/app/providers.dart';
import 'package:begin_first/domain/models/scene.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scenesProvider = FutureProvider<List<Scene>>((ref) async {
  final repository = ref.read(sceneRepositoryProvider);
  return repository.getAllScenes();
});
