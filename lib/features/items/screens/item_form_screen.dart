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
          navigationBar: CupertinoNavigationBar(middle: Text('Edit Item')),
          child: Center(child: CupertinoActivityIndicator()),
        );
      }
      if (itemsAsync.hasError) {
        return CupertinoPageScaffold(
          navigationBar: const CupertinoNavigationBar(middle: Text('Edit Item')),
          child: Center(child: Text('Failed to load item: ${itemsAsync.error}')),
        );
      }
      if (item == null) {
        return const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('Edit Item')),
          child: Center(child: Text('Item not found')),
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
        middle: Text(isEditing ? 'Edit Item' : 'New Item'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isSaving ? null : () => _save(itemId: widget.itemId),
          child: const Text('Save'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('Item Info'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _nameController,
                  placeholder: 'Name',
                ),
                CupertinoFormRow(
                  prefix: const Text('Category'),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _selectCategory,
                    child: Text(_categoryLabel(_category)),
                  ),
                ),
                CupertinoFormRow(
                  prefix: const Text('Importance'),
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
    final validation = Validators.requiredText(_nameController.text, message: 'Name required');
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
          title: const Text('Category'),
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
            child: const Text('Cancel'),
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
          title: const Text('Importance'),
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
            child: const Text('Cancel'),
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
        return 'Keys';
      case Category.cards:
        return 'Cards';
      case Category.digital:
        return 'Digital';
      case Category.documents:
        return 'Documents';
      case Category.daily:
        return 'Daily';
      case Category.other:
        return 'Other';
    }
  }

  String _importanceLabel(Importance importance) {
    switch (importance) {
      case Importance.high:
        return 'High';
      case Importance.medium:
        return 'Medium';
      case Importance.low:
        return 'Low';
    }
  }
}
