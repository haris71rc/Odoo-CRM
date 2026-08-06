import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:odoocrm/features/mobile_call/data/mapper/latest_mobile_call_mapper.dart';
import 'package:odoocrm/features/mobile_call/domain/entities/latest_mobile_call_entity.dart';

/// Builds the dual human + machine-readable Log Note body.
class MobileCallLogNoteBuilder {
  const MobileCallLogNoteBuilder({
    this.mapper = const LatestMobileCallMapper(),
  });

  final LatestMobileCallMapper mapper;

  String build(LatestMobileCallEntity call) {
    final dto = mapper.toDto(call);
    final compactJson = jsonEncode(dto.toJson());
    final human = _humanSummary(call);

    return '''
[MOBILE_CALL]
$compactJson
[/MOBILE_CALL]

$human
'''.trim();
  }

  String _humanSummary(LatestMobileCallEntity call) {
    final statusLine = switch (call.status.toLowerCase()) {
      'answered' => 'Customer answered the phone.',
      'busy' => 'Customer line was busy.',
      'missed' => 'Call was missed.',
      'rejected' => 'Call was rejected.',
      'no_answer' => 'Customer did not answer.',
      _ => 'Call completed (${call.status}).',
    };

    final duration = _formatDuration(call.duration);
    final direction = call.direction.isEmpty
        ? 'Outgoing'
        : '${call.direction[0].toUpperCase()}${call.direction.substring(1).toLowerCase()}';

    return '''
$statusLine

Duration : $duration

Direction : $direction
'''.trim();
  }

  String _formatDuration(int seconds) {
    final safe = seconds < 0 ? 0 : seconds;
    final minutes = safe ~/ 60;
    final secs = safe % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Formats timestamp for display helpers if needed.
  static String formatTimestamp(DateTime value) {
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(value.toLocal());
  }
}
