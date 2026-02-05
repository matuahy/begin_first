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
            color: CupertinoColors.black.withOpacity(0.2),
            child: const Center(
              child: CupertinoActivityIndicator(),
            ),
          ),
        ),
      ],
    );
  }
}
