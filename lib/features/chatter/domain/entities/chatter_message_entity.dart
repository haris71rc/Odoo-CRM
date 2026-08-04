import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:odoocrm/features/chatter/domain/entities/tracking_value_entity.dart';
import 'package:odoocrm/features/leads/domain/entities/named_ref_entity.dart';

part 'chatter_message_entity.freezed.dart';

@freezed
abstract class ChatterMessageEntity with _$ChatterMessageEntity {
  const ChatterMessageEntity._();

  const factory ChatterMessageEntity({
    required int id,
    NamedRefEntity? author,
    String? emailFrom,
    String? body,
    DateTime? date,
    String? messageType,
    NamedRefEntity? subtype,
    String? subtypeDescription,
    @Default(false) bool isNote,
    @Default(false) bool isDiscussion,
    @Default([]) List<TrackingValueEntity> trackingValues,
  }) = _ChatterMessageEntity;

  String get authorName {
    if (author != null && author!.name.trim().isNotEmpty) {
      return author!.name.trim();
    }
    return _nameFromEmailFrom(emailFrom) ?? 'System';
  }

  bool get hasTracking => trackingValues.isNotEmpty;

  bool get hasBody {
    final value = body?.trim();
    if (value == null || value.isEmpty) return false;
    final stripped = value
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
    return stripped.isNotEmpty;
  }

  bool get isEmpty =>
      !hasBody && !hasTracking && (subtypeDescription?.trim().isEmpty ?? true);

  static String? _nameFromEmailFrom(String? emailFrom) {
    if (emailFrom == null || emailFrom.trim().isEmpty) return null;
    final match = RegExp(r'^([^<]+)').firstMatch(emailFrom.trim());
    final name = match?.group(1)?.trim();
    if (name == null || name.isEmpty) return emailFrom.trim();
    return name.replaceAll('"', '');
  }
}
