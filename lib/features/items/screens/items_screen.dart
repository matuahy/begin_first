import 'package:begin_first/app/theme.dart';
import 'package:begin_first/core/extensions/datetime_ext.dart';
import 'package:begin_first/domain/models/enums/category.dart';
import 'package:begin_first/domain/models/enums/importance.dart';
import 'package:begin_first/features/items/providers/items_provider.dart';
import 'package:begin_first/features/items/widgets/item_list_tile.dart';
import 'package:begin_first/features/items/widgets/item_search_bar.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
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
    final allItems = itemsAsync.valueOrNull ?? const [];
    final visibleCount = _query.isEmpty
        ? allItems.length
        : allItems.where((item) => item.name.toLowerCase().contains(_query.toLowerCase())).length;

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
        child: DecoratedBox(
          decoration: AppDecorations.page,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                AppCard(
                  isEmphasized: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Icon(CupertinoIcons.cube_box, color: AppColors.primaryStrong),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('把常用物品先记住', style: AppTextStyles.heading),
                                SizedBox(height: AppSpacing.xs),
                                Text('需要时 30 秒内就能找到线索', style: AppTextStyles.bodyMuted),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _MetricPill(label: '总数', value: '${allItems.length}'),
                          const SizedBox(width: AppSpacing.sm),
                          _MetricPill(label: '当前', value: '$visibleCount'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
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
                        return EmptyState(
                          title: _query.isEmpty ? '还没有物品' : '没有匹配结果',
                          message: _query.isEmpty ? '先添加钥匙、门卡、耳机这些高频物品。' : '试试名称中的其他关键词。',
                          icon: _query.isEmpty ? CupertinoIcons.cube_box : CupertinoIcons.search,
                          actionLabel: _query.isEmpty ? '新建物品' : null,
                          onAction: _query.isEmpty ? () => context.go('/items/new') : null,
                        );
                      }

                      return ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final subtitle =
                              '${_categoryLabel(item.category)} · ${_importanceLabel(item.importance)} · 更新于 ${item.updatedAt.shortDate}';
                          return ItemListTile(
                            title: item.name,
                            subtitle: subtitle,
                            onTap: () => context.go('/items/${item.id}'),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CupertinoActivityIndicator()),
                    error: (error, stack) => EmptyState(
                      title: '加载失败',
                      message: '物品数据读取失败：$error',
                      icon: CupertinoIcons.exclamationmark_triangle,
                    ),
                  ),
                ),
              ],
            ),
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

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(width: AppSpacing.xs),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
