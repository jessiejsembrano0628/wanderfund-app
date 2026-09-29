import '../models/login_response.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../shared/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login({
    required String email,
    required String password,
  });
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String mobileNumber,
  });
  Future<void> logout(String token);
  Future<UserModel> getCurrentUser(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl({required this.apiService});

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiService.post(
        endpoint: AppConstants.loginEndpoint,
        body: {'email': email, 'password': password},
      );

      try {
        return LoginResponse.fromJson(response);
      } on FormatException catch (e) {
        throw ServerException(message: e.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String mobileNumber,
  }) async {
    await apiService.post(
      endpoint: AppConstants.registerEndpoint,
      body: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'mobile_number': mobileNumber,
      },
    );
  }

  @override
  Future<void> logout(String token) async {
    try {
      await apiService.post(
        endpoint: AppConstants.logoutEndpoint,
        body: {},
        token: token,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    try {
      final response = await apiService.get(
        endpoint: AppConstants.getUserEndpoint,
        token: token,
      );

      if (response['success'] == true) {
        return UserModel.fromJson(response['data']);
      } else {
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch user',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
