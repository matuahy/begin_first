import 'package:begin_first/app/theme.dart';
import 'package:begin_first/domain/models/enums/category.dart';
import 'package:begin_first/domain/models/enums/importance.dart';
import 'package:begin_first/domain/models/record.dart';
import 'package:begin_first/features/items/providers/item_detail_provider.dart';
import 'package:begin_first/features/items/providers/items_provider.dart';
import 'package:begin_first/features/records/providers/record_provider.dart';
import 'package:begin_first/features/records/widgets/record_timeline.dart';
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
                onPressed: () => context.go('/items/${widget.itemId}/edit'),
                child: const Icon(CupertinoIcons.pencil),
              ),
      ),
      child: SafeArea(
        child: itemsAsync.when(
          data: (_) {
            if (item == null) {
              return const EmptyState(message: '未找到物品');
            }
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                PhotoViewer(path: item.coverImagePath, height: 180),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${_categoryLabel(item.category)} · ${_importanceLabel(item.importance)}',
                  style: const TextStyle(color: CupertinoColors.secondaryLabel),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: '记录',
                        onPressed: () => context.go('/items/${widget.itemId}/record'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: '找回',
                        onPressed: () => context.go('/items/${widget.itemId}/retrieve'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                _FilterControl(
                  value: _filter,
                  onChanged: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: AppSpacing.sm),
                recordsAsync.when(
                  data: (records) {
                    final filtered = _applyFilter(records);
                    if (filtered.isEmpty) {
                      return const EmptyState(message: '暂无记录');
                    }
                    return RecordTimeline(
                      records: filtered,
                      onRecordTap: (record) => context.go('/records/${record.id}'),
                    );
                  },
                  loading: () => const Center(child: CupertinoActivityIndicator()),
                  error: (error, stack) => EmptyState(message: '加载记录失败：$error'),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: '删除物品',
                  isDestructive: true,
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ],
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, stack) => EmptyState(message: '加载物品失败：$error'),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('删除物品'),
        content: const Text('将删除该物品及其关联记录的引用。'),
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
      await ref.read(itemActionsProvider).deleteItem(itemId);
      if (context.mounted) {
        context.go('/items');
      }
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
    return CupertinoSegmentedControl<RecordFilter>(
      groupValue: value,
      onValueChanged: onChanged,
      children: const {
        RecordFilter.all: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('全部'),
        ),
        RecordFilter.last7: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('7天'),
        ),
        RecordFilter.last30: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('30天'),
        ),
      },
    );
  }
}
