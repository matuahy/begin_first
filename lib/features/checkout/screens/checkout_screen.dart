import 'package:begin_first/app/theme.dart';
import 'package:begin_first/features/checkout/providers/checkout_provider.dart';
import 'package:begin_first/features/checkout/widgets/checklist_item.dart';
import 'package:begin_first/domain/models/scene.dart';
import 'package:begin_first/features/scenes/providers/scene_detail_provider.dart';
import 'package:begin_first/features/scenes/providers/scenes_provider.dart';
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

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Checkout'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: items.isEmpty ? null : _resetChecked,
          child: const Text('Reset'),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: scenesAsync.isLoading ? null : () => _selectScene(activeScenes),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(selectedScene?.name ?? 'All items'),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(CupertinoIcons.chevron_down, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('$checkedCount / ${items.length} checked', style: const TextStyle(color: CupertinoColors.secondaryLabel)),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: items.isEmpty
                    ? const EmptyState(message: 'No items to check.')
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
            ],
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
          title: const Text('Select Scene'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(allKey),
              child: const Text('All items'),
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
            child: const Text('Cancel'),
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
}
