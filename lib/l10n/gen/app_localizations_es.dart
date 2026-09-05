// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get authLoginTitle => 'Iniciar sesión';

  @override
  String get authRegisterTitle => 'Crear cuenta';

  @override
  String get authEmailLabel => 'Correo';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authNameLabel => 'Nombre';

  @override
  String get authConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get authSignInButton => 'Iniciar sesión';

  @override
  String get authRegisterButton => 'Crear cuenta';

  @override
  String get authGoogleButton => 'Continuar con Google';

  @override
  String get authGoToRegisterPrompt => '¿No tenés cuenta?';

  @override
  String get authGoToRegisterAction => 'Registrate';

  @override
  String get authGoToLoginPrompt => '¿Ya tenés cuenta?';

  @override
  String get authGoToLoginAction => 'Iniciá sesión';

  @override
  String get authValidationEmailEmpty => 'Ingresá tu correo';

  @override
  String get authValidationEmailInvalid => 'Ingresá un correo válido';

  @override
  String get authValidationPasswordEmpty => 'Ingresá tu contraseña';

  @override
  String authValidationPasswordTooShort(int min) {
    return 'La contraseña debe tener al menos $min caracteres';
  }

  @override
  String get authValidationPasswordTooCommon =>
      'Esa contraseña es demasiado común, elegí otra';

  @override
  String get authValidationPasswordContainsIdentity =>
      'La contraseña no puede contener tu correo ni patrones obvios';

  @override
  String get authValidationNameEmpty => 'Ingresá tu nombre';

  @override
  String get authValidationConfirmPasswordEmpty => 'Repetí tu contraseña';

  @override
  String get authValidationConfirmPasswordMismatch =>
      'Las contraseñas no coinciden';

  @override
  String get authErrorInvalidCredentials => 'Correo o contraseña incorrectos';

  @override
  String get authErrorEmailAlreadyInUse =>
      'Ya existe una cuenta con este correo';

  @override
  String get authErrorGeneric => 'Algo salió mal. Probá de nuevo.';

  @override
  String get authPasswordStrengthWeak => 'Contraseña débil';

  @override
  String get authPasswordStrengthStrong => 'Contraseña fuerte';
}
