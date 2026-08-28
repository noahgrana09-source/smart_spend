import 'package:dio/dio.dart';

import '../error/failures.dart';

/// Translates a [DioException] into one of this app's [Failure] types, so
/// repositories can turn a failed network call into a `dartz` `Either`
/// without leaking `dio` types past the data layer.
abstract final class NetworkErrorMapper {
  static Failure map(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return NetworkFailure(
          code: exception.type.name,
          message: exception.message ?? 'Connection error.',
        );
      case DioExceptionType.badResponse:
        return ServerFailure(
          code: '${exception.response?.statusCode ?? 'unknown'}',
          message: exception.message ?? 'Server error.',
        );
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return NetworkFailure(
          code: exception.type.name,
          message: exception.message ?? 'Unexpected network error.',
        );
    }
  }
}
