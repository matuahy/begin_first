import 'package:flutter/cupertino.dart';

extension BuildContextExt on BuildContext {
  CupertinoThemeData get cupertinoTheme => CupertinoTheme.of(this);
  TextStyle get primaryTextStyle => cupertinoTheme.textTheme.textStyle;
}
