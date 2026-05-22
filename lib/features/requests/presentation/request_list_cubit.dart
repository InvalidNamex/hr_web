import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/request_models.dart';
import '../data/requests_remote_datasource.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exception.dart';

part 'request_list_state.dart';

class RequestListCubit extends Cubit<RequestListState> {
  RequestListCubit(this._dataSource) : super(const RequestListInitial());

  final RequestsRemoteDataSource _dataSource;

  int _currentTypeId = 0;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetching = false;

  Future<void> loadRequests(int requestTypeId) async {
    _currentTypeId = requestTypeId;
    _currentPage = 1;
    _hasMore = true;
    emit(const RequestListLoading());
    await _fetchPage(replace: true);
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isFetching) return;
    final current = state;
    if (current is! RequestListLoaded) return;
    await _fetchPage(replace: false);
  }

  Future<void> refresh() => loadRequests(_currentTypeId);

  Future<void> _fetchPage({required bool replace}) async {
    _isFetching = true;
    try {
      final response = await _dataSource.getRequestList(
        requestTypeId: _currentTypeId,
        pageNo: _currentPage,
        pageSize: AppConstants.defaultPageSize,
      );

      final newItems = response.items;
      _hasMore = newItems.length >= AppConstants.defaultPageSize;
      if (_hasMore) _currentPage++;

      if (replace) {
        emit(RequestListLoaded(
          items: newItems,
          hasMore: _hasMore,
          totalCount: response.totalCount,
          summary: response.summary,
        ));
      } else {
        final current = state as RequestListLoaded;
        emit(RequestListLoaded(
          items: [...current.items, ...newItems],
          hasMore: _hasMore,
          totalCount: response.totalCount,
          summary: response.summary,
        ));
      }
    } on ApiException catch (e) {
      if (replace) {
        emit(RequestListError(e.message));
      }
    } catch (_) {
      if (replace) {
        emit(const RequestListError('Failed to load requests.'));
      }
    } finally {
      _isFetching = false;
    }
  }
}
