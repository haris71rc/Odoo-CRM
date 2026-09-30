/// When a CRM dial may read the Android call log.
///
/// Reading and giving up happen only while the app is in the foreground.
/// Time spent in the Phone app does not expire the pending dial.
class OutboundDialSyncPolicy {
  OutboundDialSyncPolicy._();

  /// Ignore the resume flicker right after the dialer opens.
  static const launchSettle = Duration(seconds: 3);

  /// Foreground lookups with no dialer row before offering a manual outcome.
  static const maxForegroundMisses = 10;

  /// Foreground lookups that still see duration 0 before saving a DNP row.
  static const maxZeroDurationChecks = 4;

  /// How long a saved `00:00` row keeps watching for a late duration.
  static const durationWatch = Duration(minutes: 20);

  static const missRetry = Duration(seconds: 1);
  static const zeroRetry = Duration(seconds: 2);

  static bool shouldDefer(DateTime dialedAt, DateTime now) {
    return now.difference(dialedAt) < launchSettle;
  }

  static bool shouldKeepWatchingDuration(DateTime dialedAt, DateTime now) {
    return now.difference(dialedAt) < durationWatch;
  }
}
