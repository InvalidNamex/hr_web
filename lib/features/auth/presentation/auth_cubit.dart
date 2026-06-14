import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/auth_models.dart';
import '../data/auth_remote_datasource.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/network/api_exception.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRemoteDataSource dataSource,
    required StorageService storage,
  }) : _dataSource = dataSource,
       _storage = storage,
       super(const AuthInitial());

  final AuthRemoteDataSource _dataSource;
  final StorageService _storage;

  Future<void> tryAutoLogin() async {
    if (_storage.hasToken) {
      emit(const AuthAuthenticated());
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> login(String username, String password) async {
    emit(const AuthLoading());
    try {
      final response = await _dataSource.login(
        LoginRequest(username: username, password: password),
      );
      await _storage.saveToken(response.token);
      await _storage.saveHrGroupId(response.hrGroupId);
      await _storage.saveEmpId(response.empId);
      emit(const AuthAuthenticated());
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(const AuthError('Unexpected error. Please try again.'));
    }
  }

  Future<void> logout() async {
    await _storage.clearToken();
    await _storage.clearHrGroupId();
    await _storage.clearEmpId();
    emit(const AuthUnauthenticated());
  }
}
