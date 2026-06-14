import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exception.dart';
import 'request_models.dart';

class RequestsRemoteDataSource {
  RequestsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<RequestType>> getRequestTypes({required int userGroupId}) async {
    try {
      final response = await _dio.get(
        '/api/Web/GetRequestType',
        queryParameters: {'usergroupid': userGroupId},
      );
      final body = response.data;
      List<dynamic> list;
      if (body is Map<String, dynamic>) {
        list = (body['data'] ?? body['Data'] ?? []) as List;
      } else if (body is List) {
        list = body;
      } else {
        list = [];
      }
      return list
          .map((e) => RequestType.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<RequestListResponse> getRequestList({
    required int requestTypeId,
    required int pageNo,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    try {
      final response = await _dio.get(
        '/api/Web/GetRequestList',
        queryParameters: {
          'requestTypeId': requestTypeId,
          'pageNo': pageNo,
          'pageSize': pageSize,
        },
      );
      return RequestListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<RequestInfo> getRequestInfo({
    required int empReqMasterId,
    required int requestId,
    required int userGroupId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/Web/GetRequestInfo',
        queryParameters: {
          'empReqMasterID': empReqMasterId,
          'requestID': requestId,
          'userGroupId': userGroupId,
        },
      );
      return RequestInfo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<WorkflowListItem>> getWorkflows() async {
    try {
      final response = await _dio.get('/api/Web/GetWorkflows');
      final body = response.data;
      List<dynamic> list;
      if (body is Map<String, dynamic>) {
        list = (body['data'] ?? body['Data'] ?? []) as List;
      } else if (body is List) {
        list = body;
      } else {
        list = [];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map(WorkflowListItem.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<WorkflowDetails> getWorkflowById({required int id}) async {
    try {
      final response = await _dio.get(
        '/api/Web/GetWorkflowById',
        queryParameters: {'id': id},
      );

      return WorkflowDetails.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<WorkflowDropdowns> getWorkflowDropdowns({
    required int userGroupId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/Web/GetWorkflowDropdowns',
        queryParameters: {'userGroupId': userGroupId},
      );
      return WorkflowDropdowns.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> saveWorkflow(SaveWorkflowRequest request) async {
    try {
      await _dio.post('/api/Web/SaveWorkflow', data: request.toJson());
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> updateWorkflow(UpdateWorkflowRequest request) async {
    try {
      await _dio.put('/api/Web/UpdateWorkflow', data: request.toJson());
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> executeVacation(ExecuteVacationRequest request) async {
    try {
      await _dio.post('/api/Web/ExecuteVacation', data: request.toJson());
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> undoExecuteVacation(ExecuteVacationRequest request) async {
    try {
      await _dio.post('/api/Web/UndoExecuteVacation', data: request.toJson());
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
