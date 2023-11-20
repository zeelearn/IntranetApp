import 'package:dio/dio.dart';

class LoginException implements Exception {
  String? message;

  LoginException({this.message});

  LoginException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = 'Request to API server was cancelled';
        break;
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout with API server';
        break;
      case DioExceptionType.unknown:
        message = 'Connection to API server fiailed due to internet connection';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Received timeout in connection with API server';
        break;
      case DioExceptionType.receiveTimeout:
        message = _handeError(dioError.response!.statusCode);
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout in connection with API server';
        break;
      default:
        message = 'Something went wrong';
        break;
    }
  }

  String _handeError(statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad Request';
      case 404:
        return 'The requested resources was not found';
      case 500:
        return 'Internal Server Error';
      default:
        return 'Internal Server Error';
    }
  }

  @override
  String toString() => message.toString();
}
