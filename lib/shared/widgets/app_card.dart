import 'package:begin_first/app/theme.dart';
import 'package:flutter/cupertino.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    this.margin,
    this.isEmphasized = false,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final bool isEmphasized;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: padding,
      decoration: AppDecorations.card(
        emphasized: isEmphasized,
        color: color,
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      pressedOpacity: 0.94,
      onPressed: onTap,
      child: content,
    );
  }
}
