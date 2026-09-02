import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/platform_utils.dart';

/// Text button that switches between the login and register screens
/// (via `Navigator.push` / `Navigator.pop` — these two aren't routes on
/// the state-driven router).
class AuthModeLink extends StatelessWidget {
  const AuthModeLink({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return TextButton(onPressed: onPressed, child: Text(label));
  }
}
