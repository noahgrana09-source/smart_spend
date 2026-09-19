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
  (Drift SSOT + push best-effort a Firestore) — todavía **ningún feature lo
  implementa**; `onboarding` va a ser el primero (ver "Pendientes" abajo).
  La tabla `UserProfiles`/`UserProfileDao` ya existen, pensadas para
  `onboarding`, no para `auth`: `auth` decidió **no** usar persistencia
  local (ver bullet de `auth` más abajo y "Dual persistence" +
  "Technical decisions" en el `README.md` de raíz).
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
- `auth/`: autenticación, **completa** — email/password + Google, alta con
  verificación de email **obligatoria** (bloquea `AppState.authenticated`
  hasta que se confirme), cierre de sesión, borrado de cuenta. Sin
  persistencia local (decisión de seguridad — ver arriba). Detalle
  completo (árbol de directorios, decisiones técnicas, stack) en la
  sección "Features → auth" del `README.md` de raíz — no duplicar acá,
  ese es la fuente actualizada.
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

- **Reconciliación local↔remoto (offline-first).** `auth` quedó **afuera**
  de este patrón a propósito (borró toda su persistencia local — ver
  bullet de `auth` en "Estructura de directorios"): sus campos son
  sensibles y Firebase Auth/Firestore ya son la única fuente de verdad de
  la sesión, así que un cache local sin lector no se justificaba (quedaba
  como PII sin cifrar en Drift). Para los features que sí manejan datos
  propios de la app (no credenciales) — `onboarding` va a ser el primero,
  con `UserProfiles`/`UserProfileDao` ya armados para reusar — la
  estrategia cuando la persistencia local falle es **reconciliar por
  presencia**, no por tipo de error: al leer, si la fila no existe en
  Drift se rellena desde Firestore. Matices a cubrir en la implementación:
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
  - Implementar cuando llegue el primer feature que lo necesite —
    `onboarding` es el candidato actual (ver README, "Dual persistence").

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

## Estado actual del proyecto (2026-09-19)

- `pubspec.yaml` con **todas** las dependencias resolviendo limpio.
  Constraint del SDK Dart: `^3.11.1` (SDK global de la máquina, compartido
  con otros 3 proyectos de portfolio ya inactivos — no representa riesgo).
- `.env.example` con `GEMINI_API_KEY`, `FMP_API_KEY`,
  `STRIPE_PUBLISHABLE_KEY`. `.env` real existe local (vacío, gitignored).
- **`lib/core/` implementado** en todas sus carpetas (ver *Estructura de
  directorios*): env, error, network, router, state, theme, usecases,
  utils, widgets y database (Drift `AppDatabase`, `UserProfileDao` + tabla
  `UserProfiles` — reservados para `onboarding`, sin usar todavía — y el
  contrato `SyncRepository`, todavía sin implementar por ningún feature).
- **`lib/l10n/`**: bundle es/en montado, `MaterialApp.router` con los
  `localizationsDelegates` + `supportedLocales`.
- **`lib/main.dart` es solo un bootstrap** — carga `Env`, inicializa
  Firebase, `runApp()`. **Ya no tiene lógica de sesión** (esto cambió
  respecto a versiones anteriores de este doc, que decían que leía
  `resolveCurrentUserUseCaseProvider` antes de `runApp()` — quedó
  obsoleto). Cada feature que necesita decidir qué mostrar al arrancar
  tiene su propio widget "wrapper" en vez de que `main()` lo resuelva —
  `AuthWrapper` para `auth` — que resuelve *después* del primer frame
  (mostrando un spinner neutro mientras tanto, nunca la pantalla real, así
  no hay flash de contenido incorrecto). El patrón se espera repetir para
  los próximos features.
- **Feature `auth` — completa, incluye verificación de email obligatoria**
  (no solo login/signup/signout como en versiones anteriores de este doc).
  Detalle completo (árbol de directorios, todas las decisiones técnicas,
  stack) en la sección "Features → auth" del `README.md` de raíz — es la
  fuente actualizada, no duplicar acá. Puntos clave para orientarse rápido:
  - El alta (`submitSignUp`) no autentica directamente — pasa a
    `AuthState.verifying`; `AppState` sigue `unauthenticated` hasta que se
    confirma el email (botón "email verificado", o solo con reabrir la app
    si ya se verificó estando cerrada).
  - `AuthWrapper` decide entre `LoginScreen`/`EmailVerificationScreen` de
    forma reactiva según `AuthState`. `RegisterScreen` y
    `EmailVerificationScreen` no son rutas — se pushean sobre lo que
    `AuthWrapper` ya está mostrando.
  - **Sin persistencia local** (decisión de seguridad, no de performance):
    se borró `AuthLocalDataSource` entero — era best-effort, sin ningún
    lector, y guardaba PII (email, nombre, foto) sin cifrar en Drift.
    `AuthRepositoryImpl` ya no tiene una segunda dependencia además del
    datasource remoto.
  - `isEmailVerified` en Firestore se sincroniza (best-effort) cada vez
    que se recarga el usuario de Firebase Auth y sale `true` — sin esto,
    el Cloud Function de limpieza (ver abajo) podría borrar una cuenta que
    en realidad ya se verificó.
  - `deleteUnverifiedUsers` (Cloud Function programada, corre cada 24hs)
    borra cuentas con `isEmailVerified: false` en Firestore con más de 7
    días desde `createdAt` — de Firebase Auth y de Firestore.
  - `WatchCurrentUserUseCase` y toda su cadena (métodos de lectura del
    datasource local, `fetchUserProfile` remoto, `UserModel.fromFirestore`/
    `.fromDrift`) se borraron: cero consumidores reales.
  - `AutofillGroup` con hints `username`/`newUsername` (no solo `email`)
    para que el sistema ofrezca guardar contraseñas tipeadas a mano, no
    solo las autogeneradas por el gestor — limitación conocida de Flutter
    en Android, no 100% garantizada igual (ver comentarios en
    `login_screen.dart`/`register_screen.dart`).
- **Features `onboarding` y `portfolio`**: solo un stub de pantalla en
  `presentation/` cada uno. `account`, `ai_advisor`, `market` y `payment`
  todavía sin crear. `onboarding` es el próximo feature a implementar.
- **`assets/common_passwords.txt`**: blocklist de contraseñas (SecLists
  top 10k) para el aviso de fuerza en registro, cargado por
  `commonPasswordsProvider`.
- **`LICENSE`** (MIT) agregado en la raíz del repo.
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
  - `deleteUnverifiedUsers` (scheduled, v2): ver bullet de `auth` arriba.
  - Secrets en Secret Manager: `STRIPE_SECRET_KEY` y `STRIPE_WEBHOOK_SECRET`
    (ambos con valores reales, cargados y en uso).
  - Política de limpieza de Artifact Registry configurada en `us-central1`
    (borra imágenes de builds viejas a las 24hs) para no acumular costo de
    storage en cada deploy.
- Repo Git inicializado y subido a GitHub como privado (cuenta
  `noahgrana09-source`).

## Fuente

Detalle completo original en `context/SmartSpend.txt`.
