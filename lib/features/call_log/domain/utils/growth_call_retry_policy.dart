/// Classifies Growth call-log POST failures for the durable retry outbox.
///
/// Retryable = temporary (network / 5xx / rate-limit / timeout).
/// Non-retryable = client/permanent errors that should not spin forever.
class GrowthCallRetryPolicy {
  GrowthCallRetryPolicy._();

  /// HTTP statuses that warrant persisting and retrying later.
  static const retryableStatusCodes = <int>{
    408, // Request Timeout
    429, // Too Many Requests
    500, // Internal Server Error
    502, // Bad Gateway
    503, // Service Unavailable
    504, // Gateway Timeout
  };

  /// Client/permanent errors — dead-letter, do not queue for endless retry.
  static const nonRetryableStatusCodes = <int>{
    400, // Bad Request
    403, // Forbidden
    404, // Not Found
    405, // Method Not Allowed
    409, // Conflict
    422, // Unprocessable Entity
  };

  /// True when an HTTP status should stay in the outbox and be retried.
  static bool isRetryableStatus(int? statusCode) {
    if (statusCode == null) return false;
    return retryableStatusCodes.contains(statusCode);
  }

  /// True when the failure is a global outage — stop draining remaining items.
  static bool isGlobalTransientStatus(int? statusCode) {
    return statusCode == 502 || statusCode == 503 || statusCode == 504;
  }

  /// Exponential backoff delay for attempt [attempts] (1-based).
  static Duration backoffDelay(int attempts) {
    final capped = attempts.clamp(1, 8);
    return Duration(seconds: (1 << (capped - 1)).clamp(1, 60));
  }
}
