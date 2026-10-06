import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/env/env.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/gen/app_localizations.dart';

/// Set via `--dart-define=USE_FIREBASE_EMULATOR=true` — only passed when
/// running `integration_test/` against a local Firebase Emulator Suite
/// (`firebase emulators:start`, ports from `firebase.json`'s `emulators`
/// block). Never set for a real build, so this never ships.
const _useFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

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

  if (_useFirebaseEmulator) {
    // 'localhost' is deliberate, not a placeholder: the SDK's own
    // automatic host mapping rewrites it to '10.0.2.2' on Android (what
    // actually reaches the host machine from an emulator) and leaves it
    // alone everywhere else it would already work, e.g. iOS simulator.
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

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
      builder: (context, child) => CupertinoTheme(
        data: AppTheme.cupertino(Theme.of(context)),
        child: AppStateListener(child: child),
      ),
    );
  }
}
