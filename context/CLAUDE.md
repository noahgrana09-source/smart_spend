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
- `database/`: lógica de Drift y Firestore.
- `env/`: variables de entorno (`flutter_dotenv`).
- `error/`: `Failure`s propias para manejar errores con `dartz`.
- `l10n/`: internacionalización es/en.
- `network/`: conexiones REST con `dio`.
- `router/`: redirección según estado de autenticación.
- `theme/`: `ThemeData`, esquema de colores.
- `utils/`: utilidades varias (por ahora, de plataforma).

`lib/features/`:
- `account/`: estado de cuenta.
- `ai_advisor/`: consultas al LLM.
- `auth/`: autenticación.
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
de marca verde para botones y elementos destacados. **El hex exacto del verde
todavía no está definido** — pendiente de decidir durante el desarrollo del
theme.

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
decidir el approach de backend).

**Generales**: `firebase_core`, `flutter_svg` (logo Google), `flutter_riverpod`,
`riverpod_annotation`, `dartz`, `equatable`, `freezed_annotation`,
`json_annotation`, `cloud_firestore`, `flutter_localizations` (sdk) + `intl`.

**Dev**: `flutter_test`, `flutter_lints`, `build_runner`, `freezed`,
`json_serializable`, `riverpod_generator`, `mocktail`, `drift_dev`.

## Estado actual del proyecto (2026-08-22)

- `pubspec.yaml` tiene **todas** las dependencias de arriba agregadas y
  resolviendo limpio (`flutter pub get` sin conflictos).
- Flutter/Dart actualizados: Flutter 3.47.1 / Dart 3.13.1 (SDK global de la
  máquina, compartido con otros 3 proyectos de portfolio del usuario que ya
  no se tocan — no representa riesgo).
- `.env.example` creado con `GEMINI_API_KEY`, `FMP_API_KEY`,
  `STRIPE_PUBLISHABLE_KEY`. `.env` real existe local (vacío, gitignored).
- `lib/core/*` y `lib/features/*` siguen siendo carpetas vacías (todavía no
  se escribió código de `core/`). `lib/main.dart` solo inicializa Firebase
  con un Hello World.
- No hay `assets/` cargados todavía pese a estar declarado en `pubspec.yaml`.
- **Firebase (`smartspend-35d0e`) está en plan Spark**, bloqueado para usar
  Secret Manager/Cloud Functions con secrets hasta upgradear a Blaze
  (pay-as-you-go). El usuario está esperando para pagar ese upgrade; hasta
  entonces, la Cloud Function de Stripe (creación del PaymentIntent) queda
  pendiente de deploy — no bloquea el resto del desarrollo.
- Repo Git inicializado y subido a GitHub como privado (cuenta
  `noahgrana09-source`).

## Fuente

Detalle completo original en `context/SmartSpend.txt`.
