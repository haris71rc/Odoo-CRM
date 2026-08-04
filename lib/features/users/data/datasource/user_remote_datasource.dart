import 'package:odoocrm/core/constants/app_constants.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/network/dio_client.dart';
import 'package:odoocrm/core/network/json_rpc_request.dart';
import 'package:odoocrm/features/users/data/dto/user_dto.dart';

class UserRemoteDatasource {
  UserRemoteDatasource(this._dioClient);

  final DioClient _dioClient;

  Future<List<UserDto>> searchReadInternalUsers() async {
    final request = JsonRpcRequest.callKw(
      model: 'res.users',
      method: 'search_read',
      args: [
        [
          ['active', '=', true],
          ['share', '=', false],
        ],
      ],
      kwargs: const {
        'fields': [
          'id',
          'name',
          'login',
          'email',
          'image_1920',
        ],
        'order': 'name asc',
      },
    );

    final response = await _dioClient.postJsonRpc(
      AppConstants.callKwPath,
      request,
    );

    final result = response['result'];
    if (result is! List) {
      throw const ParsingFailure('Unexpected users response');
    }

    return result
        .map(
          (item) => UserDto.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
