import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/request_models.dart';
import '../data/requests_remote_datasource.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/storage_service.dart';

part 'request_types_state.dart';

class RequestTypesCubit extends Cubit<RequestTypesState> {
  RequestTypesCubit(this._dataSource, this._storage) : super(const RequestTypesInitial());

  final RequestsRemoteDataSource _dataSource;
  final StorageService _storage;

  Future<void> loadTypes() async {
    emit(const RequestTypesLoading());
    try {
      final userGroupId = int.tryParse(_storage.getHrGroupId() ?? '') ?? 0;
      final types = await _dataSource.getRequestTypes(userGroupId: userGroupId);
      emit(RequestTypesLoaded(types));
    } on ApiException catch (e) {
      emit(RequestTypesError(e.message));
    } catch (_) {
      emit(const RequestTypesError('Failed to load request types.'));
    }
  }
}
