import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:flutter/cupertino.dart';

class NudgeCard extends StatelessWidget {
  const NudgeCard({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
