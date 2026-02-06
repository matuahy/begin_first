import 'package:begin_first/app/theme.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:flutter/cupertino.dart';

class ChecklistItem extends StatelessWidget {
  const ChecklistItem({
    required this.title,
    required this.isChecked,
    required this.onChanged,
    super.key,
  });

  final String title;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => onChanged(!isChecked),
      child: Row(
        children: [
          Icon(
            isChecked ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.circle,
            size: 22,
            color: isChecked ? AppColors.success : AppColors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(
                color: isChecked ? AppColors.textSecondary : AppColors.textPrimary,
                decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),
          CupertinoSwitch(value: isChecked, onChanged: onChanged),
        ],
      ),
    );
  }
}
