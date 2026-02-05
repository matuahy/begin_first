import 'package:begin_first/data/local/hive_initializer.dart';
import 'package:begin_first/domain/models/enums/category.dart';
import 'package:begin_first/domain/models/item.dart';
import 'package:begin_first/domain/repositories/item_repository.dart';

class ItemRepositoryImpl implements ItemRepository {
  ItemRepositoryImpl(this._boxes);

  final HiveBoxes _boxes;

  @override
  Future<List<Item>> getAllItems() async {
    return _sortedItems();
  }

  @override
  Future<Item?> getItemById(String id) async {
    return _boxes.items.get(id);
  }

  @override
  Future<List<Item>> searchItems(String keyword) async {
    final query = keyword.trim().toLowerCase();
    final items = _boxes.items.values
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  @override
  Future<List<Item>> getItemsByCategory(Category category) async {
    final items = _boxes.items.values
        .where((item) => item.category == category)
        .toList();
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }

  @override
  Future<void> createItem(Item item) async {
    await _boxes.items.put(item.id, item);
  }

  @override
  Future<void> updateItem(Item item) async {
    await _boxes.items.put(item.id, item);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _boxes.items.delete(id);
  }

  @override
  Stream<List<Item>> watchAllItems() async* {
    yield _sortedItems();
    yield* _boxes.items.watch().map((_) => _sortedItems());
  }

  List<Item> _sortedItems() {
    final items = _boxes.items.values.toList();
    items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items;
  }
}
