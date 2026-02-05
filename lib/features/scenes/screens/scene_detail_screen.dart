import 'package:begin_first/app/theme.dart';
import 'package:begin_first/domain/models/enums/scene_type.dart';
import 'package:begin_first/domain/models/item.dart';
import 'package:begin_first/features/items/providers/items_provider.dart';
import 'package:begin_first/features/items/widgets/item_list_tile.dart';
import 'package:begin_first/features/records/providers/record_provider.dart';
import 'package:begin_first/features/records/widgets/record_timeline.dart';
import 'package:begin_first/features/scenes/providers/scene_detail_provider.dart';
import 'package:begin_first/features/scenes/providers/scene_record_provider.dart';
import 'package:begin_first/features/scenes/providers/scenes_provider.dart';
import 'package:begin_first/shared/widgets/app_button.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SceneDetailScreen extends ConsumerWidget {
  const SceneDetailScreen({required this.sceneId, super.key});

  final String sceneId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenesAsync = ref.watch(scenesStreamProvider);
    final itemsAsync = ref.watch(itemsStreamProvider);
    final scene = ref.watch(sceneDetailProvider(sceneId));
    final sceneRecordsAsync = ref.watch(sceneRecordsProvider(sceneId));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(scene?.name ?? 'Scene Detail'),
        trailing: scene == null
            ? null
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => context.go('/scenes/$sceneId/edit'),
                child: const Icon(CupertinoIcons.pencil),
              ),
      ),
      child: SafeArea(
        child: scenesAsync.when(
          data: (_) {
            if (scene == null) {
              return const EmptyState(message: 'Scene not found.');
            }

            final orderedIds = scene.defaultItemIds;
            final items = itemsAsync.valueOrNull ?? const <Item>[];
            final itemMap = <String, Item>{
              for (final item in items) item.id: item,
            };
            final sceneItems = orderedIds
                .map((id) => itemMap[id])
                .whereType<Item>()
                .toList();

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  '${_sceneTypeLabel(scene.type)} · ${scene.isActive ? 'Active' : 'Inactive'}',
                  style: const TextStyle(color: CupertinoColors.secondaryLabel),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Edit Scene Items',
                        onPressed: () => context.go('/scenes/$sceneId/edit'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: 'Start Recording',
                        onPressed: sceneItems.isEmpty
                            ? null
                            : () => _startRecording(context, ref, sceneId, orderedIds, sceneItems),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                if (itemsAsync.isLoading)
                  const Center(child: CupertinoActivityIndicator())
                else if (sceneItems.isEmpty)
                  const EmptyState(message: 'No items in this scene.')
                else
                  ...sceneItems.map(
                    (item) => ItemListTile(
                      title: item.name,
                      subtitle: 'Tap to record',
                      onTap: () => context.go('/items/${item.id}/record?sceneId=$sceneId'),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Scene Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.sm),
                sceneRecordsAsync.when(
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
                  label: 'Delete Scene',
                  isDestructive: true,
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ],
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, stack) => EmptyState(message: 'Failed to load scene: $error'),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Scene'),
        content: const Text('This will remove the scene. Records remain.'),
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
      await ref.read(sceneActionsProvider).deleteScene(sceneId);
      if (context.mounted) {
        context.go('/scenes');
      }
    }
  }

  Future<void> _startRecording(
    BuildContext context,
    WidgetRef ref,
    String sceneId,
    List<String> orderedIds,
    List<Item> sceneItems,
  ) async {
    final sceneItemIds = sceneItems.map((item) => item.id).toSet();
    final queue = <String>[];
    for (final id in orderedIds) {
      if (sceneItemIds.contains(id) && !queue.contains(id)) {
        queue.add(id);
      }
    }
    final firstItemId = ref.read(sceneRecordSessionProvider.notifier).start(
          sceneId: sceneId,
          itemIds: queue,
        );
    if (firstItemId == null) {
      return;
    }
    context.go('/items/$firstItemId/record?sceneId=$sceneId');
  }

  String _sceneTypeLabel(SceneType type) {
    switch (type) {
      case SceneType.home:
        return 'Home';
      case SceneType.office:
        return 'Office';
      case SceneType.parking:
        return 'Parking';
      case SceneType.travel:
        return 'Travel';
      case SceneType.temporary:
        return 'Temporary';
      case SceneType.custom:
        return 'Custom';
    }
  }
}
