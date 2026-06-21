import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/storage_service.dart';
import '../data/request_models.dart';
import '../data/requests_remote_datasource.dart';

part 'create_workflow_state.dart';

class CreateWorkflowCubit extends Cubit<CreateWorkflowState> {
  CreateWorkflowCubit(this._dataSource, this._storage)
    : super(const CreateWorkflowInitial());

  final RequestsRemoteDataSource _dataSource;
  final StorageService _storage;

  Future<void> loadDropdowns() async {
    emit(const CreateWorkflowLoadingDropdowns());
    try {
      final userGroupId = int.tryParse(_storage.getHrGroupId() ?? '') ?? 0;
      final dropdowns = await _dataSource.getWorkflowDropdowns(
        userGroupId: userGroupId,
      );
      emit(CreateWorkflowDropdownsLoaded(dropdowns));
    } on ApiException catch (e) {
      emit(CreateWorkflowError(e.message));
    } catch (_) {
      emit(const CreateWorkflowError('Failed to load form data.'));
    }
  }

  Future<void> save(SaveWorkflowRequest request) async {
    final current = state;
    final dropdowns = switch (current) {
      CreateWorkflowDropdownsLoaded(:final dropdowns) => dropdowns,
      CreateWorkflowError(:final dropdowns) => dropdowns,
      _ => null,
    };

    emit(CreateWorkflowSaving(dropdowns: dropdowns));
    try {
      await _dataSource.saveWorkflow(request);
      emit(const CreateWorkflowSaved());
    } on ApiException catch (e) {
      emit(CreateWorkflowError(e.message, dropdowns: dropdowns));
    } catch (_) {
      emit(
        CreateWorkflowError('Failed to save workflow.', dropdowns: dropdowns),
      );
    }
  }

  Future<void> update(UpdateWorkflowRequest request) async {
    final current = state;
    final dropdowns = switch (current) {
      CreateWorkflowDropdownsLoaded(:final dropdowns) => dropdowns,
      CreateWorkflowError(:final dropdowns) => dropdowns,
      _ => null,
    };

    emit(CreateWorkflowSaving(dropdowns: dropdowns));
    try {
      await _dataSource.updateWorkflow(request);
      emit(const CreateWorkflowSaved());
    } on ApiException catch (e) {
      emit(CreateWorkflowError(e.message, dropdowns: dropdowns));
    } catch (_) {
      emit(
        CreateWorkflowError('Failed to update workflow.', dropdowns: dropdowns),
      );
    }
  }

  int get loggedInUserId {
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
          payload['empId'] ??
          payload['EmpId'] ??
          payload['empID'] ??
          payload['EmpID'] ??
          payload['employeeId'] ??
          payload['EmployeeId'] ??
          payload['id'] ??
          payload['ID'] ??
          payload['sub'];

      return raw is int ? raw : int.tryParse('$raw') ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
