// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_passwords_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Lower-cased set of common passwords, loaded once from
/// `assets/common_passwords.txt` (one per line, `#` lines ignored).
///
/// Feeds `AuthValidators.signUpPassword` so a weak choice is rejected
/// client-side, per NIST SP 800-63B (a blocklist instead of composition
/// rules). A missing or unreadable asset yields an empty set — the
/// length and identity checks still apply, the blocklist check just
/// becomes a no-op until the file is present.

@ProviderFor(commonPasswords)
final commonPasswordsProvider = CommonPasswordsProvider._();

/// Lower-cased set of common passwords, loaded once from
/// `assets/common_passwords.txt` (one per line, `#` lines ignored).
///
/// Feeds `AuthValidators.signUpPassword` so a weak choice is rejected
/// client-side, per NIST SP 800-63B (a blocklist instead of composition
/// rules). A missing or unreadable asset yields an empty set — the
/// length and identity checks still apply, the blocklist check just
/// becomes a no-op until the file is present.

final class CommonPasswordsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>
        >
    with $FutureModifier<Set<String>>, $FutureProvider<Set<String>> {
  /// Lower-cased set of common passwords, loaded once from
  /// `assets/common_passwords.txt` (one per line, `#` lines ignored).
  ///
  /// Feeds `AuthValidators.signUpPassword` so a weak choice is rejected
  /// client-side, per NIST SP 800-63B (a blocklist instead of composition
  /// rules). A missing or unreadable asset yields an empty set — the
  /// length and identity checks still apply, the blocklist check just
  /// becomes a no-op until the file is present.
  CommonPasswordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commonPasswordsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commonPasswordsHash();

  @$internal
  @override
  $FutureProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String>> create(Ref ref) {
    return commonPasswords(ref);
  }
}

String _$commonPasswordsHash() => r'4b5dd967f1865b6db4cd569a9808f0bf8029013f';
