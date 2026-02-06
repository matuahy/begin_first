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
    return DecoratedBox(
      decoration: AppDecorations.page,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Text(description, style: AppTextStyles.bodyMuted),
            if (child != null) ...[
              const SizedBox(height: AppSpacing.lg),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}
