// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Subscription Manager';

  @override
  String get signIn => 'Entrar';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get login => 'Entrar';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get loginErrorHint =>
      'Dica: mesmo WiFi que o Mac? IP em api_client.dart (ipconfig getifaddr en0)?';

  @override
  String get createAccountTitle => 'Criar conta';

  @override
  String get nameOptional => 'Nome (opcional)';

  @override
  String get register => 'Cadastrar';

  @override
  String get hello => 'Olá, ';

  @override
  String get monthlySpend => 'Gasto mensal';

  @override
  String get upcomingRenewals => 'Próximas renovações';

  @override
  String get seeAll => 'Ver todas';

  @override
  String get noUpcomingRenewals => 'Nenhuma renovação próxima';

  @override
  String get manageSubscriptions => 'Gerenciar assinaturas';

  @override
  String get overdue => 'Atrasado';

  @override
  String get today => 'Hoje';

  @override
  String get tomorrow => 'Amanhã';

  @override
  String daysLeft(int count) {
    return '$count dias restantes';
  }

  @override
  String renewsOn(Object date) {
    return 'Renova em $date';
  }

  @override
  String get subscriptions => 'Assinaturas';

  @override
  String get noSubscriptionsYet => 'Nenhuma assinatura ainda';

  @override
  String get addFirstSubscription =>
      'Adicione sua primeira assinatura para começar';

  @override
  String get addSubscription => 'Adicionar assinatura';

  @override
  String get archiveSubscription => 'Arquivar assinatura';

  @override
  String archiveConfirm(Object name) {
    return 'Arquivar $name?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get archive => 'Arquivar';

  @override
  String archived(Object name) {
    return '$name arquivado';
  }

  @override
  String archiveFailed(Object error) {
    return 'Falha ao arquivar: $error';
  }

  @override
  String get retry => 'Tentar novamente';

  @override
  String get addSubscriptionTitle => 'Adicionar assinatura';

  @override
  String get catalogService => 'Serviço do catálogo';

  @override
  String get name => 'Nome';

  @override
  String get amountHint => 'Valor (ex: 29,90)';

  @override
  String get billingCycle => 'Ciclo de cobrança';

  @override
  String get monthly => 'Mensal';

  @override
  String get yearly => 'Anual';

  @override
  String get weekly => 'Semanal';

  @override
  String get customInterval => 'Intervalo personalizado';

  @override
  String get intervalCount => 'Quantidade do intervalo';

  @override
  String get intervalUnit => 'Unidade do intervalo';

  @override
  String get month => 'Mês';

  @override
  String get year => 'Ano';

  @override
  String get nextRenewal => 'Próxima renovação';

  @override
  String get notesOptional => 'Observações (opcional)';

  @override
  String get saveSubscription => 'Salvar assinatura';

  @override
  String get subscriptionDetails => 'Detalhes da assinatura';

  @override
  String get subscriptionNotFound => 'Assinatura não encontrada';

  @override
  String get amount => 'Valor';

  @override
  String get billingCycleLabel => 'Ciclo de cobrança';

  @override
  String get nextRenewalLabel => 'Próxima renovação';

  @override
  String get category => 'Categoria';

  @override
  String get filterAll => 'Todas';

  @override
  String get uncategorized => 'Sem categoria';

  @override
  String get newCategory => 'Nova categoria';

  @override
  String get editCategory => 'Alterar categoria';

  @override
  String get editSubscription => 'Editar assinatura';

  @override
  String get editSubscriptionTitle => 'Editar assinatura';

  @override
  String get save => 'Salvar';

  @override
  String get categoryUpdated => 'Categoria atualizada';

  @override
  String get subscriptionUpdated => 'Assinatura atualizada';

  @override
  String get settings => 'Configurações';

  @override
  String get language => 'Idioma';

  @override
  String get languageDesc => 'Idioma do app';

  @override
  String get english => 'English';

  @override
  String get portuguese => 'Português';

  @override
  String get notifications => 'Notificações';

  @override
  String get noNotifications => 'Nenhuma notificação';

  @override
  String get noNotificationsDesc => 'Você não tem notificações ainda';

  @override
  String get markAllAsRead => 'Marcar todas como lidas';

  @override
  String get justNow => 'Agora';

  @override
  String minutesAgo(int count) {
    return '$count min atrás';
  }

  @override
  String hoursAgo(int count) {
    return '$count h atrás';
  }

  @override
  String get yesterday => 'Ontem';

  @override
  String daysAgo(int count) {
    return '$count dias atrás';
  }
}
