import 'package:begin_first/app/theme.dart';
import 'package:begin_first/domain/models/enums/category.dart';
import 'package:begin_first/domain/models/enums/importance.dart';
import 'package:begin_first/domain/models/enums/scene_type.dart';
import 'package:begin_first/features/items/providers/items_provider.dart';
import 'package:begin_first/features/onboarding/widgets/onboarding_page.dart';
import 'package:begin_first/features/scenes/providers/scenes_provider.dart';
import 'package:begin_first/features/settings/providers/settings_provider.dart';
import 'package:begin_first/shared/widgets/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final PageController _controller = PageController();
  int _pageIndex = 0;
  bool _isSaving = false;
  final Set<String> _selectedItemKeys = <String>{'keys', 'wallet', 'phone'};
  final Set<String> _selectedSceneKeys = <String>{'home', 'office'};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('欢迎'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 6,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: AppColors.groupedBackground),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (_pageIndex + 1) / 3,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryStrong]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) => setState(() => _pageIndex = index),
                children: [
                  _buildWelcome(),
                  _buildSelectItems(),
                  _buildSelectScenes(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: _pageIndex < 2 ? '下一步' : (_isSaving ? '保存中...' : '完成'),
                      leadingIcon: _pageIndex < 2 ? CupertinoIcons.arrow_right : CupertinoIcons.checkmark,
                      onPressed: _isSaving ? null : (_pageIndex < 2 ? _nextPage : _finish),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return const OnboardingPage(
      title: '欢迎使用',
      description: '用最短时间记录随身物品的位置。',
    );
  }

  Widget _buildSelectItems() {
    return OnboardingPage(
      title: '选择起步物品',
      description: '先选几个常用物品快速开始。',
      child: CupertinoFormSection.insetGrouped(
        header: const Text('物品'),
        children: _suggestedItems
            .map(
              (item) => CupertinoFormRow(
                prefix: Text(item.label),
                child: CupertinoSwitch(
                  value: _selectedItemKeys.contains(item.key),
                  onChanged: (value) => _toggleItem(item.key, value),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSelectScenes() {
    return OnboardingPage(
      title: '选择场景',
      description: '选择常用场景，便于连续记录。',
      child: CupertinoFormSection.insetGrouped(
        header: const Text('场景'),
        children: _suggestedScenes
            .map(
              (scene) => CupertinoFormRow(
                prefix: Text(scene.label),
                child: CupertinoSwitch(
                  value: _selectedSceneKeys.contains(scene.key),
                  onChanged: (value) => _toggleScene(scene.key, value),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _nextPage() {
    if (_pageIndex < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _toggleItem(String key, bool value) {
    setState(() {
      if (value) {
        _selectedItemKeys.add(key);
      } else {
        _selectedItemKeys.remove(key);
      }
    });
  }

  void _toggleScene(String key, bool value) {
    setState(() {
      if (value) {
        _selectedSceneKeys.add(key);
      } else {
        _selectedSceneKeys.remove(key);
      }
    });
  }

  Future<void> _finish() async {
    setState(() => _isSaving = true);
    final itemActions = ref.read(itemActionsProvider);
    final sceneActions = ref.read(sceneActionsProvider);
    final existingItems = ref.read(itemsStreamProvider).valueOrNull ?? const [];
    final existingScenes = ref.read(scenesStreamProvider).valueOrNull ?? const [];

    final existingItemNames = existingItems.map((item) => item.name.toLowerCase()).toSet();
    final existingSceneNames = existingScenes.map((scene) => scene.name.toLowerCase()).toSet();

    for (final template in _suggestedItems) {
      if (_selectedItemKeys.contains(template.key) && !existingItemNames.contains(template.label.toLowerCase())) {
        await itemActions.createItem(
          name: template.label,
          category: template.category,
          importance: template.importance,
        );
      }
    }

    for (final template in _suggestedScenes) {
      if (_selectedSceneKeys.contains(template.key) && !existingSceneNames.contains(template.label.toLowerCase())) {
        await sceneActions.createScene(
          name: template.label,
          type: template.type,
          iconName: template.iconName,
          isActive: true,
        );
      }
    }

    await ref.read(appSettingsProvider.notifier).completeOnboarding();
    if (mounted) {
      setState(() => _isSaving = false);
      context.go('/items');
    }
  }
}

class _SuggestedItem {
  const _SuggestedItem({
    required this.key,
    required this.label,
    required this.category,
    required this.importance,
  });

  final String key;
  final String label;
  final Category category;
  final Importance importance;
}

class _SuggestedScene {
  const _SuggestedScene({
    required this.key,
    required this.label,
    required this.type,
    required this.iconName,
  });

  final String key;
  final String label;
  final SceneType type;
  final String iconName;
}

const List<_SuggestedItem> _suggestedItems = [
  _SuggestedItem(key: 'keys', label: '钥匙', category: Category.keys, importance: Importance.high),
  _SuggestedItem(key: 'wallet', label: '钱包', category: Category.cards, importance: Importance.high),
  _SuggestedItem(key: 'phone', label: '手机', category: Category.digital, importance: Importance.high),
  _SuggestedItem(key: 'badge', label: '工牌', category: Category.cards, importance: Importance.medium),
  _SuggestedItem(key: 'laptop', label: '笔记本', category: Category.digital, importance: Importance.medium),
];

const List<_SuggestedScene> _suggestedScenes = [
  _SuggestedScene(key: 'home', label: '家', type: SceneType.home, iconName: 'home'),
  _SuggestedScene(key: 'office', label: '公司', type: SceneType.office, iconName: 'office'),
  _SuggestedScene(key: 'parking', label: '停车', type: SceneType.parking, iconName: 'parking'),
  _SuggestedScene(key: 'travel', label: '旅行', type: SceneType.travel, iconName: 'travel'),
];
