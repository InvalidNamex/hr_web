import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/request_models.dart';
import '../data/requests_remote_datasource.dart';
import '../../../core/network/api_exception.dart';

part 'execute_vacation_state.dart';

class ExecuteVacationCubit extends Cubit<ExecuteVacationState> {
  ExecuteVacationCubit(this._dataSource) : super(const ExecuteVacationInitial());

  final RequestsRemoteDataSource _dataSource;

  Future<void> execute(ExecuteVacationRequest request) async {
    emit(const ExecuteVacationLoading());
    try {
      await _dataSource.executeVacation(request);
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
      await _dataSource.undoExecuteVacation(request);
      emit(const ExecuteVacationSuccess(isUndo: true));
    } on ApiException catch (e) {
      emit(ExecuteVacationError(e.message));
    } catch (_) {
      emit(const ExecuteVacationError('Failed to undo vacation request.'));
    }
  }

  void reset() => emit(const ExecuteVacationInitial());
}
