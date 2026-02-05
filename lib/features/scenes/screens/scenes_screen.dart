import 'package:begin_first/app/theme.dart';
import 'package:begin_first/domain/models/enums/scene_type.dart';
import 'package:begin_first/features/scenes/providers/scenes_provider.dart';
import 'package:begin_first/features/scenes/widgets/scene_card.dart';
import 'package:begin_first/shared/widgets/app_button.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ScenesScreen extends ConsumerWidget {
  const ScenesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenesAsync = ref.watch(scenesStreamProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('场景'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.push('/scenes/new'),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: DecoratedBox(
          decoration: AppDecorations.page,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: scenesAsync.when(
              data: (scenes) {
                final activeCount = scenes.where((scene) => scene.isActive).length;
                return Column(
                  children: [
                    AppCard(
                      isEmphasized: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('场景让记录更快', style: AppTextStyles.heading),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '当前启用 $activeCount 个场景，回家/出门都可以一键检查。',
                            style: AppTextStyles.bodyMuted,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            label: '开始出门检查',
                            leadingIcon: CupertinoIcons.check_mark_circled,
                            onPressed: () => context.push('/checkout'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: scenes.isEmpty
                          ? EmptyState(
                              title: '还没有场景',
                              message: '创建"回家""公司""下车"等场景后，可连续记录。',
                              icon: CupertinoIcons.square_grid_2x2,
                              actionLabel: '新建场景',
                              onAction: () => context.go('/scenes/new'),
                            )
                          : ListView.separated(
                              itemCount: scenes.length,
                              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                final scene = scenes[index];
                                final subtitle =
                                    '${_sceneTypeLabel(scene.type)} · ${scene.defaultItemIds.length} 个默认物品 · ${scene.isActive ? '启用' : '停用'}';
                                return SceneCard(
                                  title: scene.name,
                                  subtitle: subtitle,
                                  onTap: () => context.push('/scenes/${scene.id}'),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (error, stack) => EmptyState(
                title: '加载失败',
                message: '场景数据读取失败：$error',
                icon: CupertinoIcons.exclamationmark_triangle,
              ),
            ),
          ),
        ),
      ),
    );
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
