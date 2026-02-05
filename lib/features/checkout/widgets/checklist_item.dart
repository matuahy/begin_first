import 'package:flutter/cupertino.dart';

class ChecklistItem extends StatelessWidget {
  const ChecklistItem({
    required this.title,
    required this.isChecked,
    required this.onChanged,
    super.key,
  });

  final String title;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        CupertinoSwitch(value: isChecked, onChanged: onChanged),
      ],
    );
  }
}
