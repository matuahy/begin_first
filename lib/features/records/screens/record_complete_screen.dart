import 'package:begin_first/app/providers.dart';
import 'package:begin_first/app/theme.dart';
import 'package:begin_first/domain/models/location_info.dart';
import 'package:begin_first/features/records/models/record_draft.dart';
import 'package:begin_first/features/records/providers/record_provider.dart';
import 'package:begin_first/features/scenes/providers/scene_record_provider.dart';
import 'package:begin_first/shared/widgets/app_button.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:begin_first/shared/widgets/photo_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RecordCompleteScreen extends ConsumerStatefulWidget {
  const RecordCompleteScreen({required this.itemId, super.key});

  final String itemId;

  @override
  ConsumerState<RecordCompleteScreen> createState() => _RecordCompleteScreenState();
}

class _RecordCompleteScreenState extends ConsumerState<RecordCompleteScreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _attachLocation = false;
  bool _isSaving = false;
  bool _isLocating = false;
  LocationInfo? _location;

  @override
  void dispose() {
    _noteController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(recordDraftProvider);

    if (draft == null) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('补全记录'),
        ),
        child: SafeArea(
          child: DecoratedBox(
            decoration: AppDecorations.page,
            child: Column(
              children: [
                const Expanded(
                  child: EmptyState(
                    title: '没有可用草稿',
                    message: '请先拍照，再回来补充备注。',
                    icon: CupertinoIcons.photo,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: AppButton(
                    label: '返回物品详情',
                    onPressed: () => context.go('/items/${widget.itemId}'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('补全记录'),
      ),
      child: SafeArea(
        child: DecoratedBox(
          decoration: AppDecorations.page,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppCard(
                isEmphasized: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('补充线索（可选）', style: AppTextStyles.heading),
                    const SizedBox(height: AppSpacing.sm),
                    PhotoViewer(path: draft.tempPhotoPath, height: 200),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              CupertinoFormSection.insetGrouped(
                backgroundColor: const Color(0x00000000),
                header: const Text('详情'),
                children: [
                  CupertinoTextFormFieldRow(
                    controller: _noteController,
                    placeholder: '备注',
                  ),
                  CupertinoTextFormFieldRow(
                    controller: _tagsController,
                    placeholder: '标签（逗号分隔）',
                  ),
                ],
              ),
              CupertinoFormSection.insetGrouped(
                backgroundColor: const Color(0x00000000),
                header: const Text('位置'),
                children: [
                  CupertinoFormRow(
                    prefix: const Text('附加位置'),
                    child: CupertinoSwitch(
                      value: _attachLocation,
                      activeTrackColor: AppColors.primary,
                      onChanged: _isLocating ? null : _toggleLocation,
                    ),
                  ),
                  if (_attachLocation)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                        bottom: AppSpacing.md,
                      ),
                      child: _isLocating
                          ? const CupertinoActivityIndicator()
                          : Text(
                              _location == null
                                  ? '无法获取位置'
                                  : _location!.address ?? '${_location!.latitude}, ${_location!.longitude}',
                              style: AppTextStyles.bodyMuted,
                            ),
                    ),
                ],
              ),
              AppButton(
                label: _isSaving ? '保存中...' : '跳过补充，直接保存',
                leadingIcon: CupertinoIcons.forward,
                variant: AppButtonVariant.ghost,
                onPressed: _isSaving ? null : () => _saveRecord(draft, skipExtras: true),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: _isSaving ? '保存中...' : '保存记录',
                leadingIcon: CupertinoIcons.checkmark,
                onPressed: _isSaving ? null : () => _saveRecord(draft),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleLocation(bool value) async {
    setState(() {
      _attachLocation = value;
    });

    if (!value) {
      setState(() => _location = null);
      return;
    }

    setState(() => _isLocating = true);
    final location = await ref.read(locationServiceProvider).getCurrentLocation();
    if (mounted) {
      setState(() {
        _location = location;
        _isLocating = false;
      });
    }
  }

  Future<void> _saveRecord(RecordDraft draft, {bool skipExtras = false}) async {
    setState(() => _isSaving = true);
    final tags = skipExtras
        ? <String>[]
        : _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();

    await ref.read(recordActionsProvider).saveRecord(
          draft: draft,
          note: skipExtras || _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          tags: tags,
          location: skipExtras ? null : (_attachLocation ? _location : null),
        );

    ref.read(recordDraftProvider.notifier).state = null;
    if (!mounted) {
      return;
    }

    final session = ref.read(sceneRecordSessionProvider);
    if (session != null && session.sceneId == draft.sceneId && session.currentItemId == draft.itemId) {
      await _handleSceneSession(session);
      return;
    }

    setState(() => _isSaving = false);
    context.go('/items/${widget.itemId}');
  }

  Future<void> _handleSceneSession(SceneRecordSession session) async {
    if (session.hasNext) {
      final goNext = await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('继续'),
          content: const Text('继续记录该场景的下一件物品？'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('结束'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('下一件'),
            ),
          ],
        ),
      );

      if (!mounted) {
        return;
      }

      if (goNext == true) {
        final nextItemId = ref.read(sceneRecordSessionProvider.notifier).advance();
        setState(() => _isSaving = false);
        if (nextItemId == null) {
          ref.read(sceneRecordSessionProvider.notifier).end();
          context.go('/scenes/${session.sceneId}');
        } else {
          context.go('/items/$nextItemId/record?sceneId=${session.sceneId}');
        }
        return;
      }
    }

    ref.read(sceneRecordSessionProvider.notifier).end();
    setState(() => _isSaving = false);
    context.go('/scenes/${session.sceneId}');
  }
}
