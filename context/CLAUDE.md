# SmartSpend — Contexto rápido

App Flutter que muestra finanzas/rendimiento de inversiones del usuario y da
recomendaciones (comprar/no comprar un activo, estructura de portafolio, etc.)
combinando datos personales del usuario (perfil de riesgo, ubicación, dinero
total) con investigación de noticias en línea, vía un LLM (Gemini).

## Permisos del agente en este proyecto

- **Comandos de lectura**: autorizados sin pedir confirmación (leer archivos,
  listar directorios, `git status`, `git log`, `git diff`, correr tests/lint
  de solo lectura, etc.).
- **Comandos de escritura** (crear/modificar/borrar archivos, editar código,
  correr `build_runner`, instalar dependencias, `git commit`/`push`, etc.):
  **siempre pedir confirmación antes de ejecutar**, incluso si parecen
  triviales.
- **Commits de git**: cuando se pida "escribir el commit", el agente
  redacta **solo el mensaje** como texto — nunca ejecuta `git add`,
  `git commit` ni ningún otro comando de git. El usuario revisa el diff y
  corre los comandos él mismo. Recién ejecutar si el usuario lo pide con un
  verbo explícito de acción (ej. "corré el commit", "hacé commit de esto").

## Flujo de uso (8 pasos)

1. **Onboarding y perfil de riesgo**: login con Firebase, el usuario define
   ubicación y completa un test de perfil inversor (Conservador/Moderado/
   Agresivo). Se persiste (ver paso 3).
2. **Gestión de cartera**: el usuario carga activos manualmente o sube un
   extracto de broker (CSV/JSON). Se genera un JSON resumen de cartera que se
   actualiza con cada cambio y se persiste (ver paso 3).
3. **Persistencia dual**: Drift/SQLite (local) + Firestore (remoto), en
   simultáneo. **Drift es la fuente preferida** para consultas en la app
   (SSOT local); Firestore es backup/fallback si algo falla localmente.
4. **Sincronización de métricas**: el usuario decide cuándo refrescar los
   gráficos; se consulta FMP (Financial Modeling Prep) vía `dio`.
5. **Consulta a la IA**: el usuario pregunta sobre sus inversiones.
6. **Generación de la respuesta**: RAG Lite — el LLM (Gemini, vía
   `google_generative_ai`) recibe un System Instruction que le pide revisar:
   prompt del usuario, reglas de respuesta, perfil inversor, resumen de
   cartera y noticias relevantes al prompt.
7. **Respuesta en streaming**: se renderiza palabra por palabra con
   `flutter_markdown_plus`, incluyendo disclaimer de responsabilidad al
   final.
8. **Paywall**: **3 consultas gratuitas por usuario**; al superarlas, Stripe
   (`flutter_stripe`, `PaymentSheet`) pide pago para Premium. El cambio de
   estado de cuenta se persiste de inmediato (ver paso 3). Se puede pasar a
   Premium en cualquier momento desde el paso 1 en adelante.

## Arquitectura

- **Clean Architecture** por feature: `domain`, `data`, `presentation`
  (presentation es opcional según el feature).
- **Riverpod** (`flutter_riverpod` + `riverpod_annotation` +
  `riverpod_generator`) para manejo de estado.
- **SOLID** en general.
- **l10n**: inglés y español.
- **UI adaptativa**: widgets en la capa de presentación detectan el SO y
  renderizan Material o Cupertino nativo. Si un widget no existe en
  Cupertino, se construye con Material imitando la apariencia Cupertino.
- **Plataformas**: solo Android e iOS (no hay carpetas `web`/`macos`/
  `linux`/`windows` en el repo).

## Estructura de directorios

`lib/core/`:
- `database/`: conexión única Drift/SQLite (`AppDatabase`), con `tables/` y
  `daos/` adentro; `sync_repository.dart` define el contrato offline-first
  (Drift SSOT + push best-effort a Firestore) que cada feature implementa.
