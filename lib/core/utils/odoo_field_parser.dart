/// Helpers for parsing Odoo JSON-RPC field shapes into Dart types.
class OdooFieldParser {
  OdooFieldParser._();

  static String? asString(dynamic value) {
    if (value == null || value == false) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? asInt(dynamic value) {
    if (value == null || value == false) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is List && value.isNotEmpty) {
      return asInt(value.first);
    }
    return int.tryParse(value.toString());
  }

  static double? asDouble(dynamic value) {
    if (value == null || value == false) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static bool asBool(dynamic value, {bool fallback = false}) {
    if (value == null || value == false) return fallback;
    if (value is bool) return value;
    return fallback;
  }

  /// Many2one fields arrive as `[id, name]` or `false`.
  static ({int id, String name})? asMany2One(dynamic value) {
    if (value == null || value == false) return null;
    if (value is List && value.length >= 2) {
      final id = asInt(value[0]);
      final name = asString(value[1]);
      if (id == null || name == null) return null;
      return (id: id, name: name);
    }
    return null;
  }

  static List<int> asIdList(dynamic value) {
    if (value == null || value == false) return const [];
    if (value is! List) return const [];
    return value.map(asInt).whereType<int>().toList();
  }

  static DateTime? asDateTime(dynamic value) {
    final text = asString(value);
    if (text == null) return null;
    final normalized = text.contains('T')
        ? text
        : text.replaceFirst(' ', 'T');
    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) return null;
    // Odoo stores naive datetimes in UTC; treat missing offset as UTC.
    if (parsed.isUtc) return parsed;
    return DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    );
  }
}
