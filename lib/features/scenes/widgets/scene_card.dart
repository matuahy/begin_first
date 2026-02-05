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
          Text(title, style: const TextStyle(fontSize: 16)),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(color: CupertinoColors.secondaryLabel),
            ),
        ],
      ),
    );
  }
}
