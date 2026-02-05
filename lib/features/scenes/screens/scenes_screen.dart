import 'package:begin_first/app/theme.dart';
import 'package:begin_first/domain/models/enums/scene_type.dart';
import 'package:begin_first/features/scenes/providers/scenes_provider.dart';
import 'package:begin_first/features/scenes/widgets/scene_card.dart';
import 'package:begin_first/shared/widgets/app_button.dart';
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
        middle: const Text('Scenes'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.go('/scenes/new'),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: scenesAsync.when(
            data: (scenes) {
              return Column(
                children: [
                  AppButton(
                    label: 'Checkout',
                    onPressed: () => context.go('/checkout'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: scenes.isEmpty
                        ? const EmptyState(message: 'No scenes yet.')
                        : ListView.separated(
                            itemCount: scenes.length,
                            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final scene = scenes[index];
                              final subtitle = '${_sceneTypeLabel(scene.type)} · ${scene.isActive ? 'Active' : 'Inactive'}';
                              return SceneCard(
                                title: scene.name,
                                subtitle: subtitle,
                                onTap: () => context.go('/scenes/${scene.id}'),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (error, stack) => EmptyState(message: 'Failed to load scenes: $error'),
          ),
        ),
      ),
    );
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
