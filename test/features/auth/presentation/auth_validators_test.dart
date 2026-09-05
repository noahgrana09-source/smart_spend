import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend/features/auth/presentation/auth_utils/auth_validators.dart';

void main() {
  group('email', () {
    test('empty -> emailEmpty', () {
      expect(AuthValidators.email(''), AuthFieldError.emailEmpty);
      expect(AuthValidators.email('   '), AuthFieldError.emailEmpty);
      expect(AuthValidators.email(null), AuthFieldError.emailEmpty);
    });

    test('no @ or no domain -> emailInvalid', () {
      expect(AuthValidators.email('abc'), AuthFieldError.emailInvalid);
      expect(AuthValidators.email('a@b'), AuthFieldError.emailInvalid);
      expect(AuthValidators.email('a b@c.com'), AuthFieldError.emailInvalid);
    });

    test('well-formed -> null', () {
      expect(AuthValidators.email('user@example.com'), isNull);
      expect(AuthValidators.email('  user@example.com  '), isNull);
    });
  });

  group('signInPassword', () {
    test('empty -> passwordEmpty', () {
      expect(AuthValidators.signInPassword(''), AuthFieldError.passwordEmpty);
      expect(AuthValidators.signInPassword(null), AuthFieldError.passwordEmpty);
    });

    test('any non-empty value passes (no policy on sign-in)', () {
      expect(AuthValidators.signInPassword('x'), isNull);
      expect(AuthValidators.signInPassword('short'), isNull);
    });
  });

  group('signUpPassword', () {
    const common = {'password123', 'letmein12'};
    const email = 'alice@example.com';

    test('empty -> passwordEmpty', () {
      expect(
        AuthValidators.signUpPassword(
          '',
          email: email,
          commonPasswords: common,
        ),
        AuthFieldError.passwordEmpty,
      );
    });

    test('fewer than 8 chars -> passwordTooShort', () {
      expect(
        AuthValidators.signUpPassword(
          'aB3\$xyz',
          email: email,
          commonPasswords: common,
        ),
        AuthFieldError.passwordTooShort,
      );
    });

    test('contains the email local-part -> passwordContainsIdentity', () {
      expect(
        AuthValidators.signUpPassword(
          'alice-secret-9',
          email: email,
          commonPasswords: common,
        ),
        AuthFieldError.passwordContainsIdentity,
      );
    });

    test('trivial ascending run -> passwordContainsIdentity', () {
      expect(
        AuthValidators.signUpPassword(
          '12345678',
          email: 'x@y.com',
          commonPasswords: const {},
        ),
        AuthFieldError.passwordContainsIdentity,
      );
    });

    test('single repeated character -> passwordContainsIdentity', () {
      expect(
        AuthValidators.signUpPassword(
          'aaaaaaaa',
          email: 'x@y.com',
          commonPasswords: const {},
        ),
        AuthFieldError.passwordContainsIdentity,
      );
    });

    test('in the blocklist (case-insensitive) -> passwordTooCommon', () {
      expect(
        AuthValidators.signUpPassword(
          'Password123',
          email: email,
          commonPasswords: common,
        ),
        AuthFieldError.passwordTooCommon,
      );
    });

    test('long, unique, not blocked -> null', () {
      expect(
        AuthValidators.signUpPassword(
          'tR9\$mk-qp2z',
          email: email,
          commonPasswords: common,
        ),
        isNull,
      );
    });
  });

  group('name', () {
    test('empty -> nameEmpty', () {
      expect(AuthValidators.name(''), AuthFieldError.nameEmpty);
      expect(AuthValidators.name('  '), AuthFieldError.nameEmpty);
    });

    test('non-blank -> null', () {
      expect(AuthValidators.name('Alice'), isNull);
    });
  });

  group('confirmPassword', () {
    test('empty -> confirmPasswordEmpty', () {
      expect(
        AuthValidators.confirmPassword('', 'secret12'),
        AuthFieldError.confirmPasswordEmpty,
      );
    });

    test('mismatch -> confirmPasswordMismatch', () {
      expect(
        AuthValidators.confirmPassword('secret12', 'secret34'),
        AuthFieldError.confirmPasswordMismatch,
      );
    });

    test('match -> null', () {
      expect(AuthValidators.confirmPassword('secret12', 'secret12'), isNull);
    });
  });
}
