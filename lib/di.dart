import 'package:dio/dio.dart';
import 'features/requests/data/requests_remote_datasource.dart';
import 'features/auth/data/auth_remote_datasource.dart';
import 'core/storage/storage_service.dart';
import 'core/network/dio_client.dart';

// Minimal manual DI — no external package needed.
class _ServiceLocator {
  late StorageService storage;
  late Dio dio;
  late AuthRemoteDataSource authDataSource;
  late RequestsRemoteDataSource requestsDataSource;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    storage = await StorageService.create();
    dio = DioClient.create(storage);
    authDataSource = AuthRemoteDataSource(dio);
    requestsDataSource = RequestsRemoteDataSource(dio);
    _initialized = true;
  }

  T call<T>() {
    if (T == StorageService) return storage as T;
    if (T == Dio) return dio as T;
    if (T == AuthRemoteDataSource) return authDataSource as T;
    if (T == RequestsRemoteDataSource) return requestsDataSource as T;
    throw StateError('Unknown type $T');
  }
}

final getIt = _ServiceLocator();
