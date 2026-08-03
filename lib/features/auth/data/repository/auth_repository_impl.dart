import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/core/storage/secure_storage_service.dart';
import 'package:odoocrm/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:odoocrm/features/auth/data/mapper/auth_session_mapper.dart';
import 'package:odoocrm/features/auth/data/mapper/user_mapper.dart';
import 'package:odoocrm/features/auth/domain/entities/auth_session_entity.dart';
import 'package:odoocrm/features/auth/domain/entities/user_entity.dart';
import 'package:odoocrm/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDatasource datasource,
    required SecureStorageService secureStorage,
    AuthSessionMapper sessionMapper = const AuthSessionMapper(),
    UserMapper userMapper = const UserMapper(),
  })  : _datasource = datasource,
        _secureStorage = secureStorage,
        _sessionMapper = sessionMapper,
        _userMapper = userMapper;

  final AuthRemoteDatasource _datasource;
  final SecureStorageService _secureStorage;
  final AuthSessionMapper _sessionMapper;
  final UserMapper _userMapper;

  @override
  Future<Result<AuthSessionEntity>> login({
    required String username,
    required String password,
  }) async {
    try {
      final dto = await _datasource.authenticate(
        login: username,
        password: password,
      );

      final sessionId = await _datasource.readStoredSessionId();
      if (sessionId == null || sessionId.isEmpty) {
        return const Error(AuthFailure('Session cookie missing after login'));
      }

      await _secureStorage.saveSession(
        sessionId: sessionId,
        uid: dto.uid,
        login: username,
      );

      return Success(
        _sessionMapper.toEntity(dto, sessionId: sessionId),
      );
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> getCurrentUser() async {
    try {
      final uid = await _secureStorage.getUid();
      if (uid == null) {
        return const Error(AuthFailure('No authenticated user'));
      }

      final dto = await _datasource.fetchUser(uid);
      return Success(_userMapper.toEntity(dto));
    } on Failure catch (failure) {
      return Error(failure);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> isAuthenticated() async {
    try {
      final hasSession = await _secureStorage.hasSession();
      return Success(hasSession);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _secureStorage.clear();
      return const Success(null);
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Result<int?>> getStoredUid() async {
    try {
      return Success(await _secureStorage.getUid());
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
