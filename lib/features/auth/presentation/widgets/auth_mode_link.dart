import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// The "switch screens" line at the bottom of login / register: a plain
/// [prompt] in `colorScheme.primary` followed by the tappable [action]
/// in the brand color. Navigation is `Navigator.push` / `Navigator.pop`
/// — these two screens aren't routes on the state-driven router.
class AuthModeLink extends StatelessWidget {
  const AuthModeLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            prompt,
            style: baseStyle?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Text(
            action,
            style: baseStyle?.copyWith(
              color: AppTheme.brandGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
