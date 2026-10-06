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
  String get authEmailVerificationTitle => 'Verificá tu correo';

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
  String authEmailVerificationDescription(String email) {
    return 'Te enviamos un link de verificación a $email. Revisá tu bandeja de entrada y, si no lo encontrás, buscá en la carpeta de spam.';
  }

  @override
  String get authEmailVerifiedButton => 'Correo verificado';

  @override
  String get authResendEmailButton => 'Reenviar correo';

  @override
  String get authBackToRegisterButton => 'Volver al registro';

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
  String get authErrorEmailNotVerified =>
      'Tu correo todavía no está verificado';

  @override
  String get authPasswordStrengthWeak => 'Contraseña débil';

  @override
  String get authPasswordStrengthStrong => 'Contraseña fuerte';

  @override
  String get onbDropdownDone => 'Listo';

  @override
  String onbGetStartedGreeting(String name) {
    return '¡Hola $name, empecemos!';
  }

  @override
  String get onbStartButton => 'Comenzar';

  @override
  String get onbPickNationalityTitle => 'Elegí tu nacionalidad';

  @override
  String get onbNationalityLabel => 'Nacionalidad';

  @override
  String get onbNextButton => 'Siguiente';

  @override
  String get onbFinishButton => 'Finalizar';

  @override
  String onbErrorGeneric(String title) {
    return 'Algo salió mal: $title. Probá de nuevo.';
  }

  @override
  String get onbTestTimeHorizonQuestion =>
      '¿Por cuánto tiempo planeás mantener este dinero invertido antes de necesitarlo?';

  @override
  String get onbTestTimeHorizonOption1 => 'Menos de 1 año';

  @override
  String get onbTestTimeHorizonOption2 => 'De 1 a 3 años';

  @override
  String get onbTestTimeHorizonOption3 => 'De 3 a 7 años';

  @override
  String get onbTestTimeHorizonOption4 => 'Más de 7 años';

  @override
  String get onbTestMarketDropQuestion =>
      'Tu portafolio cae un 20% en pocas semanas. ¿Qué hacés?';

  @override
  String get onbTestMarketDropOption1 => 'Vendo todo para evitar más pérdidas';

  @override
  String get onbTestMarketDropOption2 =>
      'Vendo una parte para reducir el riesgo';

  @override
  String get onbTestMarketDropOption3 =>
      'No hago nada y espero a que se recupere';

  @override
  String get onbTestMarketDropOption4 =>
      'Compro más aprovechando los precios bajos';

  @override
  String get onbTestGoalQuestion =>
      '¿Cuál es tu principal objetivo de inversión?';

  @override
  String get onbTestGoalOption1 => 'Preservar mi capital';

  @override
  String get onbTestGoalOption2 => 'Generar ingresos estables';

  @override
  String get onbTestGoalOption3 => 'Hacer crecer mi capital moderadamente';

  @override
  String get onbTestGoalOption4 => 'Maximizar el crecimiento a largo plazo';

  @override
  String get onbTestSituationQuestion =>
      '¿Cuáles de estas describen tu situación financiera? (Seleccioná todas las que apliquen)';

  @override
  String get onbTestSituationOption1 =>
      'Tengo un fondo de emergencia que cubre 3+ meses de gastos';

  @override
  String get onbTestSituationOption2 => 'Tengo ingresos estables y predecibles';

  @override
  String get onbTestSituationOption3 =>
      'Tengo otros ahorros o inversiones además de esto';

  @override
  String get onbTestSituationOption4 =>
      'Este dinero está destinado a un gasto próximo';

  @override
  String get onbTestExperienceQuestion =>
      '¿Cómo describirías tu experiencia invirtiendo?';

  @override
  String get onbTestExperienceOption1 => 'Ninguna, soy nuevo invirtiendo';

  @override
  String get onbTestExperienceOption2 => 'Alguna, entiendo lo básico';

  @override
  String get onbTestExperienceOption3 => 'Buena, sigo los mercados activamente';

  @override
  String get onbTestExperienceOption4 =>
      'Extensa, tengo experiencia avanzada o profesional';
}
