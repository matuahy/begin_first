import 'package:begin_first/app/theme.dart';
import 'package:begin_first/features/checkout/providers/checkout_provider.dart';
import 'package:begin_first/features/checkout/widgets/checklist_item.dart';
import 'package:begin_first/domain/models/scene.dart';
import 'package:begin_first/features/scenes/providers/scene_detail_provider.dart';
import 'package:begin_first/features/scenes/providers/scenes_provider.dart';
import 'package:begin_first/shared/widgets/app_button.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    final scenesAsync = ref.watch(scenesStreamProvider);
    final selectedSceneId = ref.watch(checkoutSceneProvider);
    final selectedScene = selectedSceneId == null ? null : ref.watch(sceneDetailProvider(selectedSceneId));
    final items = ref.watch(checkoutItemsProvider);
    final checked = ref.watch(checkoutCheckedProvider);
    final scenes = scenesAsync.valueOrNull ?? const <Scene>[];
    final activeScenes = scenes.where((scene) => scene.isActive).toList();
    final checkedCount = items.where((item) => checked.contains(item.id)).length;
    final missingCount = items.length - checkedCount;
    final completion = items.isEmpty ? 0.0 : checkedCount / items.length;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('出门检查'),
      ),
      child: SafeArea(
        child: DecoratedBox(
          decoration: AppDecorations.page,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  isEmphasized: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text('出门前 20 秒确认一下', style: AppTextStyles.heading),
                          ),
                          if (items.isNotEmpty)
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 0,
                              onPressed: _resetChecked,
                              child: const Text('重置'),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        onPressed: scenesAsync.isLoading ? null : () => _selectScene(activeScenes),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(selectedScene?.name ?? '全部物品', style: AppTextStyles.body),
                            const SizedBox(width: AppSpacing.xs),
                            const Icon(CupertinoIcons.chevron_down, size: 16),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: SizedBox(
                          height: 8,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(color: AppColors.groupedBackground),
                              FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: completion,
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.primary, AppColors.primaryStrong],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '已勾选 $checkedCount / ${items.length}',
                        style: AppTextStyles.bodyMuted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: items.isEmpty
                      ? const EmptyState(
                          title: '暂无可检查物品',
                          message: '先去物品页添加关键物品，或给场景配置默认物品。',
                          icon: CupertinoIcons.check_mark_circled,
                        )
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isChecked = checked.contains(item.id);
                            return ChecklistItem(
                              title: item.name,
                              isChecked: isChecked,
                              onChanged: (value) => _toggleItem(item.id, value),
                            );
                          },
                        ),
                ),
                if (items.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: missingCount == 0 ? '完成出门检查' : '仍有 $missingCount 项未确认',
                    leadingIcon: missingCount == 0 ? CupertinoIcons.check_mark_circled : CupertinoIcons.exclamationmark_circle,
                    variant: missingCount == 0 ? AppButtonVariant.primary : AppButtonVariant.secondary,
                    onPressed: () => _finishCheckout(missingCount),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectScene(List<Scene> scenes) async {
    const allKey = '__all__';
    final result = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('选择场景'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(allKey),
              child: const Text('全部物品'),
            ),
            ...scenes.map(
              (scene) => CupertinoActionSheetAction(
                onPressed: () => Navigator.of(context).pop(scene.id),
                child: Text(scene.name),
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        );
      },
    );

    if (result == null) {
      return;
    }

    if (result == allKey) {
      ref.read(checkoutSceneProvider.notifier).state = null;
    } else {
      ref.read(checkoutSceneProvider.notifier).state = result;
    }
    _resetChecked();
  }

  void _toggleItem(String itemId, bool value) {
    final current = ref.read(checkoutCheckedProvider);
    final next = {...current};
    if (value) {
      next.add(itemId);
    } else {
      next.remove(itemId);
    }
    ref.read(checkoutCheckedProvider.notifier).state = next;
  }

  void _resetChecked() {
    ref.read(checkoutCheckedProvider.notifier).state = <String>{};
  }

  Future<void> _finishCheckout(int missingCount) async {
    final title = missingCount == 0 ? '准备好了' : '还有遗漏';
    final message = missingCount == 0
        ? '本次出门检查已完成，祝你一路顺利。'
        : '还有 $missingCount 项未确认。你可以返回继续检查，也可以直接结束。';

    final shouldFinish = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('继续检查'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('完成'),
          ),
        ],
      ),
    );

    if (shouldFinish == true) {
      _resetChecked();
      if (mounted) {
        await showCupertinoDialog<void>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('已完成'),
            content: const Text('下次出门前再来快速确认一次。'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('知道了'),
              ),
            ],
          ),
        );
      }
    }
  }
}
