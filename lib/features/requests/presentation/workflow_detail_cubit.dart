import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../data/request_models.dart';
import '../data/requests_remote_datasource.dart';

part 'workflow_detail_state.dart';

class WorkflowDetailCubit extends Cubit<WorkflowDetailState> {
  WorkflowDetailCubit(this._dataSource) : super(const WorkflowDetailInitial());

  final RequestsRemoteDataSource _dataSource;

  Future<void> loadWorkflow(int id) async {
    emit(const WorkflowDetailLoading());
    try {
      final workflow = await _dataSource.getWorkflowById(id: id);
      emit(WorkflowDetailLoaded(workflow));
    } on ApiException catch (e) {
      emit(WorkflowDetailError(e.message));
    } catch (_) {
      emit(const WorkflowDetailError('Failed to load workflow details.'));
    }
  }
}
