// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get emailLabel => 'Correo';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get signInButton => 'Iniciar sesión';

  @override
  String get registerButton => 'Crear cuenta';

  @override
  String get googleButton => 'Continuar con Google';

  @override
  String get goToRegister => '¿No tenés cuenta? Registrate';

  @override
  String get goToLogin => '¿Ya tenés cuenta? Iniciá sesión';

  @override
  String get validationEmailEmpty => 'Ingresá tu correo';

  @override
  String get validationEmailInvalid => 'Ingresá un correo válido';

  @override
  String get validationPasswordEmpty => 'Ingresá tu contraseña';

  @override
  String validationPasswordTooShort(int min) {
    return 'La contraseña debe tener al menos $min caracteres';
  }

  @override
  String get validationNameEmpty => 'Ingresá tu nombre';

  @override
  String get validationConfirmPasswordEmpty => 'Repetí tu contraseña';

  @override
  String get validationConfirmPasswordMismatch =>
      'Las contraseñas no coinciden';

  @override
  String get errorInvalidCredentials => 'Correo o contraseña incorrectos';

  @override
  String get errorEmailAlreadyInUse => 'Ya existe una cuenta con este correo';

  @override
  String get errorGeneric => 'Algo salió mal. Probá de nuevo.';
}
