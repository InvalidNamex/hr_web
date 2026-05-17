import 'package:dio/dio.dart';
import '../../../core/network/api_exception.dart';
import '../data/auth_models.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/api/Web/Login',
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
