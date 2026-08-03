import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:odoocrm/features/leads/domain/entities/named_ref_entity.dart';

part 'lead_detail_entity.freezed.dart';

@freezed
abstract class LeadDetailEntity with _$LeadDetailEntity {
  const factory LeadDetailEntity({
    required int id,
    required String name,
    String? partnerName,
    String? phone,
    String? mobile,
    String? email,
    String? street,
    String? city,
    NamedRefEntity? state,
    NamedRefEntity? country,
    String? zip,
    String? description,
    NamedRefEntity? stage,
    NamedRefEntity? assignedUser,
    NamedRefEntity? team,
    String? priority,
    DateTime? createdDate,
    DateTime? writeDate,
    double? expectedRevenue,
    double? probability,
    @Default([]) List<int> tagIds,
  }) = _LeadDetailEntity;
}
