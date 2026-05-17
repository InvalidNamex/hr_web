import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/request_models.dart';
import '../data/requests_remote_datasource.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/storage_service.dart';

part 'request_info_state.dart';

class RequestInfoCubit extends Cubit<RequestInfoState> {
  RequestInfoCubit(this._dataSource, this._storage) : super(const RequestInfoInitial());

  final RequestsRemoteDataSource _dataSource;
  final StorageService _storage;

  Future<void> loadInfo({
    required int empReqMasterId,
    required int requestId,
  }) async {
    emit(const RequestInfoLoading());
    try {
      final userGroupId = int.tryParse(_storage.getHrGroupId() ?? '') ?? 0;
      final info = await _dataSource.getRequestInfo(
        empReqMasterId: empReqMasterId,
        requestId: requestId,
        userGroupId: userGroupId,
      );
      emit(RequestInfoLoaded(info));
    } on ApiException catch (e) {
      emit(RequestInfoError(e.message));
    } catch (_) {
      emit(const RequestInfoError('Failed to load request details.'));
    }
  }
}
