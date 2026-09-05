# SmartSpend

Flutter app (Android / iOS) for personal finance and investments: it shows
the user's portfolio and performance and gives buy / don't-buy style
recommendations through an LLM (Gemini), combining the user's risk profile,
a portfolio summary, and relevant news (RAG-lite). Premium is a one-time
USD 9.99 unlock (Stripe) after 3 free LLM queries.

Full product spec: `context/SmartSpend.txt`. Working context and current
state: `context/CLAUDE.md`.

## Architecture

- **Clean Architecture per feature** — `domain/` (contracts, pure Dart),
  `data/` (datasources + repository impl), `presentation/` (optional per
  feature). Fallible operations return `Either<Failure, T>` (dartz).
- **Riverpod** (`flutter_riverpod` + `riverpod_annotation` +
  `riverpod_generator`) for DI and state. `domain/` and `data/` stay
  Riverpod-free; each feature's `presentation/providers/` is its
  composition root.
- **State-driven navigation** — a global `AppState`
  (`unauthenticated → authenticated → onboarded`, plus `error`) in
  `lib/core/state`; `AppStateListener` (the `MaterialApp.router` builder)
  drives `go_router`. No `GoRouter.redirect`.
- **Dual persistence** — Drift/SQLite is the local source of truth for
  reads; Firestore is the remote copy for backup and multi-device sync
  (`lib/core/database/sync_repository.dart` is the contract).
- **Adaptive UI** — presentation widgets detect the OS and render Material
  or Cupertino; where Cupertino has no equivalent, Material imitates it.
- **l10n** — single bundle in `lib/l10n/` (es/en), keys prefixed per
  feature (`auth*`, `onboarding*`, …).

## Core (`lib/core/`)

`env` (typed `.env` access) · `error` (`Failure` hierarchy) · `network`
(`dio` client + `DioException → Failure` mapper) · `router` (state-driven
`go_router`) · `state` (`AppState` / `PaymentState` + notifiers) · `theme`
(`AppTheme`, brand green `0xFF0E9F6E`) · `usecases` (base contracts) ·
`utils` (platform detection) · `widgets` (shared adaptive widgets:
`AdaptiveProgressIndicator`, `LoadingOverlay`) · `database` (`AppDatabase`,
DAOs/tables, `SyncRepository`).

## Features (`lib/features/`)

### auth — done (domain + data + presentation)

Email/password and Google sign-in, sign-up, sign-out.

**Distribution**
- `domain/` — `AuthRepository` + use cases (`signInWithEmail`,
  `signInWithGoogle`, `signUpWithEmail`, `signOut`, `getCurrentUser`,
  `watchCurrentUser`).
- `data/` — `AuthRemoteDataSource` (Firebase Auth + Firestore, typed
  exceptions, rolls back a just-created account if the profile write
  fails), `AuthLocalDataSource` (Drift profile cache, best-effort, errors
  untyped), `AuthRepositoryImpl` (orchestrates both; caches on success,
  cache-aside backfill from Firestore).
- `presentation/` — `providers/` (composition root, `AuthNotifier`,
  `commonPasswordsProvider`), `auth_utils/` (pure validators, password
  strength, l10n message mapping), `widgets/` (adaptive), `screens/`
  (`LoginScreen`, `RegisterScreen`).

**Technical decisions**
- **State split**: the session's source of truth is the global `AppState`
  (Firebase Auth is authoritative). `AuthNotifier` holds only screen state
  (`AuthState`: normal / loading / error). A successful sign-in/up/out
  advances `AppState`; a failure stays local. `AppState.error` is reserved
  for session-level problems (involuntary sign-out, forced update). A
  cancelled Google prompt is a no-op.
- **Session restore**: `main()` reads `ResolveCurrentUserUseCase` before
  `runApp()` — if Firebase Auth has a persisted session it sets
  `AppState.authenticated`, so the router opens past login. Runs through
  keepAlive providers only; `AppStateNotifier` / `PaymentStateNotifier`
  are `keepAlive` precisely so this pre-frame write survives until the
  first build reads it. `ResolveCurrentUserUseCase` waits on
  `authStateChanges().first` rather than the synchronous `currentUser`,
  which can race ahead of Firebase's async session restoration.
- **`RegisterScreen` is not a route** — `LoginScreen` opens it with
  `Navigator.push` (adaptive page route); the state-driven router only
  knows `/login`, `/onboarding`, `/home`.
- **Password policy — NIST SP 800-63B**: no composition rules. Blocking:
  ≥ 8 chars, not derived from the email / app name / a trivial run, and
  not in the common-password blocklist (`assets/common_passwords.txt`,
  SecLists top 10k, via `commonPasswordsProvider`). On top, a non-blocking
  weak/strong hint below the field (length + character-variety score).
  Sign-in only checks the field is non-empty.
- **Drift cache is best-effort**: a cache failure never fails an auth
  result and its errors aren't typed. Broader local↔remote reconciliation
  is deferred to the first feature that needs it (see `context/CLAUDE.md`).

**Stack**: `firebase_auth`, `cloud_firestore`, `google_sign_in`, `drift`,
`flutter_riverpod` + `riverpod_annotation`, `freezed`, `dartz`,
`flutter_svg` (Google mark, inlined), `mocktail` (tests).

### onboarding, portfolio, account, ai_advisor, market, payment

Not started (onboarding and portfolio have a placeholder screen). The
Stripe backend for `payment` is already deployed — see
`functions/src/index.ts` and `context/CLAUDE.md`.

## Testing

`flutter test`. Coverage so far: the whole `auth` domain/data suite, plus
`presentation` (validators, password strength, `AuthNotifier` state
transitions, and widget tests for both screens). Widget tests exercise the
Material branch only — `PlatformUtils` reads `dart:io Platform`, so
`debugDefaultTargetPlatformOverride` doesn't flip it to Cupertino.
