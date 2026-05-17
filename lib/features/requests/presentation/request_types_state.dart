part of 'request_types_cubit.dart';

abstract class RequestTypesState extends Equatable {
  const RequestTypesState();
  @override
  List<Object?> get props => [];
}

class RequestTypesInitial extends RequestTypesState {
  const RequestTypesInitial();
}

class RequestTypesLoading extends RequestTypesState {
  const RequestTypesLoading();
}

class RequestTypesLoaded extends RequestTypesState {
  const RequestTypesLoaded(this.types);
  final List<RequestType> types;
  @override
  List<Object?> get props => [types];
}

class RequestTypesError extends RequestTypesState {
  const RequestTypesError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
