import 'dart:convert';

import 'package:html/parser.dart' as html_parser;
import 'package:odoocrm/features/chatter/domain/entities/chatter_message_entity.dart';
import 'package:odoocrm/features/leads/presentation/utils/lead_list_filters.dart';
import 'package:odoocrm/features/mobile_call/data/dto/latest_mobile_call_dto.dart';
import 'package:odoocrm/features/mobile_call/data/mapper/latest_mobile_call_mapper.dart';
import 'package:odoocrm/features/mobile_call/domain/entities/latest_mobile_call_entity.dart';

/// Result of locating the latest transition into Follow-up.
class FollowUpEntry {
  const FollowUpEntry({
    required this.messageId,
    this.at,
  });

  final int messageId;
  final DateTime? at;
}

/// Extracts [LatestMobileCallEntity] from Odoo chatter HTML bodies.
///
/// Never throws — malformed messages are ignored.
class MobileCallParser {
  const MobileCallParser({
    this.mapper = const LatestMobileCallMapper(),
  });

  final LatestMobileCallMapper mapper;

  static final RegExp _blockPattern = RegExp(
    r'\[MOBILE_CALL\]\s*(\{[\s\S]*?\})\s*\[/MOBILE_CALL\]',
    caseSensitive: false,
  );

  static final RegExp _stageToFollowUpPattern = RegExp(
    r'(?:stage\s+set\s+to|→|->|:)\s*follow[\s-]*up',
    caseSensitive: false,
  );

  /// Parses a single chatter body (HTML or plain text).
  LatestMobileCallEntity? parseBody(String? body) {
    if (body == null || body.trim().isEmpty) return null;

    try {
      final text = _toPlainText(body);
      final match = _blockPattern.firstMatch(text);
      if (match == null) return null;

      final jsonRaw = match.group(1)?.trim();
      if (jsonRaw == null || jsonRaw.isEmpty) return null;

      final decoded = jsonDecode(jsonRaw);
      if (decoded is! Map) return null;

      final dto = LatestMobileCallDto.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      if (dto.status.isEmpty && dto.phone.isEmpty) return null;

      return mapper.toEntity(dto);
    } catch (_) {
      return null;
    }
  }

  /// Returns the newest MOBILE_CALL entry from [messages] (newest-first list).
  LatestMobileCallEntity? parseLatestFromMessages(
    List<ChatterMessageEntity> messages,
  ) {
    final all = parseAllFromMessages(messages);
    return all.isEmpty ? null : all.first;
  }

  /// All MOBILE_CALL entries, newest first (same order as [messages]).
  List<LatestMobileCallEntity> parseAllFromMessages(
    List<ChatterMessageEntity> messages,
  ) {
    final calls = <LatestMobileCallEntity>[];
    for (final message in messages) {
      final parsed = parseBody(message.body);
      if (parsed == null) continue;
      calls.add(
        parsed.copyWith(
          messageId: message.id,
          loggedAt: message.date?.toLocal(),
        ),
      );
    }
    return calls;
  }

  /// Most recent transition *into* a Follow-up stage (newest-first scan).
  FollowUpEntry? findFollowUpEntry(List<ChatterMessageEntity> messages) {
    for (final message in messages) {
      if (_messageIndicatesFollowUpEntry(message)) {
        return FollowUpEntry(
          messageId: message.id,
          at: message.date?.toLocal(),
        );
      }
    }
    return null;
  }

  /// Timestamp helper kept for callers that only need the date.
  DateTime? findFollowUpEnteredAt(List<ChatterMessageEntity> messages) {
    return findFollowUpEntry(messages)?.at;
  }

  bool _messageIndicatesFollowUpEntry(ChatterMessageEntity message) {
    for (final tracking in message.trackingValues) {
      if (!_isStageField(tracking.changedField)) continue;
      if (LeadListFilters.isFollowUp(tracking.newValue)) return true;
    }

    final subtype = message.subtypeDescription?.trim() ?? '';
    if (_textIndicatesFollowUpEntry(subtype)) return true;

    final bodyText = _toPlainText(message.body ?? '');
    if (_textIndicatesFollowUpEntry(bodyText)) return true;

    return false;
  }

  bool _textIndicatesFollowUpEntry(String text) {
    final normalized = text.toLowerCase().trim();
    if (normalized.isEmpty) return false;
    if (!normalized.contains('follow')) return false;

    // "Stage set to Follow-Up"
    if (normalized.contains('stage set to') &&
        LeadListFilters.isFollowUp(normalized)) {
      return true;
    }

    // "Not connected (DNP) → Follow-Up (Stage)" or "-> Follow-Up"
    if (_stageToFollowUpPattern.hasMatch(normalized)) return true;

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
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n');

    try {
      final document = html_parser.parse(withBreaks);
      final text = document.body?.text ?? withBreaks;
      return _decodeBasicEntities(text);
    } catch (_) {
      return _decodeBasicEntities(
        withBreaks.replaceAll(RegExp(r'<[^>]+>'), ' '),
      );
    }
  }

  String _decodeBasicEntities(String input) {
    return input
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }
}
