import 'package:begin_first/app/theme.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:flutter/cupertino.dart';

class ItemListTile extends StatelessWidget {
  const ItemListTile({
    required this.title,
    this.subtitle,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodyMuted,
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: AppColors.textTertiary,
            ),
        ],
      ),
    );
  }
}
