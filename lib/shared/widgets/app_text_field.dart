import 'package:begin_first/app/theme.dart';
import 'package:flutter/cupertino.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.placeholder,
    this.onChanged,
    this.keyboardType,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    super.key,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 13),
      prefix: prefixIcon == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: Icon(prefixIcon, size: 18, color: AppColors.textSecondary),
            ),
      suffix: suffix == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: suffix,
            ),
      placeholderStyle: AppTextStyles.bodyMuted,
      style: AppTextStyles.body,
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
    );
  }
}
