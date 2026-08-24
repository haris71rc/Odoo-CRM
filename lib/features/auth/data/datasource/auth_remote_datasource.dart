import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/network/dio_client.dart';
import 'package:odoocrm/core/network/json_rpc_request.dart';
import 'package:odoocrm/core/storage/secure_storage_service.dart';
import 'package:odoocrm/features/auth/data/dto/auth_session_dto.dart';
import 'package:odoocrm/features/auth/data/dto/user_dto.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource({
    required DioClient dioClient,
    required SecureStorageService secureStorage,
  })  : _dioClient = dioClient,
        _secureStorage = secureStorage;

  final DioClient _dioClient;
  final SecureStorageService _secureStorage;

  Future<AuthSessionDto> authenticate({
    required String login,
    required String password,
  }) async {
    final request = JsonRpcRequest.authenticate(
      db: _dioClient.databaseName,
      login: login,
      password: password,
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.authenticatePath,
      request,
    );

    final result = response['result'];
    if (result == null || result is! Map<String, dynamic>) {
      throw const AuthFailure('Invalid credentials');
    }

    final uid = result['uid'];
    if (uid == null || uid == false) {
      throw const AuthFailure('Invalid username or password');
    }

    final sessionIdFromResult = result['session_id'];
    if (sessionIdFromResult is String && sessionIdFromResult.isNotEmpty) {
      await _secureStorage.saveSessionId(sessionIdFromResult);
    }

    return AuthSessionDto.fromJson({
      ...result,
      'username': login,
    });
  }

  Future<UserDto> fetchUser(int uid) async {
    final request = JsonRpcRequest.callKw(
      model: 'res.users',
      method: 'read',
      args: [
        [uid],
        ['id', 'name', 'login', 'email', 'partner_id'],
      ],
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callKwPath,
      request,
    );

    final result = response['result'];
    if (result is! List || result.isEmpty) {
      throw const ApiFailure('Unable to load user profile');
    }

    return UserDto.fromJson(Map<String, dynamic>.from(result.first as Map));
  }

  Future<String?> readStoredSessionId() => _secureStorage.getSessionId();
}
