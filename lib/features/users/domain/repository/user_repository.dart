import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/users/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Result<List<UserEntity>>> getInternalUsers();
}
