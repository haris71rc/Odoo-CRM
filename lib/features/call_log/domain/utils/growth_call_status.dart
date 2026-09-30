/// Odoo "Result call" values accepted by the Growth `/calls/log` API.
///
/// Device auto-sync only produces [picked] / [dnp]. Positive / Negative /
/// Wrong number are pass-through when already set (e.g. manual UI).
abstract final class GrowthCallStatus {
  static const positive = 'positive';
  static const negative = 'negative';
  static const wrongNumber = 'wrong_number';
  static const picked = 'picked';
  static const dnp = 'dnp';

  static const allowed = {
    positive,
    negative,
    wrongNumber,
    picked,
    dnp,
  };

  /// Maps legacy / device statuses onto the Result-call set.
  ///
  /// Unrecognized values fall back to [picked] when [durationSeconds] > 0,
  /// otherwise [dnp].
  static String normalize(String? status, {int durationSeconds = 0}) {
    final n = (status ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    if (n == positive) return positive;
    if (n == negative) return negative;
    if (n == wrongNumber || n == 'wrongnumber') return wrongNumber;

    if (n == picked ||
        n == 'answered' ||
        n == 'connected' ||
        n == 'completed') {
      return picked;
    }

    if (n == dnp ||
        n == 'not_picked' ||
        n == 'notpicked' ||
        n == 'missed' ||
        n == 'busy' ||
        n == 'hanged_up' ||
        n == 'hangedup' ||
        n == 'call_failed' ||
        n == 'callfailed' ||
        n == 'rejected' ||
        n == 'failed' ||
        n == 'unknown') {
      return dnp;
    }

    if (allowed.contains(n)) return n;
    return durationSeconds > 0 ? picked : dnp;
  }

  /// Preference rank when merging duplicate outbox rows (higher wins).
  static int rank(String status) {
    switch (normalize(status)) {
      case positive:
        return 4;
      case negative:
      case wrongNumber:
        return 3;
      case picked:
        return 2;
      case dnp:
      default:
        return 1;
    }
  }
}
