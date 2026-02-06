import 'package:begin_first/app/providers.dart';
import 'package:begin_first/app/theme.dart';
import 'package:begin_first/core/extensions/datetime_ext.dart';
import 'package:begin_first/domain/models/record.dart';
import 'package:begin_first/features/items/providers/item_detail_provider.dart';
import 'package:begin_first/features/records/providers/record_provider.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:begin_first/shared/widgets/app_button.dart';
import 'package:begin_first/shared/widgets/empty_state.dart';
import 'package:begin_first/shared/widgets/photo_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RecordDetailScreen extends ConsumerStatefulWidget {
  const RecordDetailScreen({required this.recordId, super.key});

  final String recordId;

  @override
  ConsumerState<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends ConsumerState<RecordDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordAsync = ref.watch(recordDetailProvider(widget.recordId));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('记录详情'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isSaving ? null : () => _save(recordAsync.valueOrNull),
          child: const Text('保存'),
        ),
      ),
      child: SafeArea(
        child: DecoratedBox(
          decoration: AppDecorations.page,
          child: recordAsync.when(
            data: (record) {
              if (record == null) {
                return const EmptyState(
                  title: '未找到记录',
                  message: '该记录可能已被删除。',
                  icon: CupertinoIcons.doc_text,
                );
              }

              if (!_initialized) {
                _noteController.text = record.note ?? '';
                _tagsController.text = record.tags.join(', ');
                _initialized = true;
              }

              final item = ref.watch(itemDetailProvider(record.itemId));
              final location = record.location;

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  AppCard(
                    isEmphasized: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PhotoViewer(path: record.photoPath, height: 220),
                        const SizedBox(height: AppSpacing.md),
                        Text(item?.name ?? '物品 ${record.itemId}', style: AppTextStyles.heading),
                        const SizedBox(height: AppSpacing.xs),
                        Text(record.timestamp.fullDateTime, style: AppTextStyles.bodyMuted),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CupertinoFormSection.insetGrouped(
                    backgroundColor: const Color(0x00000000),
                    header: const Text('备注'),
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
                  if (location != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: '打开位置',
                      leadingIcon: CupertinoIcons.location,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => ref.read(locationServiceProvider).openInMaps(
                            location.latitude,
                            location.longitude,
                            location.placeName,
                          ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: DestructiveTextButton(
                      label: '删除这条记录',
                      onPressed: () => _confirmDelete(record),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (error, stack) => EmptyState(
              title: '加载失败',
              message: '加载记录失败：$error',
              icon: CupertinoIcons.exclamationmark_triangle,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(Record? record) async {
    if (record == null) {
      return;
    }
    setState(() => _isSaving = true);
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    final updated = record.copyWith(
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      tags: tags,
    );
    await ref.read(recordActionsProvider).updateRecord(updated);
    if (mounted) {
      setState(() => _isSaving = false);
      context.pop();
    }
  }

  Future<void> _confirmDelete(Record record) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('删除记录'),
        content: const Text('该记录将被删除。'),
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
      await ref.read(recordActionsProvider).deleteRecord(record);
      if (mounted) {
        context.pop();
      }
    }
  }
}
