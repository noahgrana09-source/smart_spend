import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/core/network/network_error_mapper.dart';

void main() {
  final requestOptions = RequestOptions(path: '/test');

  group('NetworkErrorMapper', () {
    group('timeout and connection errors', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.transformTimeout,
        DioExceptionType.connectionError,
      ]) {
        test('maps $type to a NetworkFailure carrying its code', () {
          final exception = DioException(
            requestOptions: requestOptions,
            type: type,
            message: 'boom',
          );

          final failure = NetworkErrorMapper.map(exception);

          expect(failure, isA<NetworkFailure>());
          expect(failure.code, type.name);
          expect(failure.message, 'boom');
        });
      }

      test('falls back to a default message when none is provided', () {
        final exception = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionTimeout,
        );

        expect(NetworkErrorMapper.map(exception).message, 'Connection error.');
      });
    });

    group('badResponse', () {
      test('maps to a ServerFailure carrying the status code', () {
        final exception = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: requestOptions, statusCode: 404),
          message: 'Not found',
        );

        final failure = NetworkErrorMapper.map(exception);

        expect(failure, isA<ServerFailure>());
        expect(failure.code, '404');
        expect(failure.message, 'Not found');
      });

      test('uses "unknown" as the code when there is no status code', () {
        final exception = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
        );

        expect(NetworkErrorMapper.map(exception).code, 'unknown');
      });

      test('falls back to a default message when none is provided', () {
        final exception = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: requestOptions, statusCode: 500),
        );

        expect(NetworkErrorMapper.map(exception).message, 'Server error.');
      });
    });

    group('other errors', () {
      for (final type in [
        DioExceptionType.cancel,
        DioExceptionType.badCertificate,
        DioExceptionType.unknown,
      ]) {
        test(
          'maps $type to a NetworkFailure with a generic default message',
          () {
            final exception = DioException(
              requestOptions: requestOptions,
              type: type,
            );

            final failure = NetworkErrorMapper.map(exception);

            expect(failure, isA<NetworkFailure>());
            expect(failure.code, type.name);
            expect(failure.message, 'Unexpected network error.');
          },
        );
      }
    });
  });
}