- `env/`: acceso tipado a variables de entorno (`Env`, `flutter_dotenv`).
- `error/`: jerarquía `Failure` (dartz `Either`) — `ServerFailure`,
  `AuthFailure`, `GoogleSignInFailure`, `NetworkFailure`,
  `UserPersistenceFailure`.
- `network/`: `DioClient` (instancia `dio` compartida) + `NetworkErrorMapper`
  (`DioException` → `Failure`).
- `router/`: `GoRouter` (`go_router`). La navegación **no** usa
  `GoRouter.redirect`: `AppStateListener` (montado como `builder` de
  `MaterialApp.router`) observa `appStateProvider` y llama `context.go` en
  cada cambio de estado.
- `state/`: estados globales `freezed` (`AppState`, `PaymentState`) y sus
  notifiers Riverpod (`AppStateNotifier`, `PaymentStateNotifier`).
- `theme/`: `AppTheme` (light/dark) y `AppTextStyles`.
- `usecases/`: contratos base `UseCase` / `StreamUseCase` / `NoParams`.
- `utils/`: utilidades varias (por ahora, detección de plataforma).
- `widgets/`: widgets adaptativos compartidos entre features
  (`AdaptiveProgressIndicator`, `LoadingOverlay`).

`lib/l10n/`: bundle único de internacionalización es/en (`app_en.arb` /
`app_es.arb` + `l10n.yaml`, `generate: true`). Convención: claves con
prefijo por feature (`auth*`, `onboarding*`, …), sin prefijo solo lo
compartido. Generado en `lib/l10n/gen/`.

`lib/features/` (distribución y decisiones técnicas por feature +
stack: sección "Features" del `README.md` de raíz):
- `account/`: estado de cuenta.
- `ai_advisor/`: consultas al LLM.
- `auth/`: autenticación. Capas domain/data/presentation completas.
- `market/`: conexión con FMP para métricas de activos.
- `onboarding/`: nacionalidad + perfil de inversor.
- `payment/`: pago del plan Premium.
- `portfolio/`: portafolio de inversiones del usuario.

## Pantallas

1. **Login**: email/contraseña o Google OAuth.
2. **Onboarding**: aviso + botón para iniciar el test de perfil de inversor,
   luego el test, y selección de nacionalidad.
3. **Home**: barra de búsqueda de activos, gráficos del portafolio del
   usuario, botón para subir CSV/JSON. Si el usuario es nuevo (sin
   portfolio), el botón de subida reemplaza los gráficos en el centro.
   Sidebar izquierdo para navegar entre pantallas.
4. **LLM**: `TextField` para preguntarle al modelo; la respuesta se genera
   arriba, en streaming.
5. **Cuenta**: accesible desde el logo en la esquina superior derecha del
   AppBar de Home. Muestra datos básicos del usuario, botón de cambiar
   contraseña/cerrar sesión, e `IconButton` de configuración (l10n/theme).
6. **Planes**: muestra plan Estándar y Premium con descripción y compra. Al
   elegir Premium, un `ScrollView` en la misma pantalla revela el formulario
   de pago más abajo.

## Esquema de colores

Grises (blanco/claros en modo claro, negro/oscuros en modo oscuro) + un color
de marca verde para botones y elementos destacados. Verde de marca definido:
`AppTheme.brandGreen = 0xFF0E9F6E` (seed de `ColorScheme.fromSeed` en
`lib/core/theme/app_theme.dart`).

## Pendientes / decisiones de diseño

