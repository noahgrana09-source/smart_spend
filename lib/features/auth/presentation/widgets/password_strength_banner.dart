import 'package:flutter/material.dart';

import '../auth_utils/password_strength.dart';

/// Non-blocking hint under the sign-up password field. Renders nothing
/// until the password is acceptable ([strength] non-null): red for a
/// weak password, green for a strong one. Sits below the field so it
/// doesn't shift what the user is typing.
class PasswordStrengthBanner extends StatelessWidget {
  const PasswordStrengthBanner({super.key, this.strength, this.message});

  final PasswordStrength? strength;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final strength = this.strength;
    final message = this.message;
    if (strength == null || message == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final (Color background, Color foreground, IconData icon) = switch (
      strength
    ) {
      PasswordStrength.weak => (
          scheme.errorContainer,
          scheme.onErrorContainer,
          Icons.info_outline,
        ),
      PasswordStrength.strong => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          Icons.check_circle_outline,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
