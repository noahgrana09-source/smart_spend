import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed access to the environment variables loaded from `.env` via
/// `flutter_dotenv`.
///
/// Call [Env.load] once, before `runApp`, so every getter below is
/// guaranteed to return a real value.
abstract final class Env {
  /// Loads `.env` into memory. Must be awaited before any other member
  /// of this class is used.
  static Future<void> load() => dotenv.load();

  /// Key for Gemini (`google_generative_ai`), used by the AI advisor
  /// feature.
  static String get geminiApiKey => _require('GEMINI_API_KEY');

  /// Key for Financial Modeling Prep, used by the market feature.
  static String get fmpApiKey => _require('FMP_API_KEY');

  /// Stripe's publishable key. Safe to expose client-side by design —
  /// the secret key never leaves Cloud Functions.
  static String get stripePublishableKey =>
      _require('STRIPE_PUBLISHABLE_KEY');

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing "$key" in .env. Copy .env.example to .env and fill it in.',
      );
    }
    return value;
  }
}
