import 'package:flutter/services.dart' show rootBundle;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'common_passwords_provider.g.dart';

/// Lower-cased set of common passwords, loaded once from
/// `assets/common_passwords.txt` (one per line, `#` lines ignored).
///
/// Feeds `AuthValidators.signUpPassword` so a weak choice is rejected
/// client-side, per NIST SP 800-63B (a blocklist instead of composition
/// rules). A missing or unreadable asset yields an empty set — the
/// length and identity checks still apply, the blocklist check just
/// becomes a no-op until the file is present.
@Riverpod(keepAlive: true)
Future<Set<String>> commonPasswords(Ref ref) async {
  try {
    final raw = await rootBundle.loadString('assets/common_passwords.txt');
    return raw
        .split('\n')
        .map((line) => line.trim().toLowerCase())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toSet();
  } catch (_) {
    return const <String>{};
  }
}
