import 'package:begin_first/core/utils/date_formatter.dart';

extension DateTimeExt on DateTime {
  String get shortDate => DateFormatter.shortDate(this);
  String get shortTime => DateFormatter.shortTime(this);
  String get fullDateTime => DateFormatter.fullDateTime(this);
}
