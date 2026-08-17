import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../core/utils/token_storage.dart';
import '../models/auth_response_model.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    final json = await ApiClient.instance.post(
      ApiConstants.login,
      body: {'username': username, 'password': password},
    );
    print('RESPONSE LOGIN: $json');
    final result = AuthResponseModel.fromJson(json);
    await TokenStorage.saveToken(result.token);
    return result;
  }
}
