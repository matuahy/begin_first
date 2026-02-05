import 'package:flutter/cupertino.dart';

class ItemSearchBar extends StatelessWidget {
  const ItemSearchBar({this.onChanged, super.key});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      onChanged: onChanged,
    );
  }
}
