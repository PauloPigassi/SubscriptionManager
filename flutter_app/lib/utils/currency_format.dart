import 'package:intl/intl.dart';

/// Formata centavos em moeda sempre com ponto como decimal (ex: 29.90).
String formatCurrency(int cents, String currency) {
  final formatter = NumberFormat.simpleCurrency(locale: 'en_US', name: currency);
  return formatter.format(cents / 100.0);
}

/// Converte texto de valor para double; aceita vírgula ou ponto como decimal.
double parseAmount(String text) {
  final normalized = text.trim().replaceAll(',', '.');
  return double.tryParse(normalized) ?? 0;
}
