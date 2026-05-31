// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get done => 'Hecho';

  @override
  String get next => 'Siguiente';

  @override
  String get skip => 'Omitir';

  @override
  String get grant => 'Conceder';

  @override
  String get change => 'Cambiar';

  @override
  String get clear => 'Limpiar';

  @override
  String get import => 'Importar';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get expense => 'Gasto';

  @override
  String get income => 'Ingreso';

  @override
  String get both => 'Ambos';

  @override
  String get recurring => 'Recurrente';

  @override
  String get daily => 'Diario';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get annually => 'Anual';

  @override
  String get search => 'Buscar';

  @override
  String get settings => 'Configuración';

  @override
  String get history => 'Historial';

  @override
  String get budget => 'Presupuesto';

  @override
  String get currency => 'Moneda';

  @override
  String get categories => 'Categorías';

  @override
  String get version => 'Versión';

  @override
  String get auto => 'Auto';

  @override
  String get noCategory => 'Sin categoría';

  @override
  String get selectCategory => 'Seleccionar categoría';

  @override
  String get setBudget => 'Establecer presupuesto';

  @override
  String get homeSearchHint => 'Buscar transacciones…';

  @override
  String get homeAllWallets => 'Todas las carteras';

  @override
  String get homeSwitchWallet => 'Cambiar cartera';

  @override
  String get homeWallet => 'Cartera';

  @override
  String get homePreviousMonth => 'Mes anterior';

  @override
  String get homeNextMonth => 'Mes siguiente';

  @override
  String get homeTapReturnCurrentMonth => 'Toca para volver al mes actual';

  @override
  String get homeNoBudget => 'Sin presupuesto establecido.';

  @override
  String homeRemainingThisMonth(int percent) {
    return 'restante este mes · $percent% gastado';
  }

  @override
  String homeOverBudget(int percent) {
    return 'sobre el presupuesto · $percent% gastado';
  }

  @override
  String homeCarryOver(String amount) {
    return '+ $amount trasladado del mes pasado';
  }

  @override
  String get homeNoTransactions =>
      'Sin transacciones aún.\nToca + para añadir una.';

  @override
  String get homeNoTransactionsDay => 'Sin transacciones en este día.';

  @override
  String get homeNoTransactionsCategory =>
      'Sin transacciones en esta\ncategoría para este período.';

  @override
  String get homeByDay => 'Por día';

  @override
  String get homeByCategory => 'Por categoría';

  @override
  String get homeDeleteTitle => '¿Eliminar transacción?';

  @override
  String homeDeleteMessage(String description) {
    return '\"$description\" se eliminará permanentemente.';
  }

  @override
  String get homeSeeAll => 'Ver todo';

  @override
  String get homeRecentTransactions => 'Transacciones recientes';

  @override
  String get budgetRemaining => 'restante';

  @override
  String get budgetSpent => 'Gastado';

  @override
  String budgetPercentUsed(String percent) {
    return '$percent% usado';
  }

  @override
  String get budgetNoSet => 'Sin presupuesto establecido para este mes.';

  @override
  String setBudgetForPeriod(String period) {
    return 'Establecer presupuesto para $period';
  }

  @override
  String get setBudgetHint =>
      'Este es el importe total que quieres controlar este mes.';

  @override
  String get setBudgetAmount => 'Importe del presupuesto';

  @override
  String get setBudgetEnterAmount => 'Introduce un importe';

  @override
  String get setBudgetValidAmount => 'Introduce un importe válido';

  @override
  String get setBudgetSave => 'Guardar presupuesto';

  @override
  String get historyMonth => 'Mes';

  @override
  String get historyYear => 'Año';

  @override
  String get transactionTitleEdit => 'Editar transacción';

  @override
  String get transactionTitleNew => 'Nueva transacción';

  @override
  String get transactionValidAmount => 'Introduce un importe válido.';

  @override
  String get transactionAddDescription => 'Añade una descripción.';

  @override
  String get transactionSelectCategory => 'Selecciona una categoría.';

  @override
  String get transactionRepeats => 'Se repite';

  @override
  String get transactionDescription => 'Descripción';

  @override
  String get transactionFrequent => 'FRECUENTE';

  @override
  String get transactionNewCategory => 'Nueva';

  @override
  String get transactionEnterCategoryName => 'Introduce un nombre de categoría';

  @override
  String transactionAddFieldsTooltip(String fields) {
    return 'Añade $fields para continuar';
  }

  @override
  String transactionRuleInfo(String keyword) {
    return 'Regla: $keyword  •  toca para editar';
  }

  @override
  String get transactionDeleteTitle => '¿Eliminar transacción?';

  @override
  String transactionDeleteMessage(String description) {
    return '\"$description\" se eliminará permanentemente.';
  }

  @override
  String get transactionDeleteRecurringTitle =>
      'Eliminar transacción recurrente';

  @override
  String get transactionDeleteRecurringQuestion => '¿Cómo quieres eliminarla?';

  @override
  String get transactionDeleteOnlyThis => 'Solo esta';

  @override
  String get transactionDeleteThisAndFuture => 'Esta y las futuras';

  @override
  String get categoriesNoExpense => 'Sin categorías de gasto aún.';

  @override
  String get categoriesNoIncome => 'Sin categorías de ingreso aún.';

  @override
  String categoriesActiveCount(int count) {
    return '$count activas';
  }

  @override
  String categoriesUnusedHeader(int count) {
    return 'SIN USO ESTE MES · $count';
  }

  @override
  String get categoriesUnused => 'sin uso';

  @override
  String categoriesPercentSpend(String percent) {
    return '$percent% del gasto';
  }

  @override
  String get editCategoryTitleEdit => 'Editar categoría';

  @override
  String get editCategoryTitleAdd => 'Añadir categoría';

  @override
  String get editCategoryName => 'Nombre';

  @override
  String get editCategoryUsedFor => 'Usada para';

  @override
  String get editCategoryColour => 'Color';

  @override
  String get editCategoryIcon => 'Icono';

  @override
  String get editCategoryChartNote =>
      'El color de la barra del gráfico es gestionado por el tema para las categorías integradas.';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsMonthStartsOn => 'El mes empieza el';

  @override
  String settingsMonthStartDay(int day, String ordinal) {
    return 'Día $day$ordinal';
  }

  @override
  String get settingsDaysFebNote =>
      'Los días 29-31 no están disponibles para garantizar la compatibilidad con febrero.';

  @override
  String get settingsDefaultMonthlyBudget =>
      'Presupuesto mensual predeterminado';

  @override
  String get settingsNotSet => 'No establecido';

  @override
  String get settingsManageCategories => 'Gestionar categorías';

  @override
  String get settingsWallets => 'Carteras';

  @override
  String get settingsManageWallets => 'Gestionar carteras';

  @override
  String get settingsAutomations => 'Automatizaciones';

  @override
  String get settingsData => 'Datos';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsDeveloperTools => 'Herramientas de desarrollador';

  @override
  String get settingsDangerZone => 'Zona de peligro';

  @override
  String get settingsResetApp => 'Restablecer aplicación';

  @override
  String get settingsResetAppDesc =>
      'Borrar todas las transacciones y presupuestos, restaurar valores predeterminados';

  @override
  String get settingsSelectCurrency => 'Seleccionar moneda';

  @override
  String get settingsMonthStartOnDay => 'El mes empieza el día…';

  @override
  String get settingsResetTitle => '¿Restablecer la aplicación?';

  @override
  String get settingsResetMessage =>
      'Esto eliminará permanentemente:\n  • Todas las transacciones\n  • Todos los presupuestos\n  • Todas las categorías personalizadas\n\nLa configuración se restaurará a los valores predeterminados y se cerrará tu sesión de Google. Inicia sesión de nuevo para restaurar desde una copia de seguridad.\n\nEsto no se puede deshacer.';

  @override
  String get settingsResetConfirm => 'Restablecer todo';

  @override
  String get settingsChangeStartDayTitle => '¿Cambiar el día de inicio?';

  @override
  String settingsChangeStartDayMessage(int from, int to) {
    return 'Cambiar del día $from al día $to desplazará los límites del período para todos los meses. Las transacciones existentes permanecen igual.';
  }

  @override
  String get settingsBackupToDrive => 'Hacer copia en Google Drive';

  @override
  String get settingsSignInForBackup =>
      'Inicia sesión para activar la copia de seguridad';

  @override
  String settingsLastBackup(String time) {
    return 'Última copia: $time';
  }

  @override
  String get settingsNoBackupYet => 'Sin copia de seguridad aún';

  @override
  String get settingsBackupNow => 'Hacer copia ahora';

  @override
  String get settingsRestoreFromDrive => 'Restaurar desde Drive';

  @override
  String get settingsRestoreFromDriveDesc =>
      'Reemplazar datos locales con la copia de Drive';

  @override
  String get settingsSignOut => 'Cerrar sesión';

  @override
  String get settingsBackupSaved => 'Copia guardada en Google Drive.';

  @override
  String get settingsBackupNoChanges =>
      'Sin cambios desde la última copia — omitido.';

  @override
  String settingsBackupFailed(String error) {
    return 'Error en la copia: $error';
  }

  @override
  String settingsListBackupsFailed(String error) {
    return 'No se pudieron listar las copias: $error';
  }

  @override
  String get settingsNoBackupFound =>
      'No se encontró copia de seguridad en Google Drive.';

  @override
  String get settingsReplaceLocalTitle =>
      '¿Reemplazar todos los datos locales?';

  @override
  String get settingsReplaceLocalMessage =>
      'Restaurar desde Google Drive eliminará permanentemente todo en este dispositivo — todas las transacciones, presupuestos y categorías — y lo reemplazará con la copia de seguridad.\n\nEsto no se puede deshacer.';

  @override
  String get settingsReplaceMyData => 'Reemplazar mis datos';

  @override
  String get settingsDataRestored => 'Datos restaurados desde Google Drive.';

  @override
  String settingsRestoreFailed(String error) {
    return 'Error al restaurar: $error';
  }

  @override
  String get settingsSelectBackup => 'Seleccionar copia para restaurar';

  @override
  String get settingsExportBackup => 'Exportar copia de seguridad';

  @override
  String get settingsExportBackupDesc =>
      'Guardar todos los datos como archivo JSON';

  @override
  String get settingsRestoreFromFile => 'Restaurar desde archivo';

  @override
  String get settingsRestoreFromFileDesc =>
      'Reemplazar datos locales con una copia exportada';

  @override
  String settingsExportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String settingsCannotReadFile(String error) {
    return 'No se puede leer el archivo: $error';
  }

  @override
  String get settingsImportTitle => '¿Importar copia de seguridad?';

  @override
  String settingsImportFound(int transactions, int budgets, int categories) {
    return 'Encontrado:\n  • $transactions transacciones\n  • $budgets presupuestos\n  • $categories categorías\n\nEsto reemplazará todos los datos locales. No se puede deshacer.';
  }

  @override
  String get settingsImportConfirm => 'Importar';

  @override
  String settingsImportDone(int count) {
    return 'Se importaron $count transacciones correctamente.';
  }

  @override
  String settingsImportFailed(String error) {
    return 'Error al importar: $error';
  }

  @override
  String get settingsSmsRules => 'Reglas SMS';

  @override
  String get settingsSmsRulesDesc =>
      'Crear transacciones automáticamente desde mensajes entrantes';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeAuto => 'Auto';

  @override
  String get settingsCarryOver => 'Trasladar presupuesto no utilizado';

  @override
  String get settingsCarryOverDesc => 'El superávit se añade al mes siguiente';

  @override
  String get settingsDefaultBudgetApplied =>
      'Se aplica automáticamente cuando no hay presupuesto establecido para el mes actual.';

  @override
  String get settingsJustNow => 'Ahora mismo';

  @override
  String settingsMinutesAgo(int minutes) {
    return 'hace $minutes min';
  }

  @override
  String settingsHoursAgo(int hours) {
    return 'hace $hours h';
  }

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSelectLanguage => 'Seleccionar idioma';

  @override
  String get manageWalletsTitle => 'Gestionar carteras';

  @override
  String get manageWalletsNone => 'Sin carteras aún.';

  @override
  String get manageWalletsAdd => 'Añadir cartera';

  @override
  String get manageWalletsEditTitle => 'Editar cartera';

  @override
  String get manageWalletsName => 'Nombre de la cartera';

  @override
  String get manageWalletsDefaultBudget =>
      'Presupuesto mensual predeterminado (opcional)';

  @override
  String get manageWalletsLeaveEmpty => 'Deja vacío para desactivar';

  @override
  String get manageWalletsMonthStart => 'El mes empieza el (opcional)';

  @override
  String get manageWalletsAppDefault => 'Predeterminado de la app';

  @override
  String manageWalletsDay(int day) {
    return 'Día $day';
  }

  @override
  String get manageWalletsLeaveAsDefault =>
      'Dejar como predeterminado de la app si no se establece';

  @override
  String get manageWalletsDefaultLabel => 'Cartera predeterminada';

  @override
  String get manageWalletsSetAsDefault => 'Establecer como predeterminada';

  @override
  String get manageWalletsNoBudget => 'Sin presupuesto predeterminado';

  @override
  String get manageWalletsAlreadyExists =>
      'Ya existe una cartera con este nombre';

  @override
  String manageWalletsBudgetCarryOver(String budget) {
    return '$budget · Traslado activado';
  }

  @override
  String get smsRulesTitle => 'Reglas SMS';

  @override
  String get smsRulesScanPast => 'Escanear SMS anteriores';

  @override
  String get smsRulesPermissionTitle => 'Se requiere permiso SMS';

  @override
  String get smsRulesPermissionMessage =>
      'Concede acceso para que los mensajes entrantes se puedan comparar con tus reglas.';

  @override
  String get smsRulesNone => 'Sin reglas aún';

  @override
  String get smsRulesNoneMessage =>
      'Añade una regla para crear transacciones automáticamente al recibir SMS bancarios.';

  @override
  String get smsRulesAddFirst => 'Añadir primera regla';

  @override
  String get smsRulesDeleteTitle => '¿Eliminar regla?';

  @override
  String smsRulesDeleteMessage(String keyword) {
    return 'La regla para \"$keyword\" será eliminada. Las transacciones creadas no se verán afectadas.';
  }

  @override
  String smsRulesImported(int count, String date) {
    return 'Se crearon $count transacciones el $date — ve a la pantalla de inicio para verlas.';
  }

  @override
  String get smsRulesNoImports => 'No se importaron transacciones.';

  @override
  String get smsRuleFormTitleEdit => 'Editar regla';

  @override
  String get smsRuleFormTitleNew => 'Nueva regla';

  @override
  String get smsRuleFormKeyword => 'Palabra clave';

  @override
  String get smsRuleFormKeywordHint => 'ej. Carrefour, VODAFONE, Uber';

  @override
  String get smsRuleFormKeywordHelper =>
      'Coincidencia sin distinción de mayúsculas en cualquier parte del SMS.';

  @override
  String get smsRuleFormLabel => 'Etiqueta de transacción';

  @override
  String get smsRuleFormLabelHint =>
      'ej. Gasolina, Café, Supermercado (dejar vacío para usar la palabra clave)';

  @override
  String get smsRuleFormLabelHelper =>
      'Aparece como descripción de la transacción. Por defecto usa la palabra clave.';

  @override
  String get smsRuleFormType => 'Tipo de transacción';

  @override
  String get smsRuleFormCategory => 'Categoría';

  @override
  String get smsRuleFormSelectCategory => 'Seleccionar categoría';

  @override
  String get smsRuleFormWallet => 'Cartera';

  @override
  String get smsRuleFormAdvanced => 'Avanzado';

  @override
  String get smsRuleFormCustomRegex =>
      'Expresión regular personalizada para el importe';

  @override
  String get smsRuleFormRegexHint => 'Expresión regular del importe (opcional)';

  @override
  String get smsRuleFormRegexHelper =>
      'Usa el grupo de captura 1 para extraer el importe. Deja vacío para usar la detección integrada.';

  @override
  String get smsRuleFormSaveChanges => 'Guardar cambios';

  @override
  String get smsRuleFormSaveNew => 'Guardar regla';

  @override
  String get smsRuleFormDeleteRule => 'Eliminar regla';

  @override
  String get smsRuleFormEnterKeyword =>
      'Por favor introduce una palabra clave.';

  @override
  String get smsRuleFormSelectCategoryError =>
      'Por favor selecciona una categoría.';

  @override
  String smsRuleFormDeleteMessage(String keyword) {
    return 'La regla para \"$keyword\" se eliminará permanentemente.';
  }

  @override
  String get smsRuleFormSelectCategoryTitle => 'Seleccionar categoría';

  @override
  String get smsScanTitle => 'Escanear SMS existentes';

  @override
  String get smsScanDesc =>
      'Aplicar tus reglas activas a los mensajes ya en tu bandeja de entrada.';

  @override
  String get smsScanDateRange => 'Rango de fechas';

  @override
  String get smsScan3Days => '3 días';

  @override
  String get smsScan7Days => '7 días';

  @override
  String get smsScan30Days => '30 días';

  @override
  String get smsScanCustom => 'Personalizado…';

  @override
  String get smsScanSelectRange => 'Seleccionar rango de fechas';

  @override
  String get smsScanPermissionRequired =>
      'Se requiere permiso SMS para escanear mensajes.';

  @override
  String get smsScanScanning => 'Escaneando mensajes…';

  @override
  String get smsScanNoMatches => 'Sin coincidencias';

  @override
  String get smsScanNoMatchesMessage =>
      'Ningún mensaje en este rango coincidió con tus reglas activas.\nIntenta un rango más amplio o revisa las palabras clave.';

  @override
  String get smsScanTryDifferent => 'Probar rango diferente';

  @override
  String smsScanMatchesFound(int count) {
    return '$count coincidencias encontradas';
  }

  @override
  String smsScanDupNote(int count) {
    return '$count ya existen hoy — sin marcar por defecto';
  }

  @override
  String smsScanImportButton(int count) {
    return 'Importar $count transacciones';
  }

  @override
  String get smsScanNothingSelected => 'Nada seleccionado';

  @override
  String get smsScanEditLabel => 'Editar etiqueta';

  @override
  String get smsScanTransactionDesc => 'Descripción de la transacción';

  @override
  String get smsScanExists => 'existe';

  @override
  String get smsScanDupWarning =>
      'Ya existe una transacción con este importe y categoría en este día';

  @override
  String get paywallTitle => 'FELOOSY PRO';

  @override
  String get paywallSubtitle =>
      'Todo desbloqueado, de una vez. Sin suscripciones.';

  @override
  String paywallUnlock(String price) {
    return 'Desbloquear para siempre — $price';
  }

  @override
  String get paywallRestore => 'Restaurar compra';

  @override
  String get paywallRestoreNote => 'Compra única · Sin cargos recurrentes';

  @override
  String get paywallTrialEnded => 'Tu prueba gratuita de 14 días ha finalizado';

  @override
  String get paywallProUnlocked => 'Pro desbloqueado';

  @override
  String get paywallFeatureWallets => 'Carteras ilimitadas';

  @override
  String get paywallFeatureTransactions => 'Transacciones ilimitadas';

  @override
  String get paywallFeatureHistory => 'Historial completo de transacciones';

  @override
  String get paywallFeatureBackup => 'Copia de seguridad en Google Drive';

  @override
  String get paywallFeatureExport => 'Exportar tus datos';

  @override
  String get paywallFeatureCategories => 'Categorías personalizadas';

  @override
  String get paywallFeatureSms => 'Análisis automático de SMS (Android)';

  @override
  String get paywallNoRestoreFound =>
      'No se encontró ninguna compra anterior para esta cuenta.';

  @override
  String paywallRestoreFailed(String error) {
    return 'Error al restaurar: $error';
  }

  @override
  String tutorialStepOf(int current, int total) {
    return '$current de $total';
  }

  @override
  String get tutorialGetStarted => 'Empezar';

  @override
  String get tutorialWelcomeTitle => 'Bienvenido a FELOOSY';

  @override
  String get tutorialWelcomeMessage =>
      'Tu presupuesto personal, bellamente simple.\nHagamos un recorrido rápido por las funciones principales.';

  @override
  String get tutorialBudgetTitle => 'Presupuesto mensual';

  @override
  String get tutorialBudgetMessage =>
      'Esta tarjeta muestra tu presupuesto frente al gasto del mes. Toca \"Establecer presupuesto\" para definir tu límite mensual.';

  @override
  String get tutorialCarryoverTitle => 'Trasladar superávit';

  @override
  String get tutorialCarryoverMessage =>
      'Activa el traslado en Configuración → Gestionar carteras para cualquier cartera. El presupuesto no utilizado del mes pasado se añade automáticamente a este mes.';

  @override
  String get tutorialAddTitle => 'Añadir una transacción';

  @override
  String get tutorialAddMessage =>
      'Toca el botón + para registrar una compra, factura o ingreso. Elige una categoría para ver adónde va tu dinero.';

  @override
  String get tutorialBrowseTitle => 'Ver meses anteriores';

  @override
  String get tutorialBrowseMessage =>
      'Toca las flechas o desliza izquierda/derecha en la pantalla de inicio para revisar cualquier mes anterior.';

  @override
  String get tutorialSettingsTitle => 'Configuración y más';

  @override
  String get tutorialSettingsMessage =>
      'Cambia la moneda, gestiona cuentas, personaliza categorías y realiza copias de seguridad desde aquí.';

  @override
  String get tutorialDoneTitle => '¡Todo listo!';

  @override
  String get tutorialDoneMessage =>
      'Empieza añadiendo tu primera transacción. FELOOSY hará el seguimiento del resto.';

  @override
  String get privacyTitle => 'Antes de empezar';

  @override
  String get privacySmsTitle => 'Detección automática de SMS';

  @override
  String get privacySmsMessage =>
      'Si concedes permiso SMS, los mensajes bancarios entrantes se comparan con tus reglas en memoria. El texto del mensaje nunca se guarda ni se comparte.';

  @override
  String get privacyDataTitle => 'Tus datos permanecen en tu dispositivo';

  @override
  String get privacyDataMessage =>
      'Las transacciones y los presupuestos se almacenan localmente. No tenemos servidores y no podemos ver tus datos financieros.';

  @override
  String get privacyAiTitle => 'Análisis con IA (opcional)';

  @override
  String get privacyAiMessage =>
      'Si usas la función de IA, se envían resúmenes de gasto anonimizados (totales por categoría, sin SMS sin procesar) a Google Gemini.';

  @override
  String get privacyReadPolicy => 'Leer política completa';

  @override
  String get privacyAccept => 'Aceptar y continuar';
}
