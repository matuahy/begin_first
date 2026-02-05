import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _date = DateFormat('yyyy-MM-dd');
  static final DateFormat _time = DateFormat('HH:mm');
  static final DateFormat _dateTime = DateFormat('yyyy-MM-dd HH:mm');

  static String shortDate(DateTime date) => _date.format(date);
  static String shortTime(DateTime date) => _time.format(date);
  static String fullDateTime(DateTime date) => _dateTime.format(date);
}
