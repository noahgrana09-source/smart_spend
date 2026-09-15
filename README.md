# SmartSpend

**Product spec:** Flutter app (Android / iOS) for personal finance and investments: it shows
the user's portfolio and performance and gives buy / don't-buy style
recommendations through an LLM (Gemini), combining the user's risk profile,
a portfolio summary, and relevant news (RAG-lite). Premium is a one-time
USD 9.99 unlock (Stripe) after 3 free LLM queries.

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
- **Adaptive theme** — `AppTheme` (`lib/core/theme/app_theme.dart`) builds a
  `light` and a `dark` `ThemeData` from the same
  `ColorScheme.fromSeed(seedColor: brandGreen)`, one per `Brightness`,
  sharing `AppTextStyles.textTheme`. `MaterialApp.router` (`lib/main.dart`)
  wires both (`theme` / `darkTheme`) with `themeMode: ThemeMode.system`, so
  the app follows the OS-level light/dark setting automatically — there is
  no in-app toggle or persisted override yet.
- **l10n** — single bundle in `lib/l10n/` (es/en), keys prefixed per
  feature (`auth*`, `onboarding*`, …).
- **Boot-time decisions live in the feature, not in `main()`** —
  `lib/main.dart` is a bootstrap-only "master key" (load `.env`, init
  Firebase, `runApp()`), with no session/auth logic of its own. Each
  feature that needs to decide what to show at boot owns its own wrapper
  screen instead (`AuthWrapper` for `auth`; the same pattern is meant to
  repeat for whichever feature needs it next). This trades away
  resolving before the first frame — see `AuthWrapper`'s own boot-time
  loading spinner in the `auth` section below.

## Project structure

```
smart_spend/
├── lib/
│   ├── core/               # see "Core" section right below for what's in each
│   │   ├── database/
│   │   ├── env/
│   │   ├── error/
│   │   ├── network/
│   │   ├── router/
│   │   ├── state/
│   │   ├── theme/
│   │   ├── usecases/
│   │   ├── utils/
│   │   └── widgets/
│   ├── features/
│   │   ├── account/       # not started
│   │   ├── ai_advisor/    # not started
│   │   ├── auth/          # done — see "Features → auth" below
│   │   ├── market/        # not started
│   │   ├── onboarding/    # placeholder screen only
│   │   ├── payment/       # not started (Stripe backend already deployed)
│   │   └── portfolio/     # placeholder screen only
│   ├── l10n/              # es/en ARB bundle + gen/
│   ├── firebase_options.dart
│   └── main.dart          # bootstrap only — see Architecture above
├── functions/             # Cloud Functions (Stripe backend, deleteUnverifiedUsers)
├── test/                  # mirrors lib/'s structure
├── assets/                # animations/, common_passwords.txt
├── context/               # CLAUDE.md, SmartSpend.txt — extended context
├── firestore.rules
├── firestore.indexes.json
└── firebase.json
```

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

Email/password and Google sign-in, sign-up gated behind mandatory email
verification, sign-out, account deletion.

**Directory structure** (`lib/features/auth/`)
```
auth/
├── domain/
│   ├── entities/
│   │   └── user_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── check_email_verified_usecase.dart
│       ├── delete_user_usecase.dart
│       ├── get_current_user_usecase.dart
│       ├── resend_email_verification_usecase.dart
│       ├── resolve_current_user_usecase.dart
│       ├── sign_in_with_email_usecase.dart
│       ├── sign_in_with_google_usecase.dart
│       ├── sign_out_usecase.dart
│       └── sign_up_with_email_usecase.dart
├── data/
│   ├── datasources/
│   │   ├── auth_local_datasource.dart
│   │   └── auth_remote_datasource.dart
│   ├── models/
│   │   └── user_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
└── presentation/
    ├── auth_utils/          # pure validators, password strength, l10n message mapping
    │   ├── auth_messages.dart
    │   ├── auth_validators.dart
    │   └── password_strength.dart
    ├── providers/            # composition root
    │   ├── auth_notifier.dart
    │   ├── auth_providers.dart
    │   ├── auth_state.dart
    │   └── common_passwords_provider.dart
    ├── screens/
    │   ├── auth_wrapper.dart              # boot-time gate for the `/login` route
    │   ├── email_verification_screen.dart
    │   ├── login_screen.dart
    │   └── register_screen.dart
    └── widgets/              # adaptive
        ├── auth_error_banner.dart
        ├── auth_mode_link.dart
        ├── auth_primary_button.dart
        ├── auth_text_field.dart
        ├── form_scaffold.dart
        ├── google_sign_in_button.dart
        └── password_strength_banner.dart
```

**Distribution**
- `domain/` — `AuthRepository` + use cases (`signInWithEmail`,
  `signInWithGoogle`, `signUpWithEmail`, `signOut`, `getCurrentUser`,
  `resolveCurrentUser`, `resendEmailVerification`, `checkEmailVerified`,
  `deleteUser`).
- `data/` — `AuthRemoteDataSource` (Firebase Auth + Firestore, typed
  exceptions, rolls back a just-created account if the profile write
  fails; also sends the verification email on sign-up, reloads/checks
  `emailVerified`, and deletes the Firebase Auth user + Firestore profile
  on `deleteUser`), `AuthLocalDataSource` (Drift profile cache — just
  `saveUser`/`clear`; write-only today, nothing reads it back yet),
  `AuthRepositoryImpl` (orchestrates both; local cache write is
  best-effort and never turns a successful remote result into a
  `Failure`).
- `presentation/` — `providers/` (`AuthNotifier`,
  `commonPasswordsProvider`), `auth_utils/`, `widgets/`, `screens/`
  (`AuthWrapper`, `LoginScreen`, `RegisterScreen`,
  `EmailVerificationScreen`).

