import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/auth/domain/entities/auth_session_entity.dart';
import 'package:odoocrm/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<AuthSessionEntity>> login({
    required String username,
    required String password,
  });

  Future<Result<UserEntity>> getCurrentUser();

  Future<Result<bool>> isAuthenticated();

  Future<Result<void>> logout();

  Future<Result<int?>> getStoredUid();
}
