import 'package:odoocrm/core/utils/odoo_field_parser.dart';
import 'package:odoocrm/features/chatter/domain/entities/chatter_message_entity.dart';
import 'package:odoocrm/features/chatter/domain/entities/tracking_value_entity.dart';
import 'package:odoocrm/features/leads/domain/entities/named_ref_entity.dart';

/// Parses Odoo `/mail/thread/messages` Store payload into domain entities.
class ChatterStoreParser {
  const ChatterStoreParser();

  List<ChatterMessageEntity> parse(Map<String, dynamic> result) {
    final data = result['data'];
    if (data is! Map) return const [];

    final partnerNames = _partnerNameMap(data);
    final rawMessages = data['mail.message'];
    if (rawMessages is! List) return const [];

    final messages = rawMessages
        .whereType<Map>()
        .map((item) => _mapMessage(Map<String, dynamic>.from(item), partnerNames))
        .toList();

    final order = result['messages'];
    if (order is List && order.isNotEmpty) {
      final indexById = {
        for (var i = 0; i < order.length; i++)
          if (order[i] is int) order[i] as int: i,
      };
      messages.sort((a, b) {
        final ai = indexById[a.id] ?? 999999;
        final bi = indexById[b.id] ?? 999999;
        return ai.compareTo(bi);
      });
    } else {
      messages.sort((a, b) {
        final ad = a.date ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.date ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });
    }

    return messages;
  }

  Map<int, String> _partnerNameMap(Map<dynamic, dynamic> data) {
    final names = <int, String>{};

    for (final key in ['Persona', 'res.partner']) {
      final records = data[key];
      if (records is! List) continue;
      for (final record in records) {
        if (record is! Map) continue;
        final id = record['id'];
        final name = record['name'];
        if (id is int && name is String && name.isNotEmpty) {
          names[id] = name;
        }
      }
    }

    return names;
  }

  ChatterMessageEntity _mapMessage(
    Map<String, dynamic> json,
    Map<int, String> partnerNames,
  ) {
    final authorRef = _authorRef(json['author'], partnerNames) ??
        _many2One(json['author_id']);
    final subtypeRef = _many2One(json['subtype_id']);

    return ChatterMessageEntity(
      id: json['id'] as int,
      author: authorRef,
      emailFrom: OdooFieldParser.asString(json['email_from']),
      body: OdooFieldParser.asString(json['body']),
      date: OdooFieldParser.asDateTime(json['date']),
      messageType: OdooFieldParser.asString(json['message_type']),
      subtype: subtypeRef,
      subtypeDescription: OdooFieldParser.asString(json['subtype_description']),
      isNote: json['is_note'] == true,
      isDiscussion: json['is_discussion'] == true,
      trackingValues: _mapTrackingValues(json['trackingValues']),
    );
  }

  NamedRefEntity? _authorRef(
    dynamic author,
    Map<int, String> partnerNames,
  ) {
    if (author == false || author == null) return null;

    if (author is int) {
      return NamedRefEntity(id: author, name: partnerNames[author] ?? '');
    }

    if (author is Map) {
      final id = author['id'];
      if (id is! int) return null;
      final name = partnerNames[id] ?? OdooFieldParser.asString(author['name']);
      return NamedRefEntity(id: id, name: name ?? '');
    }

    return null;
  }

  NamedRefEntity? _many2One(dynamic value) {
    final ref = OdooFieldParser.asMany2One(value);
    if (ref == null) return null;
    return NamedRefEntity(id: ref.id, name: ref.name);
  }

  List<TrackingValueEntity> _mapTrackingValues(dynamic raw) {
    if (raw is! List) return const [];

    return raw.map((item) {
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        return TrackingValueEntity(
          changedField: OdooFieldParser.asString(map['changedField']) ??
              OdooFieldParser.asString(map['fieldName']) ??
              '',
          oldValue: _trackingDisplayValue(map['oldValue']),
          newValue: _trackingDisplayValue(map['newValue']),
          fieldType: OdooFieldParser.asString(map['fieldType']),
        );
      }
      return null;
    }).whereType<TrackingValueEntity>().where((item) {
      return item.changedField.isNotEmpty ||
          (item.oldValue?.isNotEmpty ?? false) ||
          (item.newValue?.isNotEmpty ?? false);
    }).toList();
  }

  String? _trackingDisplayValue(dynamic raw) {
    if (raw == null || raw == false) return null;
    if (raw is String) return raw.isEmpty ? null : raw;
    if (raw is num || raw is bool) return raw.toString();
    if (raw is Map) {
      final value = raw['value'];
      if (value == null || value == false) return null;
      return value.toString();
    }
    return raw.toString();
  }
}
