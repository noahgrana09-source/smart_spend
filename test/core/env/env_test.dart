import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_spend/core/env/env.dart';

void main() {
  group('Env', () {
    tearDown(dotenv.clean);

    group('when .env is fully loaded', () {
      setUp(() {
        dotenv.loadFromString(
          envString: '''
            GEMINI_API_KEY=gemini-test-key
            FMP_API_KEY=fmp-test-key
            STRIPE_PUBLISHABLE_KEY=pk_test_123
            ''',
        );
      });

      test('geminiApiKey returns the loaded value', () {
        expect(Env.geminiApiKey, 'gemini-test-key');
      });

      test('fmpApiKey returns the loaded value', () {
        expect(Env.fmpApiKey, 'fmp-test-key');
      });

      test('stripePublishableKey returns the loaded value', () {
        expect(Env.stripePublishableKey, 'pk_test_123');
      });
    });

    group('when a key is missing from .env', () {
      setUp(() {
        dotenv.loadFromString(envString: 'FMP_API_KEY=fmp-test-key');
      });

      test('throws a StateError naming the missing key', () {
        expect(
          () => Env.geminiApiKey,
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('GEMINI_API_KEY'),
            ),
          ),
        );
      });
    });

    group('when a key is present but empty', () {
      setUp(() {
        dotenv.loadFromString(envString: 'GEMINI_API_KEY=');
      });

      test('throws a StateError', () {
        expect(() => Env.geminiApiKey, throwsA(isA<StateError>()));
      });
    });
  });
}
