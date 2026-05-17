part of 'execute_vacation_cubit.dart';

abstract class ExecuteVacationState extends Equatable {
  const ExecuteVacationState();
  @override
  List<Object?> get props => [];
}

class ExecuteVacationInitial extends ExecuteVacationState {
  const ExecuteVacationInitial();
}

class ExecuteVacationLoading extends ExecuteVacationState {
  const ExecuteVacationLoading();
}

class ExecuteVacationSuccess extends ExecuteVacationState {
  const ExecuteVacationSuccess({required this.isUndo});
  final bool isUndo;
  @override
  List<Object?> get props => [isUndo];
}

class ExecuteVacationError extends ExecuteVacationState {
  const ExecuteVacationError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
