part of 'create_workflow_cubit.dart';

abstract class CreateWorkflowState extends Equatable {
  const CreateWorkflowState();

  @override
  List<Object?> get props => [];
}

class CreateWorkflowInitial extends CreateWorkflowState {
  const CreateWorkflowInitial();
}

class CreateWorkflowLoadingDropdowns extends CreateWorkflowState {
  const CreateWorkflowLoadingDropdowns();
}

class CreateWorkflowDropdownsLoaded extends CreateWorkflowState {
  const CreateWorkflowDropdownsLoaded(this.dropdowns);

  final WorkflowDropdowns dropdowns;

  @override
  List<Object?> get props => [dropdowns];
}

class CreateWorkflowSaving extends CreateWorkflowState {
  const CreateWorkflowSaving({this.dropdowns});

  final WorkflowDropdowns? dropdowns;

  @override
  List<Object?> get props => [dropdowns];
}

class CreateWorkflowSaved extends CreateWorkflowState {
  const CreateWorkflowSaved();
}

class CreateWorkflowError extends CreateWorkflowState {
  const CreateWorkflowError(this.message, {this.dropdowns});

  final String message;
  final WorkflowDropdowns? dropdowns;

  @override
  List<Object?> get props => [message, dropdowns];
}
