import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/request_models.dart';
import '../data/requests_remote_datasource.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/storage_service.dart';

part 'execute_vacation_state.dart';

class ExecuteVacationCubit extends Cubit<ExecuteVacationState> {
  ExecuteVacationCubit(this._dataSource, this._storage)
    : super(const ExecuteVacationInitial());

  final RequestsRemoteDataSource _dataSource;
  final StorageService _storage;

  Future<void> execute(ExecuteVacationRequest request) async {
    emit(const ExecuteVacationLoading());
    try {
      final loggedInUserId = _resolveLoggedInUserId();
      await _dataSource.executeVacation(
        ExecuteVacationRequest(
          empReqMasterId: request.empReqMasterId,
          vacReqDetailId: request.vacReqDetailId,
          empId: loggedInUserId > 0 ? loggedInUserId : request.empId,
        ),
      );
      emit(const ExecuteVacationSuccess(isUndo: false));
    } on ApiException catch (e) {
      emit(ExecuteVacationError(e.message));
    } catch (_) {
      emit(const ExecuteVacationError('Failed to execute vacation request.'));
    }
  }

  Future<void> undo(ExecuteVacationRequest request) async {
    emit(const ExecuteVacationLoading());
    try {
      final loggedInUserId = _resolveLoggedInUserId();
      await _dataSource.undoExecuteVacation(
        ExecuteVacationRequest(
          empReqMasterId: request.empReqMasterId,
          vacReqDetailId: request.vacReqDetailId,
          empId: loggedInUserId > 0 ? loggedInUserId : request.empId,
        ),
      );
      emit(const ExecuteVacationSuccess(isUndo: true));
    } on ApiException catch (e) {
      emit(ExecuteVacationError(e.message));
    } catch (_) {
      emit(const ExecuteVacationError('Failed to undo vacation request.'));
    }
  }

  void reset() => emit(const ExecuteVacationInitial());

  int _resolveLoggedInUserId() {
    final stored = _storage.getEmpId();
    if (stored > 0) return stored;

    final token = _storage.getToken();
    if (token == null || token.isEmpty) return 0;

    try {
      final parts = token.split('.');
      if (parts.length < 2) return 0;
      final normalized = base64Url.normalize(parts[1]);
      final payload =
          jsonDecode(utf8.decode(base64Url.decode(normalized))) as Map<String, dynamic>;

      final dynamic raw =
          payload['userId'] ??
          payload['UserId'] ??
          payload['empId'] ??
          payload['EmpId'] ??
          payload['empID'] ??
          payload['EmpID'] ??
          payload['employeeId'] ??
          payload['EmployeeId'] ??
          payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
          payload['id'] ??
          payload['ID'] ??
          payload['sub'];

      return raw is int ? raw : int.tryParse('$raw') ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
