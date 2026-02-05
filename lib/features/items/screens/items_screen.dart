import 'package:begin_first/app/theme.dart';
import 'package:begin_first/domain/models/enums/category.dart';
import 'package:begin_first/domain/models/enums/importance.dart';
import 'package:begin_first/features/items/providers/items_provider.dart';
import 'package:begin_first/features/items/widgets/item_list_tile.dart';
import 'package:begin_first/features/items/widgets/item_search_bar.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ItemsScreen extends ConsumerStatefulWidget {
  const ItemsScreen({super.key});

  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsStreamProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Items'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.go('/items/new'),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              ItemSearchBar(
                onChanged: (value) => setState(() => _query = value.trim()),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: itemsAsync.when(
                  data: (items) {
                    final filtered = _query.isEmpty
                        ? items
                        : items
                            .where((item) => item.name.toLowerCase().contains(_query.toLowerCase()))
                            .toList();

                    if (filtered.isEmpty) {
                      return const EmptyState(message: 'No items yet.');
                    }

                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final subtitle = '${_categoryLabel(item.category)} · ${_importanceLabel(item.importance)}';
                        return ItemListTile(
                          title: item.name,
                          subtitle: subtitle,
                          onTap: () => context.go('/items/${item.id}'),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CupertinoActivityIndicator()),
                  error: (error, stack) => EmptyState(message: 'Failed to load items: $error'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(Category category) {
    switch (category) {
      case Category.keys:
        return 'Keys';
      case Category.cards:
        return 'Cards';
      case Category.digital:
        return 'Digital';
      case Category.documents:
        return 'Documents';
      case Category.daily:
        return 'Daily';
      case Category.other:
        return 'Other';
    }
  }

  String _importanceLabel(Importance importance) {
    switch (importance) {
      case Importance.high:
        return 'High';
      case Importance.medium:
        return 'Medium';
      case Importance.low:
        return 'Low';
    }
  }
}
