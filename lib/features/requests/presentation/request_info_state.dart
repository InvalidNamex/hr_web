part of 'request_info_cubit.dart';

abstract class RequestInfoState extends Equatable {
  const RequestInfoState();
  @override
  List<Object?> get props => [];
}

class RequestInfoInitial extends RequestInfoState {
  const RequestInfoInitial();
}

class RequestInfoLoading extends RequestInfoState {
  const RequestInfoLoading();
}

class RequestInfoLoaded extends RequestInfoState {
  const RequestInfoLoaded(this.info);
  final RequestInfo info;
  @override
  List<Object?> get props => [info];
}

class RequestInfoError extends RequestInfoState {
  const RequestInfoError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
