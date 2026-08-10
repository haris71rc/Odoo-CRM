import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/tags/data/datasource/tag_remote_datasource.dart';
import 'package:odoocrm/features/tags/data/mapper/tag_mapper.dart';
import 'package:odoocrm/features/tags/domain/entities/lead_tag_entity.dart';
import 'package:odoocrm/features/tags/domain/repository/tag_repository.dart';

class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl({
    required TagRemoteDatasource datasource,
    TagMapper mapper = const TagMapper(),
  })  : _datasource = datasource,
        _mapper = mapper;

  final TagRemoteDatasource _datasource;
  final TagMapper _mapper;

  @override
  Future<Result<List<LeadTagEntity>>> getLeadTemperatureTags() async {
    try {
      final rows = await _datasource.searchLeadTemperatureTags();
      return Success(_mapper.toEntityList(rows));
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
