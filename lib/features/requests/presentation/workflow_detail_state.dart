part of 'workflow_detail_cubit.dart';

abstract class WorkflowDetailState extends Equatable {
  const WorkflowDetailState();

  @override
  List<Object?> get props => [];
}

class WorkflowDetailInitial extends WorkflowDetailState {
  const WorkflowDetailInitial();
}

class WorkflowDetailLoading extends WorkflowDetailState {
  const WorkflowDetailLoading();
}

class WorkflowDetailLoaded extends WorkflowDetailState {
  const WorkflowDetailLoaded(this.workflow);

  final WorkflowDetails workflow;

  @override
  List<Object?> get props => [workflow];
}

class WorkflowDetailError extends WorkflowDetailState {
  const WorkflowDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
