part of 'workflows_cubit.dart';

abstract class WorkflowsState extends Equatable {
  const WorkflowsState();

  @override
  List<Object?> get props => [];
}

class WorkflowsInitial extends WorkflowsState {
  const WorkflowsInitial();
}

class WorkflowsLoading extends WorkflowsState {
  const WorkflowsLoading();
}

class WorkflowsLoaded extends WorkflowsState {
  const WorkflowsLoaded({required this.items, required this.query});

  final List<WorkflowListItem> items;
  final String query;

  WorkflowsLoaded copyWith({List<WorkflowListItem>? items, String? query}) {
    return WorkflowsLoaded(
      items: items ?? this.items,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [items, query];
}

class WorkflowsError extends WorkflowsState {
  const WorkflowsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
