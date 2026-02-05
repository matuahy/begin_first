import 'package:begin_first/app/theme.dart';
import 'package:flutter/cupertino.dart';

enum AppButtonVariant { primary, secondary, ghost, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.variant,
    this.expand = true,
    this.padding,
    this.isDestructive = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final AppButtonVariant? variant;
  final bool expand;
  final EdgeInsetsGeometry? padding;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final resolvedVariant = variant ?? (isDestructive ? AppButtonVariant.destructive : AppButtonVariant.primary);
    final disabled = onPressed == null;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      pressedOpacity: 0.92,
      onPressed: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: expand ? double.infinity : null,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 13),
        decoration: _decoration(resolvedVariant, disabled),
        child: DefaultTextStyle(
          style: AppTextStyles.body.copyWith(color: _foregroundColor(resolvedVariant, disabled)),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 18, color: _foregroundColor(resolvedVariant, disabled)),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label),
              if (trailingIcon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(trailingIcon, size: 18, color: _foregroundColor(resolvedVariant, disabled)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _decoration(AppButtonVariant variant, bool disabled) {
    final borderRadius = BorderRadius.circular(AppRadius.md);
    if (disabled) {
      return BoxDecoration(
        color: AppColors.groupedBackground,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.border),
      );
    }
    switch (variant) {
      case AppButtonVariant.primary:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryStrong],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: borderRadius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F22695C),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: borderRadius,
          border: Border.all(color: const Color(0xFFBFDCD4)),
        );
      case AppButtonVariant.ghost:
        return BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: borderRadius,
          border: Border.all(color: AppColors.border),
        );
      case AppButtonVariant.destructive:
        return BoxDecoration(
          color: AppColors.error,
          borderRadius: borderRadius,
        );
    }
  }

  Color _foregroundColor(AppButtonVariant variant, bool disabled) {
    if (disabled) {
      return AppColors.textTertiary;
    }
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.destructive:
        return AppColors.textOnPrimary;
      case AppButtonVariant.secondary:
        return AppColors.primaryStrong;
      case AppButtonVariant.ghost:
        return AppColors.textPrimary;
    }
  }
}

/// 纯文字红色删除按钮，用于危险操作
class DestructiveTextButton extends StatelessWidget {
  const DestructiveTextButton({
    required this.label,
    this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: onPressed != null
              ? AppColors.error
              : AppColors.error.withOpacity(0.5),
        ),
      ),
    );
  }
}
