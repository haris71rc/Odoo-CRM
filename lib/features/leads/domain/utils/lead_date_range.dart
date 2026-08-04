import 'package:odoocrm/features/leads/domain/entities/lead_date_filter.dart';

/// Computes create-date bounds for Odoo domain filters.
class LeadDateRange {
  const LeadDateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  /// Returns null when [filter] is null (no date constraint).
  /// For [LeadDateFilter.custom], uses [customStart]/[customEnd] when both set.
  static LeadDateRange? resolve({
    required LeadDateFilter? filter,
    DateTime? customStart,
    DateTime? customEnd,
    DateTime? now,
  }) {
    if (filter == null) return null;

    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);

    switch (filter) {
      case LeadDateFilter.today:
        return LeadDateRange(
          start: today,
          end: _endOfDay(today),
        );
      case LeadDateFilter.thisWeek:
        final monday = today.subtract(Duration(days: today.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        return LeadDateRange(start: monday, end: _endOfDay(sunday));
      case LeadDateFilter.thisMonth:
        final start = DateTime(current.year, current.month, 1);
        final end = DateTime(current.year, current.month + 1, 0);
        return LeadDateRange(start: start, end: _endOfDay(end));
      case LeadDateFilter.thisQuarter:
        final quarterStartMonth = ((current.month - 1) ~/ 3) * 3 + 1;
        final start = DateTime(current.year, quarterStartMonth, 1);
        final end = DateTime(current.year, quarterStartMonth + 3, 0);
        return LeadDateRange(start: start, end: _endOfDay(end));
      case LeadDateFilter.thisYear:
        final start = DateTime(current.year, 1, 1);
        final end = DateTime(current.year, 12, 31);
        return LeadDateRange(start: start, end: _endOfDay(end));
      case LeadDateFilter.custom:
        if (customStart == null || customEnd == null) return null;
        final start = DateTime(
          customStart.year,
          customStart.month,
          customStart.day,
        );
        final end = DateTime(customEnd.year, customEnd.month, customEnd.day);
        return LeadDateRange(start: start, end: _endOfDay(end));
    }
  }

  static DateTime _endOfDay(DateTime day) =>
      DateTime(day.year, day.month, day.day, 23, 59, 59);
}
