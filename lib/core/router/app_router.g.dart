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
/// [AppState.unauthenticated]. `main()` awaits its session-bootstrap
/// step before `runApp()`, so by the time this router is first built, a
/// restored session has already moved `appStateProvider` to
/// [AppState.authenticated] — hardcoding `unauthenticated` here would
/// always open on `/login` regardless.

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
/// [AppState.unauthenticated]. `main()` awaits its session-bootstrap
/// step before `runApp()`, so by the time this router is first built, a
/// restored session has already moved `appStateProvider` to
/// [AppState.authenticated] — hardcoding `unauthenticated` here would
/// always open on `/login` regardless.

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
  /// [AppState.unauthenticated]. `main()` awaits its session-bootstrap
  /// step before `runApp()`, so by the time this router is first built, a
  /// restored session has already moved `appStateProvider` to
  /// [AppState.authenticated] — hardcoding `unauthenticated` here would
  /// always open on `/login` regardless.
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

String _$appRouterHash() => r'e99a9e22606b68065abb1c622c1034601f09738a';
