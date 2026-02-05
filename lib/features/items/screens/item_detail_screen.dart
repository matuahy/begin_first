import 'package:begin_first/app/theme.dart';
import 'package:begin_first/domain/models/enums/category.dart';
import 'package:begin_first/domain/models/enums/importance.dart';
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

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({required this.itemId, super.key});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsStreamProvider);
    final item = ref.watch(itemDetailProvider(itemId));
    final recordsAsync = ref.watch(itemRecordsProvider(itemId));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(item?.name ?? 'Item Detail'),
        trailing: item == null
            ? null
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => context.go('/items/$itemId/edit'),
                child: const Icon(CupertinoIcons.pencil),
              ),
      ),
      child: SafeArea(
        child: itemsAsync.when(
          data: (_) {
            if (item == null) {
              return const EmptyState(message: 'Item not found.');
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
                          label: 'Record',
                          onPressed: () => context.go('/items/$itemId/record'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppButton(
                          label: 'Retrieve',
                          onPressed: () => context.go('/items/$itemId/retrieve'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text('Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.sm),
                  recordsAsync.when(
                    data: (records) {
                      if (records.isEmpty) {
                        return const EmptyState(message: 'No records yet.');
                      }
                      return RecordTimeline(records: records);
                    },
                    loading: () => const Center(child: CupertinoActivityIndicator()),
                    error: (error, stack) => EmptyState(message: 'Failed to load records: $error'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Delete Item',
                    isDestructive: true,
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ],
              );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, stack) => EmptyState(message: 'Failed to load item: $error'),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Item'),
        content: const Text('This will remove the item and its records reference.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
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
