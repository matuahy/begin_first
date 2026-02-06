import 'package:begin_first/app/theme.dart';
import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:flutter/cupertino.dart';

/// iOS风格的操作卡片按钮
/// 包含图标、标题和副标题，适用于详情页的快捷操作
class ActionButtonCard extends StatelessWidget {
  const ActionButtonCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    super.key,
  });

  /// 卡片图标
  final IconData icon;

  /// 主标题
  final String title;

  /// 副标题（引导性文案）
  final String? subtitle;

  /// 点击回调
  final VoidCallback? onTap;

  /// 图标颜色，默认为主题色
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTextStyles.body),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTextStyles.bodyMuted,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// 水平方向的操作卡片按钮组
/// 用于在一行内展示多个操作卡片
class ActionButtonCardRow extends StatelessWidget {
  const ActionButtonCardRow({
    required this.children,
    super.key,
  });

  final List<ActionButtonCard> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < children.length; index++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : AppSpacing.sm / 2,
                right: index == children.length - 1 ? 0 : AppSpacing.sm / 2,
              ),
              child: children[index],
            ),
          ),
      ],
    );
  }
}
