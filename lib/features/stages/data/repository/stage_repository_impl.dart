import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/stages/data/datasource/stage_remote_datasource.dart';
import 'package:odoocrm/features/stages/data/mapper/stage_mapper.dart';
import 'package:odoocrm/features/stages/domain/entities/stage_entity.dart';
import 'package:odoocrm/features/stages/domain/repository/stage_repository.dart';

class StageRepositoryImpl implements StageRepository {
  StageRepositoryImpl({
    required StageRemoteDatasource datasource,
    StageMapper mapper = const StageMapper(),
  })  : _datasource = datasource,
        _mapper = mapper;

  final StageRemoteDatasource _datasource;
  final StageMapper _mapper;

  @override
  Future<Result<List<StageEntity>>> getStages() async {
    try {
      final dtos = await _datasource.searchRead();
      return Success(_mapper.toEntityList(dtos));
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
