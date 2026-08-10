import 'package:html/parser.dart' as html_parser;
import 'package:odoocrm/features/chatter/domain/entities/chatter_message_entity.dart';
import 'package:odoocrm/features/chatter/domain/repository/chatter_repository.dart';
import 'package:odoocrm/features/leads/presentation/utils/lead_list_filters.dart';

/// Resolves when a lead most recently entered Follow-up (from chatter tracking).
class FollowUpStageResolver {
  const FollowUpStageResolver();

  /// Returns the local wall-clock time the lead entered the *current* Follow-Up.
  ///
  /// [leadWriteDate] is used when the lead is in Follow-Up but chatter has not
  /// yet returned the newest stage-change (common right after moving in).
  Future<DateTime?> resolve(
    ChatterRepository chatterRepository,
    int leadId, {
    DateTime? leadWriteDate,
  }) async {
    final result = await chatterRepository.getMessagesForLead(leadId);
    return result.when(
      success: (messages) => _findFollowUpEnteredAt(
        messages,
        leadWriteDate: leadWriteDate,
      ),
      failure: (_) => leadWriteDate?.toLocal(),
    );
  }

  DateTime? _findFollowUpEnteredAt(
    List<ChatterMessageEntity> messages, {
    DateTime? leadWriteDate,
  }) {
    // Messages are newest-first. Walk stage changes to find the current visit.
    for (final message in messages) {
      final newStage = _stageNewValue(message);
      if (newStage == null) continue;

      if (LeadListFilters.isFollowUp(newStage)) {
        return message.date?.toLocal() ?? leadWriteDate?.toLocal();
      }

      // Newest stage change is away from Follow-Up. If we are validating while
      // still in Follow-Up, chatter is stale — fall back to lead write_date.
      return leadWriteDate?.toLocal();
    }

    // No stage tracking found.
    return leadWriteDate?.toLocal();
  }

  String? _stageNewValue(ChatterMessageEntity message) {
    for (final tracking in message.trackingValues) {
      if (!_isStageField(tracking.changedField)) continue;
      final value = tracking.newValue?.trim();
      if (value != null && value.isNotEmpty) return value;
    }

    final subtype = message.subtypeDescription?.trim() ?? '';
    if (_textIndicatesFollowUpEntry(subtype)) return 'Follow-Up';

    final bodyText = _toPlainText(message.body ?? '');
    if (_textIndicatesFollowUpEntry(bodyText)) return 'Follow-Up';

    return null;
  }

  bool _textIndicatesFollowUpEntry(String text) {
    final normalized = text.toLowerCase().trim();
    if (normalized.isEmpty || !normalized.contains('follow')) return false;

    if (normalized.contains('stage set to') &&
        LeadListFilters.isFollowUp(normalized)) {
      return true;
    }

    if (RegExp(
      r'(?:stage\s+set\s+to|→|->|:)\s*follow[\s-]*up',
      caseSensitive: false,
    ).hasMatch(normalized)) {
      return true;
    }

    return false;
  }

  bool _isStageField(String field) {
    final n = field.toLowerCase().trim();
    return n == 'stage' ||
        n == 'stage_id' ||
        n.contains('stage') ||
        n == 'status';
  }

  String _toPlainText(String raw) {
    final withBreaks = raw
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n');

    try {
      final document = html_parser.parse(withBreaks);
      return document.body?.text ?? withBreaks;
    } catch (_) {
      return withBreaks.replaceAll(RegExp(r'<[^>]+>'), ' ');
    }
  }
}
