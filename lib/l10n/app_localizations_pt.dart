// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get done => 'Concluído';

  @override
  String get next => 'Seguinte';

  @override
  String get skip => 'Ignorar';

  @override
  String get grant => 'Conceder';

  @override
  String get change => 'Alterar';

  @override
  String get clear => 'Limpar';

  @override
  String get import => 'Importar';

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String get expense => 'Despesa';

  @override
  String get income => 'Receita';

  @override
  String get both => 'Ambos';

  @override
  String get recurring => 'Recorrente';

  @override
  String get daily => 'Diário';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensal';

  @override
  String get annually => 'Anual';

  @override
  String get search => 'Pesquisar';

  @override
  String get settings => 'Definições';

  @override
  String get history => 'Histórico';

  @override
  String get budget => 'Orçamento';

  @override
  String get currency => 'Moeda';

  @override
  String get categories => 'Categorias';

  @override
  String get version => 'Versão';

  @override
  String get auto => 'Auto';

  @override
  String get noCategory => 'Sem categoria';

  @override
  String get selectCategory => 'Selecionar categoria';

  @override
  String get setBudget => 'Definir orçamento';

  @override
  String get homeSearchHint => 'Pesquisar transações…';

  @override
  String get homeAllWallets => 'Todas as carteiras';

  @override
  String get homeSwitchWallet => 'Trocar carteira';

  @override
  String get homeWallet => 'Carteira';

  @override
  String get homePreviousMonth => 'Mês anterior';

  @override
  String get homeNextMonth => 'Mês seguinte';

  @override
  String get homeTapReturnCurrentMonth => 'Toque para voltar ao mês atual';

  @override
  String get homeNoBudget => 'Sem orçamento definido.';

  @override
  String homeRemainingThisMonth(int percent) {
    return 'restante este mês · $percent% gasto';
  }

  @override
  String homeOverBudget(int percent) {
    return 'acima do orçamento · $percent% gasto';
  }

  @override
  String homeCarryOver(String amount) {
    return '+ $amount transitado do mês passado';
  }

  @override
  String get homeNoTransactions =>
      'Sem transações ainda.\nToque em + para adicionar uma.';

  @override
  String get homeNoTransactionsDay => 'Sem transações neste dia.';

  @override
  String get homeNoTransactionsCategory =>
      'Sem transações nesta\ncategoria para este período.';

  @override
  String get homeByDay => 'Por dia';

  @override
  String get homeByCategory => 'Por categoria';

  @override
  String get homeDeleteTitle => 'Eliminar transação?';

  @override
  String homeDeleteMessage(String description) {
    return '\"$description\" será eliminado permanentemente.';
  }

  @override
  String get homeSeeAll => 'Ver tudo';

  @override
  String get homeRecentTransactions => 'Transações recentes';

  @override
  String get budgetRemaining => 'restante';

  @override
  String get budgetSpent => 'Gasto';

  @override
  String budgetPercentUsed(String percent) {
    return '$percent% utilizado';
  }

  @override
  String get budgetNoSet => 'Sem orçamento definido para este mês.';

  @override
  String setBudgetForPeriod(String period) {
    return 'Definir orçamento para $period';
  }

  @override
  String get setBudgetHint =>
      'Este é o valor total que pretende acompanhar este mês.';

  @override
  String get setBudgetAmount => 'Valor do orçamento';

  @override
  String get setBudgetEnterAmount => 'Introduza um valor';

  @override
  String get setBudgetValidAmount => 'Introduza um valor válido';

  @override
  String get setBudgetSave => 'Guardar orçamento';

  @override
  String get historyMonth => 'Mês';

  @override
  String get historyYear => 'Ano';

  @override
  String get transactionTitleEdit => 'Editar transação';

  @override
  String get transactionTitleNew => 'Nova transação';

  @override
  String get transactionValidAmount => 'Introduza um valor válido.';

  @override
  String get transactionAddDescription => 'Adicione uma descrição.';

  @override
  String get transactionSelectCategory => 'Selecione uma categoria.';

  @override
  String get transactionRepeats => 'Repete';

  @override
  String get transactionDescription => 'Descrição';

  @override
  String get transactionFrequent => 'FREQUENTE';

  @override
  String get transactionNewCategory => 'Nova';

  @override
  String get transactionEnterCategoryName => 'Introduza um nome de categoria';

  @override
  String transactionAddFieldsTooltip(String fields) {
    return 'Adicione $fields para continuar';
  }

  @override
  String transactionRuleInfo(String keyword) {
    return 'Regra: $keyword  •  toque para editar';
  }

  @override
  String get transactionDeleteTitle => 'Eliminar transação?';

  @override
  String transactionDeleteMessage(String description) {
    return '\"$description\" será eliminado permanentemente.';
  }

  @override
  String get transactionDeleteRecurringTitle => 'Eliminar transação recorrente';

  @override
  String get transactionDeleteRecurringQuestion => 'Como pretende eliminar?';

  @override
  String get transactionDeleteOnlyThis => 'Apenas esta';

  @override
  String get transactionDeleteThisAndFuture => 'Esta e as futuras';

  @override
  String get categoriesNoExpense => 'Sem categorias de despesa ainda.';

  @override
  String get categoriesNoIncome => 'Sem categorias de receita ainda.';

  @override
  String categoriesActiveCount(int count) {
    return '$count ativa(s)';
  }

  @override
  String categoriesUnusedHeader(int count) {
    return 'NÃO UTILIZADAS ESTE MÊS · $count';
  }

  @override
  String get categoriesUnused => 'não utilizada';

  @override
  String categoriesPercentSpend(String percent) {
    return '$percent% das despesas';
  }

  @override
  String get editCategoryTitleEdit => 'Editar categoria';

  @override
  String get editCategoryTitleAdd => 'Adicionar categoria';

  @override
  String get editCategoryName => 'Nome';

  @override
  String get editCategoryUsedFor => 'Usada para';

  @override
  String get editCategoryColour => 'Cor';

  @override
  String get editCategoryIcon => 'Ícone';

  @override
  String get editCategoryChartNote =>
      'A cor da barra do gráfico é gerida pelo tema para categorias integradas.';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsMonthStartsOn => 'O mês começa em';

  @override
  String settingsMonthStartDay(int day, String ordinal) {
    return 'Dia $day$ordinal';
  }

  @override
  String get settingsDaysFebNote =>
      'Os dias 29-31 não estão disponíveis para garantir compatibilidade com fevereiro.';

  @override
  String get settingsDefaultMonthlyBudget => 'Orçamento mensal predefinido';

  @override
  String get settingsNotSet => 'Não definido';

  @override
  String get settingsManageCategories => 'Gerir categorias';

  @override
  String get settingsWallets => 'Carteiras';

  @override
  String get settingsManageWallets => 'Gerir carteiras';

  @override
  String get settingsAutomations => 'Automatizações';

  @override
  String get settingsData => 'Dados';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidade';

  @override
  String get settingsDeveloperTools => 'Ferramentas de programador';

  @override
  String get settingsDangerZone => 'Zona de perigo';

  @override
  String get settingsResetApp => 'Repor aplicação';

  @override
  String get settingsResetAppDesc =>
      'Apagar todas as transações e orçamentos, restaurar predefinições';

  @override
  String get settingsSelectCurrency => 'Selecionar moeda';

  @override
  String get settingsMonthStartOnDay => 'O mês começa no dia…';

  @override
  String get settingsResetTitle => 'Repor aplicação?';

  @override
  String get settingsResetMessage =>
      'Isto eliminará permanentemente:\n  • Todas as transações\n  • Todos os orçamentos\n  • Todas as categorias personalizadas\n\nAs definições serão restauradas para as predefinições e será terminada a sessão do Google. Inicie sessão novamente para restaurar a partir de uma cópia de segurança.\n\nIsto não pode ser desfeito.';

  @override
  String get settingsResetConfirm => 'Repor tudo';

  @override
  String get settingsChangeStartDayTitle => 'Alterar dia de início?';

  @override
  String settingsChangeStartDayMessage(int from, int to) {
    return 'Alterar do dia $from para o dia $to deslocará os limites do período para todos os meses. As transações existentes permanecem inalteradas.';
  }

  @override
  String get settingsBackupToDrive => 'Fazer cópia no Google Drive';

  @override
  String get settingsSignInForBackup =>
      'Inicie sessão para ativar cópia de segurança';

  @override
  String settingsLastBackup(String time) {
    return 'Última cópia: $time';
  }

  @override
  String get settingsNoBackupYet => 'Sem cópia de segurança ainda';

  @override
  String get settingsBackupNow => 'Fazer cópia agora';

  @override
  String get settingsRestoreFromDrive => 'Restaurar do Drive';

  @override
  String get settingsRestoreFromDriveDesc =>
      'Substituir dados locais pela cópia do Drive';

  @override
  String get settingsSignOut => 'Terminar sessão';

  @override
  String get settingsBackupSaved => 'Cópia guardada no Google Drive.';

  @override
  String get settingsBackupNoChanges =>
      'Sem alterações desde a última cópia — ignorado.';

  @override
  String settingsBackupFailed(String error) {
    return 'Falha na cópia: $error';
  }

  @override
  String settingsListBackupsFailed(String error) {
    return 'Não foi possível listar cópias: $error';
  }

  @override
  String get settingsNoBackupFound =>
      'Nenhuma cópia encontrada no Google Drive.';

  @override
  String get settingsReplaceLocalTitle => 'Substituir todos os dados locais?';

  @override
  String get settingsReplaceLocalMessage =>
      'Restaurar do Google Drive eliminará permanentemente tudo neste dispositivo — todas as transações, orçamentos e categorias — e substituirá pela cópia de segurança.\n\nIsto não pode ser desfeito.';

  @override
  String get settingsReplaceMyData => 'Substituir os meus dados';

  @override
  String get settingsDataRestored => 'Dados restaurados do Google Drive.';

  @override
  String settingsRestoreFailed(String error) {
    return 'Falha ao restaurar: $error';
  }

  @override
  String get settingsSelectBackup => 'Selecionar cópia para restaurar';

  @override
  String get settingsExportBackup => 'Exportar cópia de segurança';

  @override
  String get settingsExportBackupDesc =>
      'Guardar todos os dados como ficheiro JSON';

  @override
  String get settingsRestoreFromFile => 'Restaurar de ficheiro';

  @override
  String get settingsRestoreFromFileDesc =>
      'Substituir dados locais por cópia exportada';

  @override
  String settingsExportFailed(String error) {
    return 'Falha ao exportar: $error';
  }

  @override
  String settingsCannotReadFile(String error) {
    return 'Não é possível ler o ficheiro: $error';
  }

  @override
  String get settingsImportTitle => 'Importar cópia de segurança?';

  @override
  String settingsImportFound(int transactions, int budgets, int categories) {
    return 'Encontrado:\n  • $transactions transações\n  • $budgets orçamentos\n  • $categories categorias\n\nIsto substituirá todos os dados locais. Não pode ser desfeito.';
  }

  @override
  String get settingsImportConfirm => 'Importar';

  @override
  String settingsImportDone(int count) {
    return '$count transações importadas com sucesso.';
  }

  @override
  String settingsImportFailed(String error) {
    return 'Falha ao importar: $error';
  }

  @override
  String get settingsSmsRules => 'Regras SMS';

  @override
  String get settingsSmsRulesDesc =>
      'Criar transações automaticamente a partir de mensagens recebidas';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsThemeAuto => 'Auto';

  @override
  String get settingsCarryOver => 'Transferir orçamento não utilizado';

  @override
  String get settingsCarryOverDesc =>
      'O excedente é transferido para o mês seguinte';

  @override
  String get settingsDefaultBudgetApplied =>
      'Aplicado automaticamente quando não há orçamento definido para o mês atual.';

  @override
  String get settingsJustNow => 'Agora mesmo';

  @override
  String settingsMinutesAgo(int minutes) {
    return 'há $minutes min';
  }

  @override
  String settingsHoursAgo(int hours) {
    return 'há $hours h';
  }

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSelectLanguage => 'Selecionar idioma';

  @override
  String get manageWalletsTitle => 'Gerir carteiras';

  @override
  String get manageWalletsNone => 'Sem carteiras ainda.';

  @override
  String get manageWalletsAdd => 'Adicionar carteira';

  @override
  String get manageWalletsEditTitle => 'Editar carteira';

  @override
  String get manageWalletsName => 'Nome da carteira';

  @override
  String get manageWalletsDefaultBudget =>
      'Orçamento mensal predefinido (opcional)';

  @override
  String get manageWalletsLeaveEmpty => 'Deixe vazio para desativar';

  @override
  String get manageWalletsMonthStart => 'O mês começa em (opcional)';

  @override
  String get manageWalletsAppDefault => 'Predefinição da app';

  @override
  String manageWalletsDay(int day) {
    return 'Dia $day';
  }

  @override
  String get manageWalletsLeaveAsDefault =>
      'Deixar como predefinição da app se não definido';

  @override
  String get manageWalletsDefaultLabel => 'Carteira predefinida';

  @override
  String get manageWalletsSetAsDefault => 'Definir como predefinida';

  @override
  String get manageWalletsNoBudget => 'Sem orçamento predefinido';

  @override
  String get manageWalletsAlreadyExists =>
      'Já existe uma carteira com este nome';

  @override
  String manageWalletsBudgetCarryOver(String budget) {
    return '$budget · Transferência ativa';
  }

  @override
  String get smsRulesTitle => 'Regras SMS';

  @override
  String get smsRulesScanPast => 'Analisar SMS anteriores';

  @override
  String get smsRulesPermissionTitle => 'Permissão SMS necessária';

  @override
  String get smsRulesPermissionMessage =>
      'Conceda acesso para que as mensagens recebidas possam ser comparadas com as suas regras.';

  @override
  String get smsRulesNone => 'Sem regras ainda';

  @override
  String get smsRulesNoneMessage =>
      'Adicione uma regra para criar transações automaticamente ao receber SMS bancários.';

  @override
  String get smsRulesAddFirst => 'Adicionar primeira regra';

  @override
  String get smsRulesDeleteTitle => 'Eliminar regra?';

  @override
  String smsRulesDeleteMessage(String keyword) {
    return 'A regra para \"$keyword\" será eliminada. As transações criadas não serão afetadas.';
  }

  @override
  String smsRulesImported(int count, String date) {
    return '$count transações criadas em $date — vá ao ecrã inicial para as ver.';
  }

  @override
  String get smsRulesNoImports => 'Nenhuma transação importada.';

  @override
  String get smsRuleFormTitleEdit => 'Editar regra';

  @override
  String get smsRuleFormTitleNew => 'Nova regra';

  @override
  String get smsRuleFormKeyword => 'Palavra-chave';

  @override
  String get smsRuleFormKeywordHint => 'ex. Carrefour, VODAFONE, Uber';

  @override
  String get smsRuleFormKeywordHelper =>
      'Correspondência sem distinção de maiúsculas em qualquer parte do SMS.';

  @override
  String get smsRuleFormLabel => 'Etiqueta da transação';

  @override
  String get smsRuleFormLabelHint =>
      'ex. Combustível, Café, Supermercado (deixar vazio para usar palavra-chave)';

  @override
  String get smsRuleFormLabelHelper =>
      'Apresentado como descrição da transação. Por defeito usa a palavra-chave.';

  @override
  String get smsRuleFormType => 'Tipo de transação';

  @override
  String get smsRuleFormCategory => 'Categoria';

  @override
  String get smsRuleFormSelectCategory => 'Selecionar categoria';

  @override
  String get smsRuleFormWallet => 'Carteira';

  @override
  String get smsRuleFormAdvanced => 'Avançado';

  @override
  String get smsRuleFormCustomRegex =>
      'Expressão regular personalizada para o valor';

  @override
  String get smsRuleFormRegexHint => 'Regex do valor (opcional)';

  @override
  String get smsRuleFormRegexHelper =>
      'Use o grupo de captura 1 para extrair o valor. Deixe vazio para usar a deteção integrada.';

  @override
  String get smsRuleFormSaveChanges => 'Guardar alterações';

  @override
  String get smsRuleFormSaveNew => 'Guardar regra';

  @override
  String get smsRuleFormDeleteRule => 'Eliminar regra';

  @override
  String get smsRuleFormEnterKeyword =>
      'Por favor introduza uma palavra-chave.';

  @override
  String get smsRuleFormSelectCategoryError =>
      'Por favor selecione uma categoria.';

  @override
  String smsRuleFormDeleteMessage(String keyword) {
    return 'A regra para \"$keyword\" será eliminada permanentemente.';
  }

  @override
  String get smsRuleFormSelectCategoryTitle => 'Selecionar categoria';

  @override
  String get smsScanTitle => 'Analisar SMS existentes';

  @override
  String get smsScanDesc =>
      'Aplicar as suas regras ativas a mensagens já na sua caixa de entrada.';

  @override
  String get smsScanDateRange => 'Intervalo de datas';

  @override
  String get smsScan3Days => '3 dias';

  @override
  String get smsScan7Days => '7 dias';

  @override
  String get smsScan30Days => '30 dias';

  @override
  String get smsScanCustom => 'Personalizado…';

  @override
  String get smsScanSelectRange => 'Selecionar intervalo de datas';

  @override
  String get smsScanPermissionRequired =>
      'A permissão SMS é necessária para analisar mensagens.';

  @override
  String get smsScanScanning => 'A analisar mensagens…';

  @override
  String get smsScanNoMatches => 'Sem correspondências';

  @override
  String get smsScanNoMatchesMessage =>
      'Nenhuma mensagem neste intervalo corresponde às suas regras ativas.\nExperimente um intervalo mais amplo ou verifique as palavras-chave.';

  @override
  String get smsScanTryDifferent => 'Tentar intervalo diferente';

  @override
  String smsScanMatchesFound(int count) {
    return '$count correspondências encontradas';
  }

  @override
  String smsScanDupNote(int count) {
    return '$count já existem hoje — não selecionadas por defeito';
  }

  @override
  String smsScanImportButton(int count) {
    return 'Importar $count transações';
  }

  @override
  String get smsScanNothingSelected => 'Nada selecionado';

  @override
  String get smsScanEditLabel => 'Editar etiqueta';

  @override
  String get smsScanTransactionDesc => 'Descrição da transação';

  @override
  String get smsScanExists => 'existe';

  @override
  String get smsScanDupWarning =>
      'Já existe uma transação para este valor e categoria neste dia';

  @override
  String get paywallTitle => 'FELOOSY PRO';

  @override
  String get paywallSubtitle => 'Tudo desbloqueado, uma vez. Sem subscrições.';

  @override
  String paywallUnlock(String price) {
    return 'Desbloquear para sempre — $price';
  }

  @override
  String get paywallRestore => 'Restaurar compra';

  @override
  String get paywallRestoreNote => 'Compra única · Sem taxas recorrentes';

  @override
  String get paywallTrialEnded =>
      'O seu período de avaliação gratuito de 14 dias terminou';

  @override
  String get paywallProUnlocked => 'Pro desbloqueado';

  @override
  String get paywallFeatureWallets => 'Carteiras ilimitadas';

  @override
  String get paywallFeatureTransactions => 'Transações ilimitadas';

  @override
  String get paywallFeatureHistory => 'Histórico completo de transações';

  @override
  String get paywallFeatureBackup => 'Cópia de segurança no Google Drive';

  @override
  String get paywallFeatureExport => 'Exportar os seus dados';

  @override
  String get paywallFeatureCategories => 'Categorias personalizadas';

  @override
  String get paywallFeatureSms => 'Análise automática de SMS (Android)';

  @override
  String get paywallNoRestoreFound =>
      'Nenhuma compra anterior encontrada para esta conta.';

  @override
  String paywallRestoreFailed(String error) {
    return 'Falha ao restaurar: $error';
  }

  @override
  String tutorialStepOf(int current, int total) {
    return '$current de $total';
  }

  @override
  String get tutorialGetStarted => 'Começar';

  @override
  String get tutorialWelcomeTitle => 'Bem-vindo ao FELOOSY';

  @override
  String get tutorialWelcomeMessage =>
      'O seu orçamento pessoal, belo e simples.\nFaçamos uma visita rápida às funcionalidades principais.';

  @override
  String get tutorialBudgetTitle => 'Orçamento mensal';

  @override
  String get tutorialBudgetMessage =>
      'Este cartão mostra o seu orçamento versus despesas do mês. Toque em \"Definir orçamento\" para definir o seu limite mensal.';

  @override
  String get tutorialCarryoverTitle => 'Transferir excedente';

  @override
  String get tutorialCarryoverMessage =>
      'Ative a transferência em Definições → Gerir carteiras para qualquer carteira. O orçamento não utilizado do mês passado é adicionado automaticamente a este mês.';

  @override
  String get tutorialAddTitle => 'Adicionar uma transação';

  @override
  String get tutorialAddMessage =>
      'Toque no botão + para registar uma compra, fatura ou receita. Escolha uma categoria para ver para onde vai o seu dinheiro.';

  @override
  String get tutorialBrowseTitle => 'Consultar meses anteriores';

  @override
  String get tutorialBrowseMessage =>
      'Toque nas setas ou deslize esquerda/direita no ecrã inicial para rever qualquer mês anterior.';

  @override
  String get tutorialSettingsTitle => 'Definições e mais';

  @override
  String get tutorialSettingsMessage =>
      'Altere a moeda, gira contas, personalize categorias e faça cópia de segurança dos seus dados aqui.';

  @override
  String get tutorialDoneTitle => 'Está tudo pronto!';

  @override
  String get tutorialDoneMessage =>
      'Comece por adicionar a sua primeira transação. O FELOOSY trata do resto.';

  @override
  String get privacyTitle => 'Antes de começar';

  @override
  String get privacySmsTitle => 'Deteção automática de SMS';

  @override
  String get privacySmsMessage =>
      'Se conceder permissão SMS, as mensagens bancárias recebidas são comparadas com as suas regras em memória. O texto da mensagem nunca é guardado ou partilhado.';

  @override
  String get privacyDataTitle => 'Os seus dados ficam no seu dispositivo';

  @override
  String get privacyDataMessage =>
      'As transações e orçamentos são armazenados localmente. Não temos servidores e não podemos ver os seus dados financeiros.';

  @override
  String get privacyAiTitle => 'Análise com IA (opcional)';

  @override
  String get privacyAiMessage =>
      'Se usar a funcionalidade IA, resumos de despesas anonimizados (totais por categoria, sem SMS em bruto) são enviados para o Google Gemini.';

  @override
  String get privacyReadPolicy => 'Ler política completa';

  @override
  String get privacyAccept => 'Aceitar e continuar';
}
