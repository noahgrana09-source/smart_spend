# SmartSpend

**Product spec:** Flutter app (Android / iOS) for personal finance and investments: it shows
the user's portfolio and performance and gives buy / don't-buy style
recommendations through an LLM (Gemini), combining the user's risk profile,
a portfolio summary, and relevant news (RAG-lite). Premium is a one-time
USD 9.99 unlock (Stripe) after 3 free LLM queries.

## Architecture

- **Clean Architecture per feature** — `domain/` (contracts, pure Dart),
  `data/` (datasources + implemented repositories), `presentation/` (optional per
  feature). Fallible operations return `Either<Failure, T>` (dartz).
- **Riverpod** (`flutter_riverpod` + `riverpod_annotation` +
  `riverpod_generator`) for DI and state. `domain/` and `data/` stay
  Riverpod-free; each feature's `presentation/providers/` is its
  composition root.
- **State-driven navigation** — a global `AppState`
  (`unauthenticated → authenticated → onboarded`, plus `error`) in
  `lib/core/state`; `AppStateListener` (the `MaterialApp.router` builder)
  drives `go_router`. No `GoRouter.redirect`.
- **Dual persistence** — `lib/core/database/sync_repository.dart` is the
  intended contract for a feature whose data it owns/produces itself:
  Drift/SQLite as the local source of truth for reads, Firestore as the
  remote copy for backup and multi-device sync. `onboarding` is the first
  real user of the local side (risk profile, nationality — non-sensitive,
  app-produced, read on nearly every screen, so local-first pays for
  itself): its `UserProfiles` row is keyed by the Firebase `uid` and
  written/read through `UserProfileDao`. The Firestore push and the
  reconciliation strategy aren't implemented yet — onboarding currently
  writes Drift only. `auth` deliberately opts out: Firebase Auth/Firestore are
  themselves the only source of truth for a session, and its profile
  fields are sensitive enough that caching them in an unencrypted local
  database isn't worth it for a feature with no current reader — see
  "Technical decisions" under `auth` below. The `UserProfiles`
  table/`UserProfileDao` (`lib/core/database/`) exist already, kept for
  `onboarding` to build on rather than pulled in as auth-specific.
- **Adaptive UI** — presentation widgets detect the OS and render Material
  or Cupertino; where Cupertino has no equivalent, Material imitates it.
  Cupertino widgets ignore the Material `ThemeData`, so on iOS they'd fall
  back to Cupertino's system blue and background. `AppTheme.cupertino`
  derives a `CupertinoThemeData` from the active Material theme, and
  `MaterialApp.router`'s builder (`lib/main.dart`) wraps the app in it.
  Material inputs (`TextFormField`) also need a Material ancestor, which
  Cupertino pages don't provide — `FormScaffold` adds a transparent
  `Material` around its body on iOS for that reason.
- **Adaptive theme** — `AppTheme` (`lib/core/theme/app_theme.dart`) builds a
  `light` and a `dark` `ThemeData` from the same
  `ColorScheme.fromSeed(seedColor: brandGreen)`, one per `Brightness`,
  sharing `AppTextStyles.textTheme`. `MaterialApp.router` (`lib/main.dart`)
  wires both (`theme` / `darkTheme`) with `themeMode: ThemeMode.system`, so
  the app follows the OS-level light/dark setting automatically — there is
  no in-app toggle or persisted override.
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
│   │   ├── entities/      # shared across features (AppUserEntity, OnbDataEntity)
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
│   │   ├── onboarding/    # done — see "Features → onboarding" below
│   │   ├── payment/       # not started (Stripe backend already deployed)
│   │   └── portfolio/     # temporary debug Home only
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

