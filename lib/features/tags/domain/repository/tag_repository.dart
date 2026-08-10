import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/tags/domain/entities/lead_tag_entity.dart';

abstract class TagRepository {
  /// Fetches HOT_LEAD / WARM_LEAD tags from Odoo `crm.tag` by name.
  Future<Result<List<LeadTagEntity>>> getLeadTemperatureTags();
}
