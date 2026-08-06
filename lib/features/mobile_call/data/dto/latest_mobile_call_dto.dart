/// Machine-readable payload embedded inside a MOBILE_CALL log note.
class LatestMobileCallDto {
  const LatestMobileCallDto({
    required this.status,
    required this.duration,
    required this.direction,
    required this.phone,
    required this.timestamp,
    this.source,
    this.type,
    this.userId,
  });

  final String status;
  final int duration;
  final String direction;
  final String phone;
  final String timestamp;
  final String? source;
  final String? type;
  final int? userId;

  factory LatestMobileCallDto.fromJson(Map<String, dynamic> json) {
    return LatestMobileCallDto(
      status: json['status']?.toString() ?? '',
      duration: _asInt(json['duration']),
      direction: json['direction']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      source: json['source']?.toString(),
      type: json['type']?.toString(),
      userId: _asNullableInt(json['user_id'] ?? json['userId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source ?? 'mobile_app',
      'type': type ?? 'call',
      'status': status,
      'duration': duration,
      'direction': direction,
      'phone': phone,
      'timestamp': timestamp,
      if (userId != null) 'user_id': userId,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
