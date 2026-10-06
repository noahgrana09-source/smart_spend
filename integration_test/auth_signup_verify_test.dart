import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smart_spend/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:smart_spend/features/auth/presentation/screens/login_screen.dart';
import 'package:smart_spend/features/onboarding/presentation/screens/get_you_started_screen.dart';
import 'package:smart_spend/firebase_options.dart';
import 'package:smart_spend/main.dart' as app;

/// Reaches the host machine's Firebase Emulator Suite from the Android
/// emulator this runs on. `10.0.2.2` is the special alias for that —
/// same host `main.dart`'s `useAuthEmulator`/`useFirestoreEmulator`
/// resolve `'localhost'` to automatically via the SDK's own host
/// mapping. `dio` has no such mapping, so this is spelled out by hand.
const _authEmulatorBaseUrl = 'http://10.0.2.2:9099';

/// Pumps until [finder] matches something, instead of a fixed pump
/// count. Needed for two independent reasons: `LoginScreen` and
/// `GetYouStartedScreen` carry looping Lottie animations (`repeat:
/// true`), so `pumpAndSettle` would hang forever on them; and this test
/// waits on real work (Firebase init, real network calls to the
/// emulator, a cold app launch on an emulated device) whose timing isn't
/// fixed the way a mocked widget test's is — a fixed pump count would
/// either waste time or flake under load.
Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  Duration step = const Duration(milliseconds: 250),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure(
    'Timed out after $timeout waiting for $finder to appear',
  );
}

/// Fetches the email-verification `oobCode` the Auth emulator generated
/// for [email] and applies it — the emulator's stand-in for "the user
/// clicked the link in their inbox", with no real email involved. This
/// is the same `identitytoolkit` `accounts:update` REST call
/// `FirebaseAuth.applyActionCode` makes under the hood against a real
/// project; the emulator implements it faithfully, so this is testing
/// the real confirmation path, just supplying the code a different way.
Future<void> _verifyEmailViaEmulator(String email) async {
  final dio = Dio();
  final projectId = DefaultFirebaseOptions.currentPlatform.projectId;

  final oobResponse = await dio.get<Map<String, dynamic>>(
    '$_authEmulatorBaseUrl/emulator/v1/projects/$projectId/oobCodes',
  );
  final codes = (oobResponse.data!['oobCodes'] as List)
      .cast<Map<String, dynamic>>();
  final oobCode =
      codes.lastWhere(
            (code) =>
                code['email'] == email && code['requestType'] == 'VERIFY_EMAIL',
          )['oobCode']
          as String;

  await dio.post<void>(
    '$_authEmulatorBaseUrl/identitytoolkit.googleapis.com/v1/accounts:update',
    queryParameters: {'key': 'fake-api-key'},
    data: {'oobCode': oobCode},
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'sign up, verify the email through the emulator (no real inbox), and '
    'land on onboarding',
    (tester) async {
      final email =
          'integration-test-${DateTime.now().millisecondsSinceEpoch}@example.com';
      const password = 'Str0ngPass!x9';

      // Real app, real Firebase (pointed at the local emulator via
      // --dart-define=USE_FIREBASE_EMULATOR=true — see main.dart).
      app.main();
      // Cold launch: Env.load + Firebase.initializeApp + AuthWrapper's
      // own boot-time session resolve all have to finish first.
      await _waitFor(tester, find.byType(LoginScreen));

      // LoginScreen -> RegisterScreen. The AVD's viewport is small enough
      // that the form scrolls — ensureVisible before every tap, same as
      // this repo's own widget tests already do for exactly this reason.
      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      final createAccountButton = find.widgetWithText(
        FilledButton,
        'Create account',
      );
      await _waitFor(tester, createAccountButton);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Integration Test',
      );
      await tester.enterText(find.byType(TextFormField).at(1), email);
      await tester.enterText(find.byType(TextFormField).at(2), password);
      await tester.enterText(find.byType(TextFormField).at(3), password);
      await tester.ensureVisible(createAccountButton);
      await tester.tap(createAccountButton);
      // A real Firebase Auth signup + Firestore profile write, not mocked.
      await _waitFor(tester, find.byType(EmailVerificationScreen));

      // Scoped to this screen's subtree — RegisterScreen's own email
      // field can still be mid-pop-transition in the same frame, and it
      // also contains the typed email as text.
      expect(
        find.descendant(
          of: find.byType(EmailVerificationScreen),
          matching: find.textContaining(email),
        ),
        findsOneWidget,
      );

      await _verifyEmailViaEmulator(email);

      final emailVerifiedButton = find.widgetWithText(
        FilledButton,
        'Email verified',
      );
      await tester.ensureVisible(emailVerifiedButton);
      await tester.tap(emailVerifiedButton);
      // Real reload against the emulator, then AppState -> authenticated
      // -> OnbWrapper's own real check (no local row yet) ->
      // GetYouStartedScreen, all driven by the actual app, nothing
      // stubbed.
      await _waitFor(tester, find.byType(GetYouStartedScreen));

      expect(find.byType(EmailVerificationScreen), findsNothing);
    },
  );
}
