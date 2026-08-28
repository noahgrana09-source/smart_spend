import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Builds the [Dio] instance shared by every feature that talks to a REST
/// API (currently just `market`, via Financial Modeling Prep).
///
/// Centralizes timeouts and request/response logging. Logging is gated on
/// [kDebugMode] so API keys sent as query params never end up in release
/// logs.
abstract final class DioClient {
  static Dio create({Duration timeout = const Duration(seconds: 15)}) {
    final dio = Dio(
      BaseOptions(connectTimeout: timeout, receiveTimeout: timeout),
    );

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(responseBody: false));
    }

    return dio;
  }
}
