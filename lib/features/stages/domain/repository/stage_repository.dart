import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/stages/domain/entities/stage_entity.dart';

abstract class StageRepository {
  Future<Result<List<StageEntity>>> getStages();
}