`env` (typed `.env` access) · `entities` (domain entities read by more than
one feature: `AppUserEntity`, `OnbDataEntity`) · `error` (`Failure`
hierarchy, incl. `DatabaseFailure`) · `network` (`dio` client +
`DioException → Failure` mapper) · `router` (state-driven `go_router`) ·
`state` (`AppState` / `PaymentState` + notifiers) · `theme` (`AppTheme`,
brand green `0xFF0E9F6E`, plus the Cupertino mirror `AppTheme.cupertino`)
· `usecases` (base contracts) · `utils` (platform detection, with a
test-only `isIOSOverride` seam) · `widgets` (shared adaptive widgets:
`AdaptiveProgressIndicator`, `LoadingOverlay`, `MainAppButton`,
`AppErrorBanner`) · `database` (`AppDatabase`, DAOs/tables incl.
`UserProfileDao`, `SyncRepository`).

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
    └── widgets/              # adaptive (shared button/error banner live in core/widgets/)
        ├── auth_mode_link.dart
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
  on `deleteUser`), `AuthRepositoryImpl` (thin — maps exceptions to
  `Failure`, no local persistence of its own; see "Technical decisions"
  below).
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
- **iOS branch needs a Material ancestor for its fields** — `FormScaffold`
  renders a `CupertinoPageScaffold` on iOS, but `AuthTextField` is a Material
  `TextFormField`, which throws ("No Material widget found") without one.
  The Cupertino body is wrapped in a transparent `Material`. The host
  never takes this branch in tests, so `form_scaffold_ios_test.dart` forces
  it through `PlatformUtils.isIOSOverride`.
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
- **No local persistence** — `AuthRepositoryImpl` used to best-effort
  cache the signed-in user's profile (email, display name, photo URL,
  verification status) into a Drift table via an `AuthLocalDataSource`,
  write-only, with nothing ever reading it back. Removed: Firebase
  Auth/Firestore are already the only source of truth for a session (the
  cache was never consulted to decide whether a session exists —
  `resolveCurrentUser`/`getCurrentUser` always went to the remote data
  source), so it bought nothing, while sitting there as real user PII in
  an unencrypted local database (Drift/`sqlite3_flutter_libs` has no
  encryption-at-rest here) with no reader to justify the exposure. The
  underlying `UserProfiles` table and `UserProfileDao`
  (`lib/core/database/`) weren't deleted — they're earmarked for
  `onboarding`, whose data (risk profile, nationality) is app-produced
  rather than security-sensitive, and is the kind of thing local-first
  reads are actually meant for (see "Dual persistence" in Architecture).
  If `auth` ever needs an offline-readable profile again (e.g. a display
  name on `Home` without a network round-trip), it should be rebuilt
  scoped to exactly the non-sensitive fields that screen needs, not
  reintroduced wholesale.

**Stack**: `firebase_auth`, `cloud_firestore`, `google_sign_in`,
`flutter_riverpod` + `riverpod_annotation`, `freezed`, `dartz`,
`flutter_svg` (Google mark, inlined), `lottie` (`FormScaffold`'s header
animation), `mocktail` (tests).

### onboarding — done (domain + data + presentation)

Collects the user's nationality and investor risk profile after sign-in,
then persists both locally and advances `AppState` to `onboarded`.

