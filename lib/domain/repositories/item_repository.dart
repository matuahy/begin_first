import 'package:begin_first/domain/models/enums/category.dart';
import 'package:begin_first/domain/models/item.dart';

abstract class ItemRepository {
  Future<List<Item>> getAllItems();
  Future<Item?> getItemById(String id);
  Future<List<Item>> searchItems(String keyword);
  Future<List<Item>> getItemsByCategory(Category category);

  Future<void> createItem(Item item);
  Future<void> updateItem(Item item);
  Future<void> deleteItem(String id);

  Stream<List<Item>> watchAllItems();
}
