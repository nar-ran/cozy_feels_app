// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get sectionCommon => '========== COMÚN / SISTEMA ==========';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_save => 'Guardar';

  @override
  String get common_accept => 'Aceptar';

  @override
  String get common_error => 'Ha ocurrido un error';

  @override
  String get common_back => 'Atrás';

  @override
  String get common_import => 'Importar';

  @override
  String get common_continue => 'Continuar';

  @override
  String get common_delete => 'Eliminar';

  @override
  String get sectionHome => '========== PANTALLA DE INICIO ==========';

  @override
  String get home_title => '¿Cómo te sientes hoy?';

  @override
  String get home_hint_text => 'Déjalo salir todo...';

  @override
  String get home_no_words_question => '¿Prefieres no usar palabras?';

  @override
  String get home_already_recorded => '¡Ya has registrado tu estado de ánimo de hoy!';

  @override
  String get sectionEditor => '========== EDITOR DE ÁNIMO ==========';

  @override
  String get editor_title => 'Editar Ánimo';

  @override
  String get editor_save_button => 'Guardar Cambios';

  @override
  String get editor_hint_empty => 'Escribe algo sobre tu día...';

  @override
  String get sectionHistory => '========== SECCIÓN DE HISTORIAL ==========';

  @override
  String get history_title => 'Historial';

  @override
  String get history_empty_state => 'Sin entradas aún...';

  @override
  String get history_no_words => 'Sin palabras hoy...';

  @override
  String get history_delete_confirm => '¿Eliminar este recuerdo?';

  @override
  String get sectionSettings => '========== AJUSTES Y BACKUP ==========';

  @override
  String get settings_export_title => 'Exportar Respaldo';

  @override
  String get settings_export_subtitle => 'Guarda tu historial en un archivo';

  @override
  String get settings_import_title => 'Importar Respaldo';

  @override
  String get settings_import_subtitle => 'Restaura tus sentimientos desde un archivo';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_current_language_label => 'Español';

  @override
  String get settings_import_success => '¡Recuerdos importados con éxito!';

  @override
  String get sectionPreview => '========== VISTA PREVIA DE IMPORTACIÓN ==========';

  @override
  String get import_preview_title => 'Vista Previa';

  @override
  String get import_preview_at_date => '¡Todo está al día!';

  @override
  String import_preview_found(int count) {
    return 'Se encontraron $count entradas nuevas:';
  }

  @override
  String get import_preview_empty => 'Sin palabras...';

  @override
  String import_preview_duplicate(int count) {
    return '$count días ya existen en tu historial y se omitirán.';
  }

  @override
  String get sectionTimezone => '========== SELECTOR DE ZONA HORARIA ==========';

  @override
  String get timezone_title => 'Seleccionar Zona';

  @override
  String get timezone_ny => 'Hora del Este (EE. UU./Canadá)';

  @override
  String get timezone_madrid => 'Europa Central (Madrid/París)';

  @override
  String get timezone_ba => 'Argentina / Brasil (Sur)';

  @override
  String get timezone_singapore => 'Singapur / Sudeste Asiático';

  @override
  String get timezone_london => 'Londres / Dublín (GMT)';

  @override
  String get sectionLanguage => '========== SELECTOR DE IDIOMA ==========';

  @override
  String get language_title => 'Seleccionar Idioma';

  @override
  String get sectionOnboarding => '========== BIENVENIDA ==========';

  @override
  String onboarding_guide_step(int current, int total) {
    return 'Guía $current/$total';
  }

  @override
  String get onboarding_next => 'Siguiente';

  @override
  String get onboarding_finish => '¡Entendido!';

  @override
  String get onboarding_step1 => 'Escribe (opcional) y TOCA UN EMOJI para guardar tu día.';

  @override
  String get onboarding_step2 => 'Desliza el historial y TOCA CUALQUIER ENTRADA para editar';

  @override
  String get onboarding_step3 => 'TOCA LA FECHA arriba para cambiar tu Zona Horaria.';
}
