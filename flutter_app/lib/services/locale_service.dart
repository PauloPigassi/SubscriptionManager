import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persiste e expõe o idioma escolhido (en, pt).
/// Uso: LocaleService.getLocale() e LocaleService.setLocale(...).
class LocaleService {
  static const _key = 'app_locale';

  /// Locales suportados
  static const en = Locale('en');
  static const pt = Locale('pt');
  static const supported = [en, pt];

  static String _localeToString(Locale l) => l.languageCode;
  static Locale _stringToLocale(String s) {
    if (s == 'pt') return pt;
    return en;
  }

  /// Retorna o locale salvo ou null (usa o do sistema).
  static Future<Locale?> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null || s.isEmpty) return null;
    return _stringToLocale(s);
  }

  /// Salva o locale e retorna true.
  static Future<bool> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_key, _localeToString(locale));
  }

  /// Limpa o locale salvo (volta para o do sistema).
  static Future<bool> clearLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_key);
  }
}
