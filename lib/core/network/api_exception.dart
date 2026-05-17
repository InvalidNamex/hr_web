import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        final cause = e.error?.toString() ?? '';
        if (cause.contains('CERTIFICATE') ||
            cause.contains('HandshakeException') ||
            cause.contains('tls') ||
            cause.contains('ssl')) {
          return ApiException('SSL certificate error. ($cause)');
        }
        return ApiException('Could not reach the server. Check your connection.\n$cause');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] as String? ??
            e.response?.data?['Message'] as String? ??
            'Server error ($statusCode)';
        return ApiException(message, statusCode: statusCode);
      default:
        return ApiException(e.message ?? 'Unexpected error.');
    }
  }

  @override
  String toString() => message;
}