- **Reconciliación local↔remoto (offline-first).** En `auth` la DB local es
  best-effort: si la escritura en Drift falla, el login no falla igual
  (Firebase Auth/Firestore son la fuente de verdad) y **no se tipa el
  error** en el datasource local. Para el resto de los features, cuando la
  persistencia local falle la estrategia es **reconciliar por presencia**,
  no por tipo de error: al leer, si la fila no existe en Drift se rellena
  desde Firestore. Matices a cubrir en la implementación:
  - "Existe" no implica "está al día": la tabla lleva un marcador de
    frescura (`updatedAt` o una columna `dirty`/`pending`) para detectar
    filas desactualizadas por un update local fallido.
  - Igual hace falta **un** `try/catch` genérico (sin tipar) como fallback
    "lectura local falló → leo de remota", para el caso de DB corrupta.
  - La reconciliación se dispara en momentos definidos (arranque de app,
    login, pull-to-refresh, o caché local vacía), **nunca en cada lectura**
    (un read a Firestore por consulta choca con el enfoque offline-first y
    suma costo).
  - Vive una sola vez en `sync_repository.dart` / un helper compartido, no
    duplicada por feature.
  - Implementar cuando llegue el primer feature que lo necesite
    (`portfolio` / `account`).

## Dependencias por paso

**Paso 1**: `firebase_auth`, `google_sign_in`, `country_picker`,
`flutter_dotenv`.

**Paso 2**: `file_picker`, `csv`, `path_provider`.

**Paso 3**: `drift` + `sqlite3_flutter_libs` + `path`, `drift_dev` +
`build_runner` (dev), `cloud_firestore`. (Reemplaza a Isar — discontinuado,
incompatible con el toolchain moderno del proyecto.)

**Paso 4**: `dio`, `fl_chart`, `intl`.

**Pasos 5-7**: `google_generative_ai`, `flutter_markdown_plus` (reemplaza a
`flutter_markdown`, discontinuado).

**Paso 8**: `flutter_stripe`, `cloud_functions` (llama a una Cloud Function
que crea el PaymentIntent de Stripe; la secret key de Stripe vive solo en
Functions, nunca en el cliente — no está en el `.txt` original, se sumó al
decidir el approach de backend). Premium es **pago único** (no suscripción),
USD 9.99.

**Generales**: `firebase_core`, `flutter_svg` (logo Google), `flutter_riverpod`,
`riverpod_annotation`, `dartz`, `equatable`, `freezed_annotation`,
`json_annotation`, `cloud_firestore`, `flutter_localizations` (sdk) + `intl`.

**Dev**: `flutter_test`, `flutter_lints`, `build_runner`, `freezed`,
`json_serializable`, `riverpod_generator`, `mocktail`, `drift_dev`.

## Estado actual del proyecto (2026-09-01)

- `pubspec.yaml` con **todas** las dependencias resolviendo limpio. Sumadas
  desde el estado anterior: `go_router ^18`, `flutter_riverpod ^3.3` +
  `riverpod_annotation ^4` + `riverpod_generator ^4`. Constraint del SDK
  Dart: `^3.11.1` (SDK global de la máquina, compartido con otros 3
  proyectos de portfolio ya inactivos — no representa riesgo).
- `.env.example` con `GEMINI_API_KEY`, `FMP_API_KEY`,
  `STRIPE_PUBLISHABLE_KEY`. `.env` real existe local (vacío, gitignored).
- **`lib/core/` implementado** en todas sus carpetas (ver *Estructura de
  directorios*): env, error, network, router, state, theme, usecases,
  utils, widgets y database (Drift `AppDatabase`, `UserProfileDao` +
  tabla, y el contrato `SyncRepository`).
- **`lib/l10n/`**: bundle es/en montado, `MaterialApp.router` con los
  `localizationsDelegates` + `supportedLocales`.
- **`lib/main.dart`**: carga `Env`, inicializa Firebase, corre el
  bootstrap de sesión (lee `resolveCurrentUserUseCaseProvider` — espera a
  `authStateChanges().first` de Firebase — y si hay sesión pasa el
  `AppState` a `authenticated` antes del primer frame) y monta
  `UncontrolledProviderScope` + `MaterialApp.router` con `AppTheme` y
  `AppStateListener`. `AppStateNotifier` / `PaymentStateNotifier` son
  `keepAlive` para que ese write pre-frame no se pierda por autodispose.
