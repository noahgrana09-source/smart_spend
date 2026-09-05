import 'package:flutter/material.dart';

import 'adaptive_progress_indicator.dart';

/// A full-bleed scrim with a centered spinner, shown while [visible].
///
/// Stack it as the top child of a screen that has an in-flight
/// operation: the scrim also absorbs input, which prevents a second
/// submit while the first is running. Renders nothing (and blocks
/// nothing) when [visible] is false.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return const Positioned.fill(
      child: ColoredBox(
        color: Colors.black54,
        child: Center(child: AdaptiveProgressIndicator()),
      ),
    );
  }
}
