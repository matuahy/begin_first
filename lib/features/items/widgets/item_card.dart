import 'package:begin_first/app/theme.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:flutter/cupertino.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
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
    );
  }
}
