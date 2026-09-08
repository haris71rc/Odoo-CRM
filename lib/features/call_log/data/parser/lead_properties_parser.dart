import 'package:intl/intl.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_status_option.dart';

/// Parsed snapshot of Odoo `lead_properties` for read-modify-write updates.
class LeadPropertiesSnapshot {
  const LeadPropertiesSnapshot({
    required this.raw,
    required this.callLog,
  });

  final dynamic raw;
  final CallLog callLog;
}

enum _CallLogField {
  firstCallDate,
  lastCallDate,
  status,
  totalDuration,
  totalInboundCalls,
  totalOutboundCalls,
  responseTimeMinutes,
}

/// Reads and writes Call Log fields inside Odoo `lead_properties`.
class LeadPropertiesParser {
  const LeadPropertiesParser();

  LeadPropertiesSnapshot parse(dynamic leadProperties) {
    final raw = _cloneRaw(leadProperties);
    return LeadPropertiesSnapshot(
      raw: raw,
      callLog: _extractCallLog(raw),
    );
  }

  /// Reads Call Status tag options from the lead property definition.
  List<CallStatusOption> parseCallStatusOptions(dynamic leadProperties) {
    final list = _asPropertyList(leadProperties);
    for (final item in list) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final label = _propertyLabel(map);
      final type = map['type']?.toString();
      if (type != 'tags' && !_matches(label, ['call status', 'call_status'])) {
        continue;
      }
      return _tagsToOptions(map['tags']);
    }
    return _defaultCallStatusOptions();
  }

  /// Maps a status hint (device / legacy key) to an Odoo tag key.
  String? resolveTagKey(
    List<CallStatusOption> options,
    String statusHint,
  ) {
    if (options.isEmpty) return statusHint;
    final tags = options
        .map((option) => [option.key, option.label, 0])
        .toList();
    return _resolveTagKey(tags, statusHint);
  }

  /// Patches call-log fields and returns the payload Odoo `web_save` expects.
  dynamic mergeCallLogForWrite(dynamic existing, CallLog callLog) {
    final working = _asPropertyList(existing);
    _applyCallLog(working, callLog);
    return _toWriteMap(working);
  }

  dynamic mergeCallLog(dynamic existing, CallLog callLog) {
    final working = _asPropertyList(existing);
    _applyCallLog(working, callLog);
    return working;
  }

  List<dynamic> _asPropertyList(dynamic raw) {
    if (raw is List) {
      return _cloneRaw(raw) as List<dynamic>;
    }
    if (raw is Map) {
      return _dictToPropertyList(raw);
    }
    return [];
  }

  List<dynamic> _dictToPropertyList(Map<dynamic, dynamic> map) {
    return map.entries
        .map(
          (e) => {
            'name': e.key.toString(),
            'value': e.value,
          },
        )
        .toList();
  }

  Map<String, dynamic> _toWriteMap(List<dynamic> list) {
    final map = <String, dynamic>{};
    for (final item in list) {
      if (item is! Map) continue;
      final property = Map<String, dynamic>.from(item);
      final name = property['name'];
      final type = property['type']?.toString();
      if (name == null || name.toString().isEmpty) continue;
      if (type == 'separator') continue;
      map[name.toString()] = property['value'];
    }
    return map;
  }

  CallLog _extractCallLog(dynamic raw) {
    if (raw == null || raw == false) return const CallLog();

    if (raw is Map) return _extractFromList(_dictToPropertyList(raw));
    if (raw is List) return _extractFromList(raw);
    return const CallLog();
  }

  CallLog _extractFromList(List<dynamic> list) {
    DateTime? firstDate;
    DateTime? lastDate;
    String? duration;
    String? totalDuration;
    String? status;
    int? inbound;
    int? outbound;
    double? responseTime;

    for (final item in list) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final label = _propertyLabel(map);
      final value = map['value'];
      final field = _resolveField(
        label,
        map['type']?.toString(),
        name: map['name']?.toString(),
      );

      switch (field) {
        case _CallLogField.firstCallDate:
          firstDate ??= _parseDateTime(value);
          break;
        case _CallLogField.lastCallDate:
          lastDate ??= _parseDateTime(value);
          break;
        case _CallLogField.totalDuration:
          totalDuration ??= _asString(value);
          break;
        case _CallLogField.status:
          status ??= _parseStatus(value);
          break;
        case _CallLogField.totalInboundCalls:
          inbound ??= _parseInt(value);
          break;
        case _CallLogField.totalOutboundCalls:
          outbound ??= _parseInt(value);
          break;
        case _CallLogField.responseTimeMinutes:
          responseTime ??= _parseDouble(value);
          break;
        case null:
          break;
      }
    }

    return CallLog(
      firstCallDate: firstDate,
      lastCallDate: lastDate,
      duration: duration,
      totalDuration: totalDuration,
      status: status,
      totalInboundCalls: inbound,
      totalOutboundCalls: outbound,
      responseTimeMinutes: responseTime,
    );
  }

  void _applyCallLog(List<dynamic> list, CallLog callLog) {
    final patched = <_CallLogField>{};

    for (final item in list) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final label = _propertyLabel(map);
      final type = map['type']?.toString();
      if (type == 'separator') continue;

      final field = _resolveField(label, type, name: map['name']?.toString());
      if (field == null) continue;

      final value = _valueForField(field, callLog, map);
      if (value == null) continue;

      map['value'] = value;
      _writeBackListItem(list, item, map);
      patched.add(field);
    }

    _appendMissingFields(list, callLog, patched);
  }

  void _appendMissingFields(
    List<dynamic> list,
    CallLog callLog,
    Set<_CallLogField> patched,
  ) {
    if (!patched.contains(_CallLogField.firstCallDate) &&
        callLog.firstCallDate != null) {
      list.add(_newListProperty(
        name: 'first_dt',
        label: 'Call Date & Time (First)',
        type: 'datetime',
        value: _formatOdooDateTime(callLog.firstCallDate!),
      ));
    }
    if (!patched.contains(_CallLogField.lastCallDate) &&
        callLog.lastCallDate != null) {
      list.add(_newListProperty(
        name: 'call_date_time_last',
        label: 'Call Date & Time (Last)',
        type: 'datetime',
        value: _formatOdooDateTime(callLog.lastCallDate!),
      ));
    }
    if (!patched.contains(_CallLogField.totalDuration) &&
        callLog.totalDuration != null) {
      list.add(_newListProperty(
        name: 'total_call_duration',
        label: 'Total Call Duration',
        type: 'char',
        value: callLog.totalDuration,
      ));
    }
    if (!patched.contains(_CallLogField.status) && callLog.status != null) {
      list.add(_newListProperty(
        name: 'call_status',
        label: 'Call Status',
        type: 'tags',
        value: _formatTagsValue(
          property: {'tags': _defaultTagOptions()},
          status: callLog.status!,
        ),
      ));
    }
    if (!patched.contains(_CallLogField.totalInboundCalls) &&
        callLog.totalInboundCalls != null) {
      list.add(_newListProperty(
        name: 'inbound',
        label: 'Total InBound Calls',
        type: 'integer',
        value: callLog.totalInboundCalls,
      ));
    }
    if (!patched.contains(_CallLogField.totalOutboundCalls) &&
        callLog.totalOutboundCalls != null) {
      list.add(_newListProperty(
        name: 'outbound',
        label: 'Total Outbound Call',
        type: 'integer',
        value: callLog.totalOutboundCalls,
      ));
    }
    if (!patched.contains(_CallLogField.responseTimeMinutes) &&
        callLog.responseTimeMinutes != null) {
      list.add(_newListProperty(
        name: 'response',
        label: 'Response Time (Minutes)',
        type: 'float',
        value: callLog.responseTimeMinutes,
      ));
    }
  }

  dynamic _valueForField(
    _CallLogField field,
    CallLog callLog,
    Map<String, dynamic> property,
  ) {
    switch (field) {
      case _CallLogField.firstCallDate:
        return callLog.firstCallDate != null
            ? _formatOdooDateTime(callLog.firstCallDate!)
            : null;
      case _CallLogField.lastCallDate:
        return callLog.lastCallDate != null
            ? _formatOdooDateTime(callLog.lastCallDate!)
            : null;
      case _CallLogField.totalDuration:
        final total = callLog.totalDuration ?? callLog.duration;
        return total;
      case _CallLogField.status:
        return callLog.status != null
            ? _formatTagsValue(property: property, status: callLog.status!)
            : null;
      case _CallLogField.totalInboundCalls:
        return callLog.totalInboundCalls;
      case _CallLogField.totalOutboundCalls:
        return callLog.totalOutboundCalls;
      case _CallLogField.responseTimeMinutes:
        return callLog.responseTimeMinutes != null
            ? double.parse(callLog.responseTimeMinutes!.toStringAsFixed(2))
            : null;
    }
  }

  _CallLogField? _resolveField(String label, String? type, {String? name}) {
    final fromName = _resolveFieldFromName(name);
    if (fromName != null) return fromName;

    final normalized = label.toLowerCase();

    if (_isFirstCallDateLabel(normalized)) {
      return _CallLogField.firstCallDate;
    }
    if (_isLastCallDateLabel(normalized)) {
      return _CallLogField.lastCallDate;
    }
    if (_matches(normalized, ['call status', 'call_status'])) {
      return _CallLogField.status;
    }
    if (type == 'tags') return _CallLogField.status;
    if (_matches(normalized, ['total call duration', 'total_call_duration'])) {
      return _CallLogField.totalDuration;
    }
    if (_matches(normalized, [
      'total inbound calls',
      'total inbound call',
      'total_inbound_calls',
      'total inbound',
    ])) {
      return _CallLogField.totalInboundCalls;
    }
    if (_matches(normalized, [
      'total outbound call',
      'total outbound calls',
      'total_outbound_calls',
      'total outbound',
    ])) {
      return _CallLogField.totalOutboundCalls;
    }
    if (_matches(normalized, [
      'response time (minutes)',
      'response time minutes',
      'response_time_minutes',
      'response time',
    ])) {
      return _CallLogField.responseTimeMinutes;
    }

    return null;
  }

  _CallLogField? _resolveFieldFromName(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final compact = name.toLowerCase().replaceAll(RegExp(r'[\s_()-]+'), '');
    if (compact.isEmpty) return null;

    if (compact == 'firstdt' ||
        compact == 'calldatetimefirst' ||
        compact == 'firstcall' ||
        (compact.contains('first') &&
            (compact.contains('dt') || compact.contains('date')))) {
      return _CallLogField.firstCallDate;
    }
    if (compact == 'lastdt' ||
        compact == 'calldatetimelast' ||
        compact == 'lastcall' ||
        (compact.contains('last') &&
            (compact.contains('dt') ||
                compact.contains('date') ||
                compact.contains('call')))) {
      return _CallLogField.lastCallDate;
    }
    if (compact == 'inbound' ||
        compact == 'totalinbound' ||
        compact == 'totalinboundcall' ||
        compact == 'totalinboundcalls') {
      return _CallLogField.totalInboundCalls;
    }
    if (compact == 'outbound' ||
        compact == 'totaloutbound' ||
        compact == 'totaloutboundcall' ||
        compact == 'totaloutboundcalls') {
      return _CallLogField.totalOutboundCalls;
    }
    if (compact == 'response' || compact.contains('responsetime')) {
      return _CallLogField.responseTimeMinutes;
    }
    if (compact == 'totalcallduration' ||
        compact == 'callduration' ||
        compact == 'totalduration') {
      return _CallLogField.totalDuration;
    }
    if (compact == 'callstatus') {
      return _CallLogField.status;
    }
    return null;
  }

  bool _isFirstCallDateLabel(String label) {
    return label.contains('first') &&
        label.contains('call') &&
        label.contains('date');
  }

  bool _isLastCallDateLabel(String label) {
    if (label.contains('last') &&
        label.contains('call') &&
        label.contains('date')) {
      return true;
    }
    // Legacy single field without First/Last suffix → last call date.
    if (label.contains('first')) return false;
    return _matches(label, [
      'call date & time',
      'call date and time',
      'call_date_time',
      'calldatetime',
    ]);
  }

  bool _matches(String label, List<String> needles) {
    final normalized = label.replaceAll(RegExp(r'[\s_()-]+'), '');
    for (final needle in needles) {
      final n = needle.toLowerCase().replaceAll(RegExp(r'[\s_()-]+'), '');
      if (normalized == n || normalized.contains(n) || n.contains(normalized)) {
        return true;
      }
    }
    return false;
  }

  Map<String, dynamic> _newListProperty({
    required String name,
    required String label,
    required String type,
    required dynamic value,
  }) {
    return {
      'name': name,
      'string': label,
      'type': type,
      'value': value,
    };
  }

  void _writeBackListItem(
    List<dynamic> list,
    dynamic original,
    Map<String, dynamic> updated,
  ) {
    final index = list.indexOf(original);
    if (index >= 0) list[index] = updated;
  }

  String _propertyLabel(Map<String, dynamic> map) {
    for (final candidate in [map['string'], map['name'], map['label']]) {
      final text = _asString(candidate);
      if (text != null && text.isNotEmpty) return text.toLowerCase();
    }
    return '';
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null || value == false) return null;
    return _parseLocalDateTime(value);
  }

  DateTime? _parseLocalDateTime(dynamic value) {
    final text = _asString(value);
    if (text == null) return null;
    final normalized = text.contains('T') ? text : text.replaceFirst(' ', 'T');
    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) return null;
    if (!parsed.isUtc) return parsed;
    return parsed.toLocal();
  }

  int? _parseInt(dynamic value) {
    if (value == null || value == false) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _parseDouble(dynamic value) {
    if (value == null || value == false) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  String? _parseStatus(dynamic value) {
    if (value == null || value == false) return null;

    if (value is List) {
      if (value.isEmpty) return null;
      final first = value.first;
      if (first is List && first.isNotEmpty) {
        return _normalizeStatus(first.first);
      }
      return _normalizeStatus(first);
    }

    if (value is Map) {
      final nested = value['value'] ?? value['name'] ?? value['id'];
      return _normalizeStatus(nested);
    }

    return _normalizeStatus(value);
  }

  dynamic _formatTagsValue({
    required Map<String, dynamic> property,
    required String status,
  }) {
    final resolved = _resolveTagKey(property['tags'], status) ?? status;
    return [resolved];
  }

  String? _normalizeStatus(dynamic value) {
    final text = _asString(value);
    if (text == null || text.isEmpty) return null;
    return text.toLowerCase().replaceAll(' ', '_');
  }

  String? _resolveTagKey(dynamic tagsDefinition, String status) {
    final normalizedStatus = status.toLowerCase().replaceAll(' ', '_');
    final definedKeys = _definedTagKeys(tagsDefinition);

    if (definedKeys.isEmpty) return normalizedStatus;

    for (final key in definedKeys) {
      if (key.toLowerCase().replaceAll(' ', '_') == normalizedStatus) {
        return key;
      }
    }

    if (tagsDefinition is List) {
      for (final tag in tagsDefinition) {
        if (tag is! List || tag.isEmpty) continue;
        final key = tag.first.toString();
        final label = tag.length > 1
            ? tag[1].toString().toLowerCase().replaceAll(' ', '_')
            : '';
        if (label == normalizedStatus || label.contains(normalizedStatus)) {
          return key;
        }
      }
    }

    const unanswered = {
      'not_picked',
      'dnp',
      'busy',
      'missed',
      'rejected',
      'failed',
      'call_failed',
      'hanged_up',
      'no_answer',
    };
    if (unanswered.contains(normalizedStatus)) {
      for (final candidate in [
        'dnp',
        'not_picked',
        'notpicked',
        'no_answer',
        'missed',
        'busy',
        'hanged_up',
        'hangedup',
        'rejected',
        'failed',
        'call_failed',
      ]) {
        for (final key in definedKeys) {
          final n = key.toLowerCase().replaceAll(' ', '_');
          if (n == candidate) return key;
        }
      }
      // Match tag labels such as "Call Failed" or "Hanged Up".
      if (tagsDefinition is List) {
        for (final tag in tagsDefinition) {
          if (tag is! List || tag.length < 2) continue;
          final label = tag[1].toString().toLowerCase();
          if (normalizedStatus.contains('fail') && label.contains('fail')) {
            return tag.first.toString();
          }
          if (normalizedStatus.contains('hang') && label.contains('hang')) {
            return tag.first.toString();
          }
          if ((normalizedStatus == 'dnp' || normalizedStatus.contains('not')) &&
              label.contains('dnp')) {
            return tag.first.toString();
          }
        }
      }
    }

    if (normalizedStatus == 'picked' || normalizedStatus == 'answered') {
      for (final key in definedKeys) {
        final n = key.toLowerCase();
        if (n.contains('pick') && !n.contains('not')) return key;
      }
      for (final key in definedKeys) {
        final n = key.toLowerCase();
        if (n.contains('answer') || n.contains('connect')) return key;
      }
      // Prefer leaving the device hint intact over inventing the first tag
      // (often DNP), which would block Connected promotion.
      return normalizedStatus;
    }

    // Unknown hint — keep it; do not fall back to the first defined tag.
    return normalizedStatus;
  }

  List<String> _definedTagKeys(dynamic tagsDefinition) {
    if (tagsDefinition is! List) return const [];
    final keys = <String>[];
    for (final tag in tagsDefinition) {
      if (tag is List && tag.isNotEmpty) {
        keys.add(tag.first.toString());
      } else if (tag is String && tag.isNotEmpty) {
        keys.add(tag);
      }
    }
    return keys;
  }

  List<List<dynamic>> _defaultTagOptions() {
    return _defaultCallStatusOptions()
        .map((option) => [option.key, option.label, 0])
        .toList();
  }

  List<CallStatusOption> _defaultCallStatusOptions() {
    return const [
      CallStatusOption(key: 'picked', label: 'Picked'),
      CallStatusOption(key: 'dnp', label: 'DNP'),
      CallStatusOption(key: 'busy', label: 'Busy'),
      CallStatusOption(key: 'hanged_up', label: 'Hanged Up'),
      CallStatusOption(key: 'missed', label: 'Missed'),
      CallStatusOption(key: 'call_failed', label: 'Call Failed'),
    ];
  }

  List<CallStatusOption> _tagsToOptions(dynamic tagsDefinition) {
    if (tagsDefinition is! List || tagsDefinition.isEmpty) {
      return _defaultCallStatusOptions();
    }

    final options = <CallStatusOption>[];
    for (final tag in tagsDefinition) {
      if (tag is! List || tag.isEmpty) continue;
      final key = tag.first.toString();
      final label = tag.length > 1 ? tag[1].toString() : key;
      options.add(CallStatusOption(key: key, label: label));
    }

    return options.isEmpty ? _defaultCallStatusOptions() : options;
  }

  String? _asString(dynamic value) {
    if (value == null || value == false) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  String _formatOdooDateTime(DateTime value) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(value.toLocal());
  }

  dynamic _cloneRaw(dynamic raw) {
    if (raw == null || raw == false) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is List) {
      return raw
          .map((item) {
            if (item is Map) return Map<String, dynamic>.from(item);
            return item;
          })
          .toList();
    }
    return raw;
  }
}
