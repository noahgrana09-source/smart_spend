import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/env/env.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/gen/app_localizations.dart';

/// Master key only: loads config, initializes Firebase, and starts the
/// app. No session/auth logic here — each feature's own wrapper screen
/// (`AuthWrapper` for `auth`, and analogous ones for the features after
/// it) owns deciding what its area of the app should show at boot,
/// keeping that logic next to the feature it belongs to instead of
/// centralized here.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final container = ProviderContainer();

  runApp(
    UncontrolledProviderScope(container: container, child: const SmartSpend()),
  );
}

class SmartSpend extends ConsumerWidget {
  const SmartSpend({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) => AppStateListener(child: child),
    );
  }
}
