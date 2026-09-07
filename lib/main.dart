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
  // Session bootstrap (composition root): if Firebase Auth has a
  // persisted session, start the app already authenticated so the router
  // opens past login. `resolveCurrentUser` waits on Firebase's own async
  // session restoration; `appStateProvider` is keepAlive, so this value
  // survives the gap until the first frame reads it. Onboarding will add
  // an analogous check here once it exists. Runs entirely through
  // keepAlive providers — no auto-disposing notifier's `ref` in play.
  //
  // `isEmailVerified` matters here: a signed-up-but-unverified account
  // has a perfectly valid persisted session, but must not skip past
  // login — otherwise killing the app while `EmailVerificationScreen` is
  // up (backgrounding it to open the verification link, say) and
  // relaunching would land straight on `authenticated` without ever
  // confirming verification.
  final restoredUser =
      await container.read(resolveCurrentUserUseCaseProvider).call();
  if (restoredUser != null && restoredUser.isEmailVerified) {
    container
        .read(appStateProvider.notifier)
        .update(const AppState.authenticated());
  }

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