**Technical decisions**
- **State split**: the session's source of truth is the global `AppState`
  (Firebase Auth is authoritative). `AuthNotifier` holds only screen state
  (`AuthState`: normal / loading / verifying / error). A successful
  sign-in/out advances `AppState` directly; a successful sign-up moves to
  `verifying` instead and only advances `AppState` once the email is
  confirmed verified. A failure stays local. `AppState.error` is reserved
  for session-level problems (involuntary sign-out, forced update). A
  cancelled Google prompt is a no-op.
- **Mandatory email verification**: `submitSignUp` no longer authenticates
  on success — it moves `AuthState` to `verifying(email)`.
  `RegisterScreen` reacts to that by popping itself (it's the screen
  `AuthWrapper` was already showing underneath, now swapped to
  `EmailVerificationScreen` — see below), which offers "email verified"
  (`checkEmailVerifiedNow`), "resend email", and "back to register"
  (`deleteUser`, cleaning up the abandoned unverified account, then
  pushes a fresh `RegisterScreen`). `AppState` stays `unauthenticated`
  the whole time.
- **`AuthWrapper` is `/login`'s boot-time gate, not `main()`** — `main()`
  has no session logic (see the root Architecture section). `AuthWrapper`
  resolves the persisted Firebase session after the first frame (showing
  a bare loading spinner meanwhile, never `LoginScreen`, to avoid
  flashing the login form at a returning, already-verified user right
  before routing past it), then either advances `AppState` to
  `authenticated`, calls `AuthNotifier.resumeVerifying` for an
  existing-but-unverified session, or leaves `AuthState` at its default
  `normal`. What it renders is driven reactively off `AuthState`
  (`normal` → `LoginScreen`, `verifying` → `EmailVerificationScreen`);
  `loading`/`error` are deliberately ignored so a screen already showing
  never gets ripped away mid-action (e.g. while one of
  `EmailVerificationScreen`'s own buttons is in flight).
- **`RegisterScreen`/`EmailVerificationScreen` aren't routes** — both are
  `Navigator.push`ed (adaptive page route) on top of whatever `AuthWrapper`
  is currently showing; the state-driven router only knows `/login`,
  `/onboarding`, `/home`. Gotcha found the hard way: `LoginScreen`'s
  post-push cleanup (`notifier.reset()`, meant to clear a stale error
  once `RegisterScreen` is popped) also fires when `RegisterScreen` pops
  itself after a *successful* sign-up — `Navigator.push`'s `Future`
  resolves on any pop, not just a cancelled one — so it now skips the
  reset when the state is `verifying`.
- **Firestore's `isEmailVerified` sync** — `AuthRemoteDataSource` only
  ever writes `isEmailVerified: false` at sign-up time; verifying happens
  by opening a link outside the app, so nothing else would ever update
  it. `reloadAndCheckEmailVerified` (the "email verified" button) and
  `resolveCurrentUser` (boot) both reload the Firebase user and
  best-effort sync a fresh `true` onto the Firestore profile through a
  shared helper — otherwise `deleteUnverifiedUsers` (below) could reap an
  account that's actually verified.
- **Password autofill / save** — `LoginScreen`/`RegisterScreen` wrap their
  fields in `AutofillGroup`, and pair each email field with a username
  hint (`AutofillHints.username` on `LoginScreen`, `.newUsername` on
  `RegisterScreen`, alongside `.email`) so the platform recognizes it and
  the password field(s) (`.password` / `.newPassword`, respectively) as
  one credential worth offering to save. Both screens call
  `TextInput.finishAutofillContext()` once their submit succeeds. Whether
  the "save password?" prompt actually appears is up to the OS's own
  autofill service, not the app — a known-flaky area of Flutter on
  Android, especially on emulators.
- **`deleteUnverifiedUsers`** (`functions/src/index.ts`, scheduled Cloud
  Function) — deletes any account still `isEmailVerified: false` in
  Firestore 7+ days after `createdAt`, both from Firebase Auth and
  Firestore, so an abandoned unverified sign-up doesn't permanently hold
  onto its email address.
- **Password policy — NIST SP 800-63B**: no composition rules. Blocking:
  ≥ 8 chars, not derived from the email / app name / a trivial run, and
  not in the common-password blocklist (`assets/common_passwords.txt`,
  SecLists top 10k, via `commonPasswordsProvider`). On top, a non-blocking
  weak/strong hint below the field (length + character-variety score).
  Sign-in only checks the field is non-empty.

**Stack**: `firebase_auth`, `cloud_firestore`, `google_sign_in`, `drift`,
`flutter_riverpod` + `riverpod_annotation`, `freezed`, `dartz`,
`flutter_svg` (Google mark, inlined), `lottie` (`FormScaffold`'s header
animation), `mocktail` (tests).

### onboarding, portfolio, account, ai_advisor, market, payment

Not started (onboarding and portfolio have a placeholder screen). The
Stripe backend for `payment` is already deployed — see
`functions/src/index.ts` and `context/CLAUDE.md`.

## Testing

`flutter test`. Coverage so far: the whole `auth` domain/data suite, plus
`presentation` (validators, password strength, `AuthNotifier` state
transitions including `verifying`/`resumeVerifying`, and widget tests for
every screen — including `AuthWrapper` itself and a dedicated integration
test that pumps `AuthWrapper` → `LoginScreen` → `RegisterScreen` end to
end to catch cross-widget navigation bugs unit tests in isolation would
miss). Also `test/core/router/` for the state-driven router/
`AppStateListener`. Widget tests exercise the Material branch only —
`PlatformUtils` reads `dart:io Platform`, so
`debugDefaultTargetPlatformOverride` doesn't flip it to Cupertino.

## License

MIT — see [LICENSE](LICENSE).
