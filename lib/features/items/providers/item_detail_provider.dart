import 'package:begin_first/domain/models/item.dart';
import 'package:begin_first/features/items/providers/items_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final itemDetailProvider = Provider.family<Item?, String>((ref, itemId) {
  final items = ref.watch(itemsStreamProvider).valueOrNull ?? const <Item>[];
  for (final item in items) {
    if (item.id == itemId) {
      return item;
    }
  }
  return null;
});
