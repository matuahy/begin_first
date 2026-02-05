import 'package:begin_first/app/theme.dart';
import 'package:begin_first/core/utils/validators.dart';
import 'package:begin_first/domain/models/intent.dart' as app_intent;
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
    final intent = widget.intentId == null
        ? null
        : ref.watch(intentDetailProvider(widget.intentId!));

    if (isEditing) {
      if (intentsAsync.isLoading) {
        return const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('Edit Intent')),
          child: Center(child: CupertinoActivityIndicator()),
        );
      }
      if (intentsAsync.hasError) {
        return CupertinoPageScaffold(
          navigationBar:
              const CupertinoNavigationBar(middle: Text('Edit Intent')),
          child: Center(
              child: Text('Failed to load intent: ${intentsAsync.error}')),
        );
      }
      if (intent == null) {
        return const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('Edit Intent')),
          child: Center(child: Text('Intent not found')),
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
        middle: Text(isEditing ? 'Edit Intent' : 'New Intent'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isSaving ? null : () => _save(intent),
          child: const Text('Save'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('Intent'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _titleController,
                  placeholder: 'Title',
                ),
                CupertinoTextFormFieldRow(
                  controller: _nextStepController,
                  placeholder: 'Next step',
                ),
                CupertinoTextFormFieldRow(
                  controller: _tagsController,
                  placeholder: 'Tags (comma separated)',
                ),
                CupertinoFormRow(
                  prefix: const Text('Completed'),
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
                label: 'Delete Intent',
                isDestructive: true,
                onPressed: () => _confirmDelete(intent),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _save(app_intent.Intent? intent) async {
    final validation = Validators.requiredText(_titleController.text,
        message: 'Title required');
    if (validation != null) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Invalid'),
          content: Text(validation),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
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
        nextStep: _nextStepController.text.trim().isEmpty
            ? null
            : _nextStepController.text.trim(),
        tags: tags,
      );
    } else {
      final updated = intent.copyWith(
        title: _titleController.text.trim(),
        nextStep: _nextStepController.text.trim().isEmpty
            ? null
            : _nextStepController.text.trim(),
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

  Future<void> _confirmDelete(app_intent.Intent intent) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Intent'),
        content: const Text('This intent will be removed.'),
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
      await ref.read(intentActionsProvider).deleteIntent(intent.id);
      if (mounted) {
        context.pop();
      }
    }
  }
}
