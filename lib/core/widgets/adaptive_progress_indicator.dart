import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/platform_utils.dart';

/// A platform-native spinner: [CupertinoActivityIndicator] on iOS,
/// [CircularProgressIndicator] on Android. Shared by every feature's
/// loading states so they read the same on each OS.
class AdaptiveProgressIndicator extends StatelessWidget {
  const AdaptiveProgressIndicator({super.key, this.size, this.color});

  /// Side length in logical pixels. Falls back to each platform's own
  /// default when null.
  final double? size;

  /// Overrides the indicator color; defaults to the ambient color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoActivityIndicator(
        radius: (size ?? 20) / 2,
        color: color,
      );
    }
    final dimension = size ?? 36.0;
    return SizedBox(
      width: dimension,
      height: dimension,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: color == null ? null : AlwaysStoppedAnimation<Color>(color!),
      ),
    );
  }
}
