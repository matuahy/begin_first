import 'package:begin_first/app/theme.dart';
import 'package:begin_first/domain/models/enums/category.dart';
import 'package:begin_first/domain/models/enums/importance.dart';
import 'package:begin_first/domain/models/record.dart';
import 'package:begin_first/features/items/providers/item_detail_provider.dart';
import 'package:begin_first/features/items/providers/items_provider.dart';
import 'package:begin_first/features/records/providers/record_provider.dart';
import 'package:begin_first/features/records/widgets/record_timeline.dart';
import 'package:begin_first/shared/widgets/action_button_card.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:begin_first/shared/widgets/app_button.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:begin_first/shared/widgets/photo_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({required this.itemId, super.key});

  final String itemId;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  RecordFilter _filter = RecordFilter.all;

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsStreamProvider);
    final item = ref.watch(itemDetailProvider(widget.itemId));
    final recordsAsync = ref.watch(itemRecordsProvider(widget.itemId));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(item?.name ?? '物品详情'),
        trailing: item == null
            ? null
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => context.push('/items/${widget.itemId}/edit'),
                child: const Icon(CupertinoIcons.pencil),
              ),
      ),
      child: SafeArea(
        child: DecoratedBox(
          decoration: AppDecorations.page,
          child: itemsAsync.when(
            data: (_) {
              if (item == null) {
                return const EmptyState(
                  icon: CupertinoIcons.cube_box,
                  title: '未找到物品',
                  message: '该物品可能已被删除或不存在',
                );
              }
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  PhotoViewer(path: item.coverImagePath, height: 220),
                  const SizedBox(height: AppSpacing.lg),
                  _buildInfoCard(item.name, item.category, item.importance),
                  const SizedBox(height: AppSpacing.md),
                  ActionButtonCardRow(
                    children: [
                      ActionButtonCard(
                        icon: CupertinoIcons.pencil_outline,
                        title: '添加记录',
                        subtitle: '记录这件物品的存放位置',
                        onTap: () => context.push('/items/${widget.itemId}/record'),
                      ),
                      ActionButtonCard(
                        icon: CupertinoIcons.location,
                        title: '找回物品',
                        subtitle: '查看存放位置，快速定位',
                        iconColor: AppColors.success,
                        onTap: () => context.push('/items/${widget.itemId}/retrieve'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildRecordsSection(context, recordsAsync),
                  const SizedBox(height: AppSpacing.xl),
                  _buildDangerZone(context, ref),
                  const SizedBox(height: AppSpacing.lg),
                ],
              );
            },
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (error, stack) => EmptyState(
              icon: CupertinoIcons.exclamationmark_triangle,
              title: '加载失败',
              message: '无法加载物品信息：$error',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String name,
    Category category,
    Importance importance,
  ) {
    return AppCard(
      isEmphasized: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: AppTextStyles.title1),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _buildTag(_categoryLabel(category), AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              _buildTag(
                '重要性：${_importanceLabel(importance)}',
                _importanceColor(importance),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption1.copyWith(color: color),
      ),
    );
  }

  Widget _buildRecordsSection(
    BuildContext context,
    AsyncValue<List<Record>> recordsAsync,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('最近记录', style: AppTextStyles.headline),
          const SizedBox(height: AppSpacing.xs),
          const Text('按时间范围筛选', style: AppTextStyles.bodyMuted),
          const SizedBox(height: AppSpacing.md),
          _FilterControl(
            value: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: AppSpacing.md),
          recordsAsync.when(
            data: (records) {
              final filtered = _applyFilter(records);
              if (filtered.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: EmptyState(
                    icon: CupertinoIcons.doc_text,
                    title: '还没有任何记录',
                    message: '添加第一条记录，开始追踪这件物品',
                    actionLabel: '添加记录',
                    onAction: () =>
                        context.push('/items/${widget.itemId}/record'),
                  ),
                );
              }
              return RecordTimeline(
                records: filtered,
                onRecordTap: (record) => context.push('/records/${record.id}'),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CupertinoActivityIndicator()),
            ),
            error: (error, stack) => EmptyState(
              icon: CupertinoIcons.exclamationmark_triangle,
              title: '加载记录失败',
              message: '$error',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, WidgetRef ref) {
    return Center(
      child: DestructiveTextButton(
        label: '删除这件物品',
        onPressed: () => _confirmDelete(context, ref),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后将无法恢复，该物品的所有记录引用也会被移除。'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (result == true) {
      await ref.read(itemActionsProvider).deleteItem(widget.itemId);
      if (context.mounted) {
        context.go('/items');
      }
    }
  }

  Color _importanceColor(Importance importance) {
    switch (importance) {
      case Importance.high:
        return AppColors.error;
      case Importance.medium:
        return AppColors.warning;
      case Importance.low:
        return AppColors.success;
    }
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

  List<Record> _applyFilter(List<Record> records) {
    if (_filter == RecordFilter.all) {
      return records;
    }
    final now = DateTime.now();
    final cutoff = _filter == RecordFilter.last7
        ? now.subtract(const Duration(days: 7))
        : now.subtract(const Duration(days: 30));
    return records.where((record) => record.timestamp.isAfter(cutoff)).toList();
  }
}

enum RecordFilter { all, last7, last30 }

class _FilterControl extends StatelessWidget {
  const _FilterControl({required this.value, required this.onChanged});

  final RecordFilter value;
  final ValueChanged<RecordFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl<RecordFilter>(
      groupValue: value,
      onValueChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      children: const {
        RecordFilter.all: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('全部'),
        ),
        RecordFilter.last7: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('近 7 天'),
        ),
        RecordFilter.last30: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('近 30 天'),
        ),
      },
    );
  }
}
