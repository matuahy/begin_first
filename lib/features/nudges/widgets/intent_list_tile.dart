import 'package:begin_first/app/theme.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:flutter/cupertino.dart';

class IntentListTile extends StatelessWidget {
  const IntentListTile({
    required this.title,
    this.subtitle,
    this.isCompleted = false,
    this.onTap,
    this.onCompletedChanged,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool isCompleted;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onCompletedChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(subtitle!, style: AppTextStyles.bodyMuted),
                  ),
              ],
            ),
          ),
          if (onCompletedChanged != null)
            CupertinoSwitch(
              value: isCompleted,
              onChanged: onCompletedChanged,
            ),
        ],
      ),
    );
  }
}
