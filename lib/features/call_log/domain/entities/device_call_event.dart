/// A call entry read from the device call log (Android).
class DeviceCallEvent {
  const DeviceCallEvent({
    required this.at,
    required this.duration,
    required this.status,
    required this.isOutbound,
    required this.isInbound,
  });

  /// Device call timestamp (local wall-clock).
  final DateTime at;

  /// Duration as `MM:SS`.
  final String duration;

  /// Mapped Call Status key.
  final String status;

  final bool isOutbound;
  final bool isInbound;
}
