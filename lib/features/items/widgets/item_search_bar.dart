import 'package:flutter/cupertino.dart';

class ItemSearchBar extends StatelessWidget {
  const ItemSearchBar({this.onChanged, this.placeholder = '搜索物品', super.key});

  final ValueChanged<String>? onChanged;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      onChanged: onChanged,
      placeholder: placeholder,
    );
  }
}
