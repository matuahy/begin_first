import 'package:begin_first/app/providers.dart';
import 'package:begin_first/core/utils/id_generator.dart';
import 'package:begin_first/domain/models/enums/category.dart';
import 'package:begin_first/domain/models/enums/importance.dart';
import 'package:begin_first/domain/models/item.dart';
import 'package:begin_first/domain/repositories/item_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final itemsStreamProvider = StreamProvider<List<Item>>((ref) {
  final repository = ref.read(itemRepositoryProvider);
  return repository.watchAllItems();
});

final itemActionsProvider = Provider<ItemActions>((ref) {
  return ItemActions(ref.read(itemRepositoryProvider));
});

class ItemActions {
  ItemActions(this._repository);

  final ItemRepository _repository;

  Future<Item> createItem({
    required String name,
    required Category category,
    required Importance importance,
    String? iconName,
  }) async {
    final now = DateTime.now();
    final item = Item(
      id: IdGenerator.newId(),
      name: name,
      category: category,
      importance: importance,
      iconName: iconName,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.createItem(item);
    return item;
  }

  Future<void> updateItem(Item item) async {
    await _repository.updateItem(item);
  }

  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
  }
}
