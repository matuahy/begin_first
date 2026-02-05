import 'package:begin_first/app/theme.dart';
import 'package:flutter/cupertino.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    required this.title,
    required this.description,
    this.child,
    super.key,
  });

  final String title;
  final String description;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          Text(description, style: const TextStyle(fontSize: 16)),
          if (child != null) ...[
            const SizedBox(height: AppSpacing.lg),
            child!,
          ],
        ],
      ),
    );
  }
}
