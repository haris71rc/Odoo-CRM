import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/users/data/datasource/user_remote_datasource.dart';
import 'package:odoocrm/features/users/data/mapper/user_mapper.dart';
import 'package:odoocrm/features/users/domain/entities/user_entity.dart';
import 'package:odoocrm/features/users/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required UserRemoteDatasource datasource,
    UserMapper mapper = const UserMapper(),
  })  : _datasource = datasource,
        _mapper = mapper;

  final UserRemoteDatasource _datasource;
  final UserMapper _mapper;

  @override
  Future<Result<List<UserEntity>>> getInternalUsers() async {
    try {
      final dtos = await _datasource.searchReadInternalUsers();
      return Success(_mapper.toEntityList(dtos));
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
