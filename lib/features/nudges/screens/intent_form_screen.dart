import 'package:begin_first/app/theme.dart';
import 'package:begin_first/core/utils/validators.dart';
import 'package:begin_first/domain/models/intent.dart';
import 'package:begin_first/features/nudges/providers/intents_provider.dart';
import 'package:begin_first/shared/widgets/app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class IntentFormScreen extends ConsumerStatefulWidget {
  const IntentFormScreen({this.intentId, super.key});

  final String? intentId;

  @override
  ConsumerState<IntentFormScreen> createState() => _IntentFormScreenState();
}

class _IntentFormScreenState extends ConsumerState<IntentFormScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _nextStepController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _isCompleted = false;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _nextStepController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.intentId != null;
    final intentsAsync = ref.watch(intentsStreamProvider);
    final intent = widget.intentId == null ? null : ref.watch(intentDetailProvider(widget.intentId!));

    if (isEditing) {
      if (intentsAsync.isLoading) {
        return const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('编辑意图')),
          child: Center(child: CupertinoActivityIndicator()),
        );
      }
      if (intentsAsync.hasError) {
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(middle: Text('编辑意图')),
          child: Center(child: Text('加载意图失败：${intentsAsync.error}')),
        );
      }
      if (intent == null) {
        return const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('编辑意图')),
          child: Center(child: Text('未找到意图')),
        );
      }
    }

    if (!_initialized && intent != null) {
      _titleController.text = intent.title;
      _nextStepController.text = intent.nextStep ?? '';
      _tagsController.text = intent.tags.join(', ');
      _isCompleted = intent.isCompleted;
      _initialized = true;
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(isEditing ? '编辑意图' : '新建意图'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isSaving ? null : () => _save(intent),
          child: const Text('保存'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('意图'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _titleController,
                  placeholder: '标题',
                ),
                CupertinoTextFormFieldRow(
                  controller: _nextStepController,
                  placeholder: '下一步',
                ),
                CupertinoTextFormFieldRow(
                  controller: _tagsController,
                  placeholder: '标签（逗号分隔）',
                ),
                CupertinoFormRow(
                  prefix: const Text('已完成'),
                  child: CupertinoSwitch(
                    value: _isCompleted,
                    onChanged: (value) => setState(() => _isCompleted = value),
                  ),
                ),
              ],
            ),
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.md),
                child: Center(child: CupertinoActivityIndicator()),
              ),
            if (intent != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: '删除意图',
                isDestructive: true,
                onPressed: () => _confirmDelete(intent),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _save(Intent? intent) async {
    final validation = Validators.requiredText(_titleController.text, message: '请填写标题');
    if (validation != null) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('提示'),
          content: Text(validation),
          actions: [
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    final actions = ref.read(intentActionsProvider);

    if (intent == null) {
      await actions.createIntent(
        title: _titleController.text.trim(),
        nextStep: _nextStepController.text.trim().isEmpty ? null : _nextStepController.text.trim(),
        tags: tags,
      );
    } else {
      final updated = intent.copyWith(
        title: _titleController.text.trim(),
        nextStep: _nextStepController.text.trim().isEmpty ? null : _nextStepController.text.trim(),
        tags: tags,
        isCompleted: _isCompleted,
        updatedAt: DateTime.now(),
      );
      await actions.updateIntent(updated);
    }

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _confirmDelete(Intent intent) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('删除意图'),
        content: const Text('该意图将被删除。'),
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
      await ref.read(intentActionsProvider).deleteIntent(intent.id);
      if (mounted) {
        context.pop();
      }
    }
  }
}
