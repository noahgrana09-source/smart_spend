// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [GoRouter]. Navigation between the three top-level screens
/// isn't driven by `GoRouter.redirect` — [AppStateListener] (wired as
/// `MaterialApp.router`'s `builder`) watches [appStateProvider] and calls
/// `.go(...)` on this router on every change. `go` always replaces the
/// stack, so e.g. an onboarded user can't hit "back" into login.
///
/// `initialLocation` reads the *current* [appStateProvider] value
/// (`ref.read`, not `ref.watch` — this provider is built once and
/// doesn't need to rebuild when the state changes later, that's what
/// [AppStateListener] is for) rather than assuming
/// [AppState.unauthenticated]. Nothing sets `appStateProvider` before
/// this router is first built anymore (`main()` is deliberately a
/// master key with no session logic — see its doc comment), so today
/// this always resolves to `/login`; the `ref.read` stays as the
/// correct general contract for whichever feature wrapper sets
/// `appStateProvider` next, at whatever point that happens to be.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The app's [GoRouter]. Navigation between the three top-level screens
/// isn't driven by `GoRouter.redirect` — [AppStateListener] (wired as
/// `MaterialApp.router`'s `builder`) watches [appStateProvider] and calls
/// `.go(...)` on this router on every change. `go` always replaces the
/// stack, so e.g. an onboarded user can't hit "back" into login.
///
/// `initialLocation` reads the *current* [appStateProvider] value
/// (`ref.read`, not `ref.watch` — this provider is built once and
/// doesn't need to rebuild when the state changes later, that's what
/// [AppStateListener] is for) rather than assuming
/// [AppState.unauthenticated]. Nothing sets `appStateProvider` before
/// this router is first built anymore (`main()` is deliberately a
/// master key with no session logic — see its doc comment), so today
/// this always resolves to `/login`; the `ref.read` stays as the
/// correct general contract for whichever feature wrapper sets
/// `appStateProvider` next, at whatever point that happens to be.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's [GoRouter]. Navigation between the three top-level screens
  /// isn't driven by `GoRouter.redirect` — [AppStateListener] (wired as
  /// `MaterialApp.router`'s `builder`) watches [appStateProvider] and calls
  /// `.go(...)` on this router on every change. `go` always replaces the
  /// stack, so e.g. an onboarded user can't hit "back" into login.
  ///
  /// `initialLocation` reads the *current* [appStateProvider] value
  /// (`ref.read`, not `ref.watch` — this provider is built once and
  /// doesn't need to rebuild when the state changes later, that's what
  /// [AppStateListener] is for) rather than assuming
  /// [AppState.unauthenticated]. Nothing sets `appStateProvider` before
  /// this router is first built anymore (`main()` is deliberately a
  /// master key with no session logic — see its doc comment), so today
  /// this always resolves to `/login`; the `ref.read` stays as the
  /// correct general contract for whichever feature wrapper sets
  /// `appStateProvider` next, at whatever point that happens to be.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'5405e2f5b6d9f9f0811fff7497d434435ce51dff';
