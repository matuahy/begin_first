import 'package:begin_first/app/theme.dart';
import 'package:begin_first/core/utils/validators.dart';
import 'package:begin_first/domain/models/enums/category.dart';
import 'package:begin_first/domain/models/enums/importance.dart';
import 'package:begin_first/features/items/providers/item_detail_provider.dart';
import 'package:begin_first/features/items/providers/items_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({this.itemId, super.key});

  final String? itemId;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  Category _category = Category.other;
  Importance _importance = Importance.medium;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemId != null;
    final itemsAsync = ref.watch(itemsStreamProvider);
    final item = widget.itemId == null ? null : ref.watch(itemDetailProvider(widget.itemId!));

    if (isEditing) {
      if (itemsAsync.isLoading) {
        return const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('编辑物品')),
          child: Center(child: CupertinoActivityIndicator()),
        );
      }
      if (itemsAsync.hasError) {
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(middle: Text('编辑物品')),
          child: Center(child: Text('加载物品失败：${itemsAsync.error}')),
        );
      }
      if (item == null) {
        return const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('编辑物品')),
          child: Center(child: Text('未找到物品')),
        );
      }
    }

    if (!_initialized && item != null) {
      _nameController.text = item.name;
      _category = item.category;
      _importance = item.importance;
      _initialized = true;
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(isEditing ? '编辑物品' : '新建物品'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isSaving ? null : () => _save(itemId: widget.itemId),
          child: const Text('保存'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('物品信息'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _nameController,
                  placeholder: '名称',
                ),
                CupertinoFormRow(
                  prefix: const Text('类别'),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _selectCategory,
                    child: Text(_categoryLabel(_category)),
                  ),
                ),
                CupertinoFormRow(
                  prefix: const Text('重要程度'),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _selectImportance,
                    child: Text(_importanceLabel(_importance)),
                  ),
                ),
              ],
            ),
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.md),
                child: Center(child: CupertinoActivityIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save({String? itemId}) async {
    final validation = Validators.requiredText(_nameController.text, message: '请填写名称');
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
    final actions = ref.read(itemActionsProvider);
    if (itemId == null) {
      await actions.createItem(
        name: _nameController.text.trim(),
        category: _category,
        importance: _importance,
      );
    } else {
      final item = ref.read(itemDetailProvider(itemId));
      if (item != null) {
        final updated = item.copyWith(
          name: _nameController.text.trim(),
          category: _category,
          importance: _importance,
          updatedAt: DateTime.now(),
        );
        await actions.updateItem(updated);
      }
    }

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _selectCategory() async {
    final result = await showCupertinoModalPopup<Category>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('选择类别'),
          actions: Category.values
              .map(
                (category) => CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop(category),
                  child: Text(_categoryLabel(category)),
                ),
              )
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        );
      },
    );

    if (result != null) {
      setState(() => _category = result);
    }
  }

  Future<void> _selectImportance() async {
    final result = await showCupertinoModalPopup<Importance>(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: const Text('选择重要程度'),
          actions: Importance.values
              .map(
                (importance) => CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(context).pop(importance),
                  child: Text(_importanceLabel(importance)),
                ),
              )
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        );
      },
    );

    if (result != null) {
      setState(() => _importance = result);
    }
  }

  String _categoryLabel(Category category) {
    switch (category) {
      case Category.keys:
        return '钥匙';
      case Category.cards:
        return '卡证';
      case Category.digital:
        return '数码';
      case Category.documents:
        return '证件文件';
      case Category.daily:
        return '日常用品';
      case Category.other:
        return '其他';
    }
  }

  String _importanceLabel(Importance importance) {
    switch (importance) {
      case Importance.high:
        return '高';
      case Importance.medium:
        return '中';
      case Importance.low:
        return '低';
    }
  }
}