- **Feature `auth`** — las 3 capas completas (detalle y decisiones en la
  sección "Features → auth" del `README.md` de raíz):
  - `domain/`: `UserEntity`, contrato `AuthRepository`, usecases
    `getCurrentUser`, `signInWithEmail`, `signInWithGoogle`, `signOut`,
    `signUpWithEmail`, `watchCurrentUser`.
  - `data/`: `UserModel` (freezed), `AuthRemoteDataSource` (Firebase Auth
    + Firestore, excepciones tipadas + rollback de cuenta), `AuthLocalDataSource`
    (caché Drift best-effort sin tipar) y `AuthRepositoryImpl` (orquesta
    ambos, cache-aside + backfill).
  - `presentation/`: `providers/` (composition root `auth_providers.dart`,
    `AuthNotifier`/`authProvider`, `commonPasswordsProvider`), `auth_utils/`
    (`auth_validators`, `password_strength` — política NIST 800-63B, sin
    reglas de composición; blocklist = aviso no bloqueante —, `auth_messages`),
    `widgets/` (adaptativos Material/Cupertino), `screens/` `LoginScreen` +
    `RegisterScreen` (esta última **no** es ruta del router; se abre con
    `Navigator.push`). Estado local `AuthState` (normal/loading/error);
    éxito mueve el `AppState` global, fallo queda local.
  - Tests: `domain` + `data` + `presentation` (validators, password_strength,
    notifier, widget tests de ambas pantallas).
- **Features `onboarding` y `portfolio`**: solo un stub de pantalla en
  `presentation/` cada uno. `account`, `ai_advisor`, `market` y `payment`
  todavía sin crear.
- **`assets/common_passwords.txt`**: blocklist de contraseñas (SecLists
  top 10k) para el aviso de fuerza en registro, cargado por
  `commonPasswordsProvider`.
- **Ramas**: `staging` es la rama de trabajo; `master` es la base para PRs.
- **Firebase (`smartspend-35d0e`) está en plan Blaze** (el upgrade desde
  Spark ya se hizo). Secret Manager y Cloud Functions con secrets
  funcionan sin bloqueo.
- **Backend de Stripe deployado y funcionando** en `functions/src/index.ts`
  (`us-central1`):
  - `createPremiumPaymentSheet` (callable, v2): verifica auth, crea/reusa
    el Stripe Customer del usuario (guardado en Firestore
    `users/{uid}.stripeCustomerId`), y devuelve `paymentIntentClientSecret`
    + `ephemeralKeySecret` + `customerId` para que el cliente abra el
    `PaymentSheet` de `flutter_stripe`. Monto fijo: USD 9.99 (999 centavos),
    pago único. Rechaza (`already-exists`) si el usuario ya es Premium.
  - `stripeWebhook` (https, v2): verifica la firma del evento y recién ahí
    persiste `isPremium: true` + `premiumSince` en Firestore al recibir
    `payment_intent.succeeded` — el estado Premium **no** lo setea el
    cliente directamente, para que no se pueda falsear un pago exitoso.
    URL: `https://us-central1-smartspend-35d0e.cloudfunctions.net/stripeWebhook`,
    registrado en el Dashboard de Stripe escuchando ese evento.
  - Secrets en Secret Manager: `STRIPE_SECRET_KEY` y `STRIPE_WEBHOOK_SECRET`
    (ambos con valores reales, cargados y en uso).
  - Política de limpieza de Artifact Registry configurada en `us-central1`
    (borra imágenes de builds viejas a las 24hs) para no acumular costo de
    storage en cada deploy.
- Repo Git inicializado y subido a GitHub como privado (cuenta
  `noahgrana09-source`).

## Fuente

Detalle completo original en `context/SmartSpend.txt`.
