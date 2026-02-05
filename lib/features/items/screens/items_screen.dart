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
        middle: const Text('物品'),
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
                      return const EmptyState(message: '暂无物品');
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
                  error: (error, stack) => EmptyState(message: '加载物品失败：$error'),
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
        return '钥匙';
      case Category.cards:
        return '卡证';
      case Category.digital:
        return '数码';
      case Category.documents:
        return '证件文件';
      case Category.daily:
        return '日常用品';
      case Category.other:
        return '其他';
    }
  }

  String _importanceLabel(Importance importance) {
    switch (importance) {
      case Importance.high:
        return '高';
      case Importance.medium:
        return '中';
      case Importance.low:
        return '低';
    }
  }
}
