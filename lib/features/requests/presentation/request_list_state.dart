part of 'request_list_cubit.dart';

abstract class RequestListState extends Equatable {
  const RequestListState();
  @override
  List<Object?> get props => [];
}

class RequestListInitial extends RequestListState {
  const RequestListInitial();
}

class RequestListLoading extends RequestListState {
  const RequestListLoading();
}

class RequestListLoaded extends RequestListState {
  const RequestListLoaded({
    required this.items,
    required this.hasMore,
    required this.totalCount,
    this.summary,
  });

  final List<RequestListItem> items;
  final bool hasMore;
  final int totalCount;
  final RequestSummary? summary;

  @override
  List<Object?> get props => [items, hasMore, totalCount, summary];
}

class RequestListError extends RequestListState {
  const RequestListError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
