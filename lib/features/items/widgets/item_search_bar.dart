import 'package:begin_first/app/theme.dart';
import 'package:flutter/cupertino.dart';

class ItemSearchBar extends StatelessWidget {
  const ItemSearchBar({this.onChanged, this.placeholder = '搜索物品', super.key});

  final ValueChanged<String>? onChanged;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      onChanged: onChanged,
      placeholder: placeholder,
      backgroundColor: AppColors.secondaryBackground,
      style: AppTextStyles.body,
      placeholderStyle: AppTextStyles.bodyMuted,
      borderRadius: BorderRadius.circular(AppRadius.md),
      itemColor: AppColors.textSecondary,
      itemSize: 20,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
    );
  }
}
