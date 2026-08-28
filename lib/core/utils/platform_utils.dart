import 'dart:io';

import 'package:flutter/foundation.dart';

/// Platform detection and adaptive widget selection utilities.
///
/// Decides between Cupertino (iOS) and Material (Android) widgets
/// based on the current platform, respecting each operating
/// system's native look & feel.
///
/// Usage example:
/// ```dart
/// if (PlatformUtils.isIOS) {
///   return CupertinoButton(...);
/// } else {
///   return ElevatedButton(...);
/// }
/// ```
abstract final class PlatformUtils {
  /// `true` if the app is running on iOS or macOS.
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// `true` if the app is running on Android.
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// `true` if the app is running on the web.
  static bool get isWeb => kIsWeb;

  /// `true` if the app is running on macOS.
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// `true` if the app should use Cupertino (Apple) UI conventions.
  ///
  /// Returns `true` on iOS and macOS.
  static bool get isCupertino => isIOS || isMacOS;

  /// `true` if the app should use Material (Google) UI conventions.
  ///
  /// Returns `true` on Android and Web.
  static bool get isMaterial => isAndroid || isWeb;
}
