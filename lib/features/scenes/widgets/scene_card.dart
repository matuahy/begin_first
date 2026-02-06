import 'package:begin_first/app/theme.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:flutter/cupertino.dart';

class SceneCard extends StatelessWidget {
  const SceneCard({
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
          Row(
            children: [
              const Icon(CupertinoIcons.square_grid_2x2, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(title, style: AppTextStyles.body)),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs, left: 26),
              child: Text(subtitle!, style: AppTextStyles.bodyMuted),
            ),
        ],
      ),
    );
  }
}