**Flow**
1. `OnbWrapper` (`/onboarding`'s boot gate, same shape as `AuthWrapper`)
   checks for an existing `UserProfiles` row for the current `uid`. If one
   exists it advances `AppState` to `onboarded` straight away; otherwise it
   shows `GetYouStartedScreen`.
2. `GetYouStartedScreen` greets the user by name (`AppUserEntity`, via
   `GetCurrentUserUseCase`), shows a one-shot Lottie, and `pushReplacement`s
   to the next screen — nothing to go back to.
3. `PickNationalityScreen` — `OnbAdaptiveDropdown` fed by `country_picker`'s
   `CountryService` (used for its country data only, not its picker UI).
   "Next" stays disabled until a country is picked, then `push`es to the
   next screen so the user can go back.
4. `InvestorTestScreen` — five `OnbQuestionCard`s. Each option carries an
   integer risk point (1 = lowest, 4 = highest). A single-choice answer
   contributes its point; a multi-choice answer contributes the *average* of
   its selected points, so it stays on the same per-question scale. The
   overall score is the mean of the per-question averages, bucketed into
   three equal thirds: `conservative` ≤ 2 < `moderate` ≤ 3 < `aggressive`.
   The bucket is stored as a stable English code, not the localized label,
   because it's persisted and read by other features. The time-horizon
   question is deliberately inverted (a short horizon scores higher).
5. `OnbNotifier.submitSaveData` saves the nationality and profile
   (`SaveDataUseCase` → `OnbRepositoryImpl` → `OnbLocalDataSourceImpl` →
   `UserProfileDao`) and advances `AppState` to `onboarded`.

**Distribution**
- `domain/` — `OnbRepository` (`saveData`, `getCurrentUser`,
  `getLocalData`) and the use cases (`SaveDataUseCase`,
  `GetCurrentUserUseCase`, `GetLocalDataUseCase`). `getLocalData` returns
  `null`, not a `Failure`, when no row exists yet — that's the normal
  "not onboarded on this device" state.
- `data/` — `OnbLocalDataSourceImpl` (resolves the `uid` from
  `FirebaseAuth.currentUser` and goes through `UserProfileDao`; it has no
  Firebase Auth dependency beyond that), `OnbDataModel`, `OnbUserModel`,
  `OnbRepositoryImpl`.
- `presentation/` — `providers/` (`onb_providers.dart`: the DI wiring;
  `onb_notifier.dart`: `OnbNotifier`, the only piece that owns state
  transitions; `onb_state.dart`), `screens/`, `widgets/`
  (`OnbAdaptiveDropdown`, `OnbQuestionCard`).
- Shared entities live in `core/entities/` — `OnbDataEntity` and
  `AppUserEntity` — because `portfolio` reads them too.

**Technical decisions**
- `onboarding` doesn't import `auth`. It resolves `FirebaseAuth.instance`
  through its own provider, the same way it's duplicated elsewhere to keep
  features independent. Boot-time decisions stay in each feature's wrapper
  (`AuthWrapper`, `OnbWrapper`), not in `main()`.
- The `UserProfiles` table is keyed by `uid` and holds only `nationality` and
  `investorProfile`. Its schema was changed in place, so a device that
  already has the old table needs its app data cleared — the schema version
  wasn't bumped and there's no migration, which is fine while nothing has
  shipped.
- `DatabaseFailure` (local Drift errors) and `AuthFailure` are kept apart on
  purpose: the first is a persistence failure, the second is about the Firebase
  session.

**Temporary debug Home (`portfolio`)**
`portfolio`'s `HomeScreen` is a stand-in until the real home exists. It reads
back the signed-in user's `UserProfiles` row through
`GetLocalDataUseCase` to confirm the local database works end to end, and has
a "Log out" button: it awaits `FirebaseAuth.signOut()`, fires the Google
sign-out in the background, and sets `AppState` to `unauthenticated`.

**Stack**: `drift` (local profile), `country_picker` (country data),
`lottie` (`GetYouStartedScreen`'s animation).

### account, ai_advisor, market, payment

Not started. The Stripe backend for `payment` is already deployed — see
`functions/src/index.ts` and `context/CLAUDE.md`.

## Testing

`flutter test` runs unit and widget tests on the host. Coverage so far:
the whole `auth` domain/data suite, plus `presentation` (validators,
password strength, `AuthNotifier` state transitions including
`verifying`/`resumeVerifying`, and widget tests for every screen —
including `AuthWrapper` itself and a widget-level flow test that pumps
`AuthWrapper` → `LoginScreen` → `RegisterScreen` end to end). `onboarding`
has unit tests for its use cases and widget tests for its wrapper and
every screen. `test/core/router/` covers the state-driven router and
`AppStateListener`, and `test/core/theme/` covers the Cupertino theme
mirror.

`PlatformUtils` reads `dart:io Platform`, which the host can't override,
so tests that need the iOS branch set `PlatformUtils.isIOSOverride = true`
(`@visibleForTesting`, `null` in production). Keep this in mind when
adding a Cupertino-specific branch: a test that doesn't set it only ever
exercises the Material branch.

### Integration test against the Firebase Local Emulator Suite

`integration_test/auth_signup_verify_test.dart` runs the real app on an
Android emulator against the Firebase Auth and Firestore emulators: sign
up, verify the email, land on onboarding. No real inbox is involved — the
test reads the pending verification `oobCode` from the Auth emulator's REST
API and applies it, the same `accounts:update` call `applyActionCode` makes.

Setup and run:
1. Start the emulators (`firebase.json`'s `emulators` block: Auth on 9099,
   Firestore on 8080, UI on 4000): `firebase emulators:start --only
   auth,firestore`.
2. Start an Android emulator. On this machine, `-gpu swiftshader_indirect`
   was the only mode that stayed up; GPU passthrough and `hw.gpu.enabled =
   no` crashed the emulator once the app started rendering.
3. Run: `flutter test integration_test/auth_signup_verify_test.dart -d
   <device_id> --dart-define=USE_FIREBASE_EMULATOR=true`.

The `--dart-define` is what connects `main.dart` to the emulators
(`useAuthEmulator` / `useFirestoreEmulator`). It's never set in a real
build. `android/app/src/debug/` carries a `network_security_config.xml` that
allows cleartext HTTP to `10.0.2.2` and `localhost`, because the emulator
serves plain HTTP — that override lives under `src/debug/` only, so release
builds never get it.

Two rules the test relies on: it waits for the expected screen to appear
(`_waitFor`), not for a fixed number of frames, because the Lottie headers
loop and `pumpAndSettle` would never return; and it scopes text lookups to
the target screen, since a popped route can still be mid-transition.

## License

MIT — see [LICENSE](LICENSE).
