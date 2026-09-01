import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/env/env.dart';
import 'core/router/app_router.dart';
import 'core/state/app_states.dart';
import 'core/state/state_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'firebase_options.dart';
import 'l10n/gen/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final container = ProviderContainer();
  _restoreSession(container);

  runApp(
    UncontrolledProviderScope(container: container, child: const SmartSpend()),
  );
}

/// Skips the login screen when Firebase Auth still holds a session from a
/// previous launch. Firebase Auth is the source of truth for the
/// session; this is a synchronous read of its current user, done once
/// before the first frame. With no session the app stays
/// [AppState.unauthenticated] and the router shows login as usual.
void _restoreSession(ProviderContainer container) {
  final user = container.read(getCurrentUserUseCaseProvider).call();
  if (user != null) {
    container
        .read(appStateProvider.notifier)
        .update(const AppState.authenticated());
  }
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
