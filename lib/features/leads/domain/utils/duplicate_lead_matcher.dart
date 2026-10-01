import 'package:odoocrm/core/utils/phone_number_utils.dart';
import 'package:odoocrm/features/leads/domain/entities/duplicate_lead_candidate.dart';

/// Marks leads that share a number with one the salesperson already called.
///
/// The earliest outbound call stays unmarked. Every other lead on that number
/// is a duplicate. Numbers are compared on their last 10 digits.
abstract final class DuplicateLeadMatcher {
  DuplicateLeadMatcher._();

  static Set<int> duplicateIds(Iterable<DuplicateLeadCandidate> leads) {
    final duplicates = <int>{};
    for (final group in _groups(leads).values) {
      if (group.length < 2) continue;
      final called = group.values.where((lead) => lead.wasCalled).toList()
        ..sort(_compareOriginal);
      if (called.isEmpty) continue;
      final originalId = called.first.id;
      for (final id in group.keys) {
        if (id != originalId) duplicates.add(id);
      }
    }
    return duplicates;
  }

  /// Lead ids that share a phone key with at least one other lead.
  static Set<int> idsSharingNumber(Iterable<DuplicateLeadCandidate> leads) {
    final shared = <int>{};
    for (final group in _groups(leads).values) {
      if (group.length < 2) continue;
      shared.addAll(group.keys);
    }
    return shared;
  }

  static Set<String> phoneKeys(String? phone, String? mobile) {
    final keys = <String>{};
    final phoneKey = keyOf(phone);
    final mobileKey = keyOf(mobile);
    if (phoneKey != null) keys.add(phoneKey);
    if (mobileKey != null) keys.add(mobileKey);
    return keys;
  }

  /// Last 10 digits, after stripping spaces, dashes, parentheses, and `+`.
  static String? keyOf(String? raw) {
    final normalized = PhoneNumberUtils.normalizeOrNull(raw);
    if (normalized == null) return null;
    if (normalized.length > 10) {
      return normalized.substring(normalized.length - 10);
    }
    return normalized;
  }

  static bool sharesAnyKey({
    String? phone,
    String? mobile,
    required Set<String> keys,
  }) {
    return phoneKeys(phone, mobile).any(keys.contains);
  }

  static Map<String, Map<int, DuplicateLeadCandidate>> _groups(
    Iterable<DuplicateLeadCandidate> leads,
  ) {
    final byKey = <String, Map<int, DuplicateLeadCandidate>>{};
    for (final lead in leads) {
      for (final key in phoneKeys(lead.phone, lead.mobile)) {
        byKey.putIfAbsent(key, () => {})[lead.id] = lead;
      }
    }
    return byKey;
  }

  /// Earliest outbound call, then earliest create date, then lowest id.
  static int _compareOriginal(
    DuplicateLeadCandidate a,
    DuplicateLeadCandidate b,
  ) {
    final byCall = _compareNullableDate(a.firstCallDate, b.firstCallDate);
    if (byCall != 0) return byCall;
    final byCreated = _compareNullableDate(a.createdDate, b.createdDate);
    if (byCreated != 0) return byCreated;
    return a.id.compareTo(b.id);
  }

  static int _compareNullableDate(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }
}
