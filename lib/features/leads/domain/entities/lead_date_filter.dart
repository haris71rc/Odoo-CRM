/// Preset create-date filters for the leads list.
enum LeadDateFilter {
  today,
  thisWeek,
  thisMonth,
  thisQuarter,
  thisYear,
  custom,
}

extension LeadDateFilterLabel on LeadDateFilter {
  String get label {
    switch (this) {
      case LeadDateFilter.today:
        return 'Today';
      case LeadDateFilter.thisWeek:
        return 'This Week';
      case LeadDateFilter.thisMonth:
        return 'This Month';
      case LeadDateFilter.thisQuarter:
        return 'This Quarter';
      case LeadDateFilter.thisYear:
        return 'This Year';
      case LeadDateFilter.custom:
        return 'Custom Range';
    }
  }
}
