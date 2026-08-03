import 'package:intl/intl.dart';

class DateFormatters {
  DateFormatters._();

  static final DateFormat displayDate = DateFormat('dd MMM yyyy');
  static final DateFormat displayDateTime = DateFormat('dd MMM yyyy, HH:mm');
  static final DateFormat apiDate = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String formatDate(DateTime? date) {
    if (date == null) return '—';
    return displayDate.format(date.toLocal());
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '—';
    return displayDateTime.format(date.toLocal());
  }

  static String toApiDate(DateTime date) => apiDate.format(date);
}
