import 'package:intl/intl.dart';

class DateFormatters {
  DateFormatters._();

  static final DateFormat displayDate = DateFormat('dd MMM yyyy');
  static final DateFormat displayDateTime = DateFormat('dd MMM yyyy, HH:mm');
  static final DateFormat apiDate = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _chatterDay = DateFormat('MMM d, yyyy');
  static final DateFormat _chatterTime = DateFormat('h:mm a');

  static String formatDate(DateTime? date) {
    if (date == null) return '—';
    return displayDate.format(date.toLocal());
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '—';
    return displayDateTime.format(date.toLocal());
  }

  /// Odoo web chatter group header: "Today", "Yesterday", or "Aug 3, 2026".
  static String formatChatterDateGroup(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(local.year, local.month, local.day);

    if (messageDay == today) return 'Today';
    if (messageDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return _chatterDay.format(local);
  }

  /// Odoo web chatter timestamp: "Today at 12:40 PM", "Yesterday at 2:42 PM".
  static String formatChatterDateTime(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();
    final time = _chatterTime.format(local);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(local.year, local.month, local.day);

    if (messageDay == today) return 'Today at $time';
    if (messageDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at $time';
    }
    if (local.year == now.year) {
      return '${_chatterDay.format(local)} at $time';
    }
    return '${displayDate.format(local)} at $time';
  }

  static String toApiDate(DateTime date) => apiDate.format(date);
}
