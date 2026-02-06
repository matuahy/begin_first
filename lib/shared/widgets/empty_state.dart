import 'package:begin_first/app/theme.dart';
import 'package:begin_first/shared/widgets/app_button.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:flutter/cupertino.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    this.title = '还没有内容',
    this.icon = CupertinoIcons.tray,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    super.key,
  });

  final String message;
  final String title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppCard(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.md : AppSpacing.lg,
          vertical: compact ? AppSpacing.md : AppSpacing.lg,
        ),
        color: AppColors.secondaryBackground,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 48 : 58,
              height: compact ? 48 : 58,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: AppColors.primaryStrong, size: compact ? 22 : 26),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTextStyles.heading, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.secondary,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
