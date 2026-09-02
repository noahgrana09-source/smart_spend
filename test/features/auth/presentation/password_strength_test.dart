import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend/features/auth/presentation/auth_utils/password_strength.dart';

void main() {
  const email = 'alice@example.com';

  group('evaluatePassword', () {
    test('returns null while the password is not acceptable', () {
      expect(evaluatePassword('', email: email, common: const {}), isNull);
      expect(
        evaluatePassword('aB3\$xy', email: email, common: const {}),
        isNull,
        reason: 'shorter than 8',
      );
      expect(
        evaluatePassword('alice12345', email: email, common: const {}),
        isNull,
        reason: 'derived from the email local-part',
      );
      expect(
        evaluatePassword(
          'trustno1x',
          email: email,
          common: const {'trustno1x'},
        ),
        isNull,
        reason: 'in the blocklist (blocked upstream by signUpPassword)',
      );
    });

    test('acceptable but low length/variety -> weak', () {
      expect(
        evaluatePassword('lowercased', email: email, common: const {}),
        PasswordStrength.weak,
      );
    });

    test('long passphrase -> strong', () {
      expect(
        evaluatePassword(
          'correct horse battery staple',
          email: email,
          common: const {},
        ),
        PasswordStrength.strong,
      );
    });

    test('12 chars with 3+ character classes -> strong', () {
      expect(
        evaluatePassword('Str0ngPass!x', email: email, common: const {}),
        PasswordStrength.strong,
      );
    });
  });
}
