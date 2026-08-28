import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend/core/network/dio_client.dart';

void main() {
  group('DioClient', () {
    test('defaults connect/receive timeout to 15 seconds', () {
      final dio = DioClient.create();

      expect(dio.options.connectTimeout, const Duration(seconds: 15));
      expect(dio.options.receiveTimeout, const Duration(seconds: 15));
    });

    test('applies a custom timeout to both connect and receive', () {
      final dio = DioClient.create(timeout: const Duration(seconds: 5));

      expect(dio.options.connectTimeout, const Duration(seconds: 5));
      expect(dio.options.receiveTimeout, const Duration(seconds: 5));
    });

    test('adds a LogInterceptor only in debug mode', () {
      final dio = DioClient.create();

      final hasLogInterceptor = dio.interceptors
          .whereType<LogInterceptor>()
          .isNotEmpty;

      expect(hasLogInterceptor, kDebugMode);
    });

    test('returns a new Dio instance on every call', () {
      expect(DioClient.create(), isNot(same(DioClient.create())));
    });
  });
}
