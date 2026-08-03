import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:odoocrm/features/leads/domain/entities/named_ref_entity.dart';

part 'lead_entity.freezed.dart';

@freezed
abstract class LeadEntity with _$LeadEntity {
  const factory LeadEntity({
    required int id,
    required String name,
    String? phone,
    String? partnerName,
    NamedRefEntity? stage,
    NamedRefEntity? assignedUser,
    String? priority,
    DateTime? createdDate,
    String? description,
  }) = _LeadEntity;
}
