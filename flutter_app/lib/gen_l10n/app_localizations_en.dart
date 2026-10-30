// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Subscription Manager';

  @override
  String get signIn => 'Sign in';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get createAccount => 'Create an account';

  @override
  String get loginErrorHint =>
      'Hint: same WiFi as Mac? Check IP in api_client.dart (ipconfig getifaddr en0)?';

  @override
  String get createAccountTitle => 'Create account';

  @override
  String get nameOptional => 'Name (optional)';

  @override
  String get register => 'Register';

  @override
  String get hello => 'Hello, ';

  @override
  String get monthlySpend => 'Monthly Spend';

  @override
  String get upcomingRenewals => 'Upcoming Renewals';

  @override
  String get seeAll => 'See All';

  @override
  String get noUpcomingRenewals => 'No upcoming renewals';

  @override
  String get manageSubscriptions => 'Manage Subscriptions';

  @override
  String get overdue => 'Overdue';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String daysLeft(int count) {
    return '$count days left';
  }

  @override
  String renewsOn(Object date) {
    return 'Renews on $date';
  }

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get noSubscriptionsYet => 'No subscriptions yet';

  @override
  String get addFirstSubscription =>
      'Add your first subscription to get started';

  @override
  String get addSubscription => 'Add Subscription';

  @override
  String get archiveSubscription => 'Archive Subscription';

  @override
  String archiveConfirm(Object name) {
    return 'Are you sure you want to archive $name?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get archive => 'Archive';

  @override
  String archived(Object name) {
    return '$name archived';
  }

  @override
  String archiveFailed(Object error) {
    return 'Failed to archive: $error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get addSubscriptionTitle => 'Add Subscription';

  @override
  String get catalogService => 'Catalog service';

  @override
  String get name => 'Name';

  @override
  String get amountHint => 'Amount (e.g. 29.90)';

  @override
  String get billingCycle => 'Billing cycle';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get weekly => 'Weekly';

  @override
  String get customInterval => 'Custom interval';

  @override
  String get intervalCount => 'Interval count';

  @override
  String get intervalUnit => 'Interval unit';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get nextRenewal => 'Next renewal';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get saveSubscription => 'Save Subscription';

  @override
  String get subscriptionDetails => 'Subscription Details';

  @override
  String get subscriptionNotFound => 'Subscription not found';

  @override
  String get amount => 'Amount';

  @override
  String get billingCycleLabel => 'Billing Cycle';

  @override
  String get nextRenewalLabel => 'Next Renewal';

  @override
  String get category => 'Category';

  @override
  String get filterAll => 'All';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get newCategory => 'New category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get editSubscription => 'Edit subscription';

  @override
  String get editSubscriptionTitle => 'Edit subscription';

  @override
  String get save => 'Save';

  @override
  String get categoryUpdated => 'Category updated';

  @override
  String get subscriptionUpdated => 'Subscription updated';

  @override
  String get iconUrlOptional => 'Icon URL (optional)';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageDesc => 'App language';

  @override
  String get english => 'English';

  @override
  String get portuguese => 'Português';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsDesc => 'You don\'t have any notifications yet';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String yearlySpend(String amount) {
    return '≈ $amount per year';
  }

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String subscriptionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subscriptions',
      one: '1 subscription',
    );
    return '$_temp0';
  }

  @override
  String get reminders => 'Renewal reminders';

  @override
  String get remindersDesc => 'Get a push notification before each renewal';

  @override
  String get reminderOnDay => 'On renewal day';

  @override
  String reminderDaysBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days before',
      one: '1 day before',
    );
    return '$_temp0';
  }

  @override
  String get remindersLoadFailed => 'Could not load reminders';

  @override
  String get remindersSaveFailed => 'Could not save reminders';
}
