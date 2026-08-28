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
/// `context.go(...)` on every change. `go` always replaces the stack, so
/// e.g. an onboarded user can't hit "back" into login.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The app's [GoRouter]. Navigation between the three top-level screens
/// isn't driven by `GoRouter.redirect` — [AppStateListener] (wired as
/// `MaterialApp.router`'s `builder`) watches [appStateProvider] and calls
/// `context.go(...)` on every change. `go` always replaces the stack, so
/// e.g. an onboarded user can't hit "back" into login.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's [GoRouter]. Navigation between the three top-level screens
  /// isn't driven by `GoRouter.redirect` — [AppStateListener] (wired as
  /// `MaterialApp.router`'s `builder`) watches [appStateProvider] and calls
  /// `context.go(...)` on every change. `go` always replaces the stack, so
  /// e.g. an onboarded user can't hit "back" into login.
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

String _$appRouterHash() => r'adcf8eab6c123a0bbe58c3b7743a86387b0e61d8';
