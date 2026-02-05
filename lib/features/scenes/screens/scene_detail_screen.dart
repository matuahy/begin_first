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
import 'package:begin_first/shared/widgets/app_card.dart';
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
        middle: Text(scene?.name ?? '场景详情'),
        trailing: scene == null
            ? null
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => context.go('/scenes/$sceneId/edit'),
                child: const Icon(CupertinoIcons.pencil),
              ),
      ),
      child: SafeArea(
        child: DecoratedBox(
          decoration: AppDecorations.page,
          child: scenesAsync.when(
            data: (_) {
              if (scene == null) {
                return const EmptyState(
                  title: '未找到场景',
                  message: '该场景可能已被删除。',
                  icon: CupertinoIcons.exclamationmark_circle,
                );
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
                  AppCard(
                    isEmphasized: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(scene.name, style: AppTextStyles.heading),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${_sceneTypeLabel(scene.type)} · ${scene.isActive ? '启用' : '停用'} · ${sceneItems.length} 个物品',
                          style: AppTextStyles.bodyMuted,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: '编辑场景',
                                leadingIcon: CupertinoIcons.pencil,
                                variant: AppButtonVariant.secondary,
                                onPressed: () => context.go('/scenes/$sceneId/edit'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppButton(
                                label: '开始记录',
                                leadingIcon: CupertinoIcons.camera,
                                onPressed: sceneItems.isEmpty
                                    ? null
                                    : () => _startRecording(context, ref, sceneId, orderedIds, sceneItems),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text('场景物品', style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.sm),
                  if (itemsAsync.isLoading)
                    const Center(child: CupertinoActivityIndicator())
                  else if (sceneItems.isEmpty)
                    const EmptyState(
                      title: '还没配置物品',
                      message: '给这个场景添加默认物品后，可一键连续记录。',
                      icon: CupertinoIcons.cube_box,
                      compact: true,
                    )
                  else
                    ...sceneItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ItemListTile(
                          title: item.name,
                          subtitle: '点击记录当前位置',
                          onTap: () => context.go('/items/${item.id}/record?sceneId=$sceneId'),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text('场景记录', style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.sm),
                  sceneRecordsAsync.when(
                    data: (records) {
                      if (records.isEmpty) {
                        return const EmptyState(
                          title: '暂无记录',
                          message: '试试"开始记录"，连续拍几张更高效。',
                          icon: CupertinoIcons.clock,
                          compact: true,
                        );
                      }
                      return RecordTimeline(
                        records: records,
                        onRecordTap: (record) => context.go('/records/${record.id}'),
                      );
                    },
                    loading: () => const Center(child: CupertinoActivityIndicator()),
                    error: (error, stack) => EmptyState(
                      title: '读取失败',
                      message: '加载记录失败：$error',
                      icon: CupertinoIcons.exclamationmark_triangle,
                      compact: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: DestructiveTextButton(
                      label: '删除这个场景',
                      onPressed: () => _confirmDelete(context, ref),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (error, stack) => EmptyState(
              title: '加载失败',
              message: '加载场景失败：$error',
              icon: CupertinoIcons.exclamationmark_triangle,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('删除场景'),
        content: const Text('将删除该场景，记录会保留。'),
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
        return '家';
      case SceneType.office:
        return '公司';
      case SceneType.parking:
        return '停车';
      case SceneType.travel:
        return '旅行';
      case SceneType.temporary:
        return '临时';
      case SceneType.custom:
        return '自定义';
    }
  }
}
