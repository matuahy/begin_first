import 'package:begin_first/app/theme.dart';
import 'package:flutter/cupertino.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.placeholder,
    this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    super.key,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      padding: const EdgeInsets.all(AppSpacing.md),
    );
  }
}
