import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend/features/auth/presentation/providers/auth_notifier.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Onboarding — pendiente'),
            const SizedBox(height: 24),
            // TEMPORARY: lets us bounce back to the auth screens to
            // eyeball them. Only flips the global state — the Firebase
            // session stays, so a cold start returns here. Remove when
            // the onboarding flow is real.
            OutlinedButton(
              onPressed: () => ref.read(authProvider.notifier).submitSignOut(),
              child: const Text('← Volver a auth (dev)'),
            ),
          ],
        ),
      ),
    );
  }
}
