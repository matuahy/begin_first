import 'package:begin_first/app/theme.dart';
import 'package:flutter/cupertino.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    required this.isLoading,
    required this.child,
    super.key,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Container(
            color: const Color(0x66000000),
            child: const Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: CupertinoActivityIndicator(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
