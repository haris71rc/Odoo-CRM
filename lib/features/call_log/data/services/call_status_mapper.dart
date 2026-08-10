import 'package:call_log/call_log.dart' as native;
import 'package:odoocrm/features/call_log/data/parser/lead_properties_parser.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_status_option.dart';

/// Maps native call-log entries to Odoo Call Status tag keys.
class CallStatusMapper {
  const CallStatusMapper({
    LeadPropertiesParser parser = const LeadPropertiesParser(),
  }) : _parser = parser;

  final LeadPropertiesParser _parser;

  String mapDeviceStatus({
    required native.CallType? type,
    required int durationSeconds,
    required List<CallStatusOption> options,
  }) {
    final hint = _deviceStatusHint(type, durationSeconds);
    return _parser.resolveTagKey(options, hint) ?? hint;
  }

  String _deviceStatusHint(native.CallType? type, int durationSeconds) {
    switch (type) {
      case native.CallType.missed:
        return 'missed';
      case native.CallType.rejected:
      case native.CallType.blocked:
        return 'hanged_up';
      case native.CallType.outgoing:
      case native.CallType.wifiOutgoing:
        return durationSeconds > 0 ? 'picked' : 'dnp';
      case native.CallType.incoming:
      case native.CallType.wifiIncoming:
        return durationSeconds > 0 ? 'picked' : 'missed';
      case native.CallType.voiceMail:
      case native.CallType.answeredExternally:
      case native.CallType.unknown:
      case null:
        return durationSeconds > 0 ? 'picked' : 'call_failed';
    }
  }
}
