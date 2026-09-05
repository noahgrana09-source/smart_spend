import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/adaptive_progress_indicator.dart';

/// Full-width primary action button. [CupertinoButton.filled] on iOS,
/// [FilledButton] on Android. Shows a spinner in place of [label] while
/// [isLoading], and is non-interactive while loading or when [onPressed]
/// is null.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final spinnerColor = PlatformUtils.isCupertino
        ? CupertinoColors.white
        : Theme.of(context).colorScheme.onPrimary;
    final child = isLoading
        ? AdaptiveProgressIndicator(size: 20, color: spinnerColor)
        : Text(label);

    if (PlatformUtils.isCupertino) {
      return SizedBox(
        width: double.infinity,
        child: CupertinoButton.filled(
          onPressed: effectiveOnPressed,
          child: child,
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: FilledButton(onPressed: effectiveOnPressed, child: child),
    );
  }
}
