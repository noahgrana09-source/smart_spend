import 'dart:io';

/// Platform detection and adaptive widget selection utilities.
///
/// Decides between Cupertino (iOS) and Material (Android) widgets
/// based on the current platform, respecting each operating
/// system's native look & feel. SmartSpend only ships on Android and
/// iOS (see `context/CLAUDE.md`), so there's no web/desktop branching
/// here.
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
  /// `true` if the app is running on iOS.
  static bool get isIOS => Platform.isIOS;

  /// `true` if the app is running on Android.
  static bool get isAndroid => Platform.isAndroid;

  /// `true` if the app should use Cupertino (Apple) UI conventions.
  static bool get isCupertino => isIOS;

  /// `true` if the app should use Material (Google) UI conventions.
  static bool get isMaterial => isAndroid;
}
