import 'package:begin_first/domain/models/item.dart';
import 'package:begin_first/features/items/providers/items_provider.dart';
import 'package:begin_first/features/scenes/providers/scene_detail_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final checkoutSceneProvider = StateProvider<String?>((ref) => null);
final checkoutCheckedProvider = StateProvider<Set<String>>((ref) => <String>{});

final checkoutItemsProvider = Provider<List<Item>>((ref) {
  final items = ref.watch(itemsStreamProvider).valueOrNull ?? const <Item>[];
  final sceneId = ref.watch(checkoutSceneProvider);
  if (sceneId == null) {
    return items;
  }
  final scene = ref.watch(sceneDetailProvider(sceneId));
  if (scene == null) {
    return const <Item>[];
  }
  final itemIds = scene.defaultItemIds.toSet();
  return items.where((item) => itemIds.contains(item.id)).toList();
});
