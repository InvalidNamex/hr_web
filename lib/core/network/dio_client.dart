import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final StorageService _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['ServiceKey'] = AppConstants.serviceKey;

    final token = _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 401 will be handled by AuthCubit watching the stream; just forward.
    handler.next(err);
  }
}

class DioClient {
  DioClient._();

  static Dio create(StorageService storage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(AuthInterceptor(storage));
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (o) => print('[DIO] $o'),
      ),
    );

    return dio;
  }
}
