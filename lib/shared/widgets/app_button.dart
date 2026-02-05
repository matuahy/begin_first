import 'package:begin_first/app/theme.dart';
import 'package:flutter/cupertino.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.isDestructive = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: isDestructive ? AppColors.error : AppColors.primary,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
