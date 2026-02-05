import 'package:begin_first/shared/widgets/app_card.dart';
import 'package:flutter/cupertino.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({required this.title, required this.value, super.key});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
