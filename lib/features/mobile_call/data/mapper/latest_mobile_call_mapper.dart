import 'package:odoocrm/features/mobile_call/data/dto/latest_mobile_call_dto.dart';
import 'package:odoocrm/features/mobile_call/domain/entities/latest_mobile_call_entity.dart';

class LatestMobileCallMapper {
  const LatestMobileCallMapper();

  LatestMobileCallEntity toEntity(LatestMobileCallDto dto) {
    return LatestMobileCallEntity(
      status: dto.status.trim().isEmpty ? 'no_answer' : dto.status.trim(),
      duration: dto.duration < 0 ? 0 : dto.duration,
      direction:
          dto.direction.trim().isEmpty ? 'outgoing' : dto.direction.trim(),
      phone: dto.phone.trim(),
      timestamp: _parseTimestamp(dto.timestamp) ?? DateTime.now().toLocal(),
      userId: dto.userId,
    );
  }

  LatestMobileCallDto toDto(LatestMobileCallEntity entity) {
    return LatestMobileCallDto(
      status: entity.status,
      duration: entity.duration,
      direction: entity.direction,
      phone: entity.phone,
      timestamp: entity.timestamp.toIso8601String(),
      source: 'mobile_app',
      type: 'call',
      userId: entity.userId,
    );
  }

  DateTime? _parseTimestamp(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }
}
