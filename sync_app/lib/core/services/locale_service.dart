import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple locale service for EN/TR switching.
/// Uses ChangeNotifier so the entire widget tree can rebuild on locale change.
class LocaleService extends ChangeNotifier {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  static const String _prefKey = 'app_locale';
  String _locale = 'en'; // default English

  String get locale => _locale;
  bool get isEnglish => _locale == 'en';
  bool get isTurkish => _locale == 'tr';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = prefs.getString(_prefKey) ?? 'en';
    notifyListeners();
  }

  Future<void> setLocale(String locale) async {
    if (locale != 'en' && locale != 'tr') return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale);
  }

  Future<void> toggle() async {
    await setLocale(_locale == 'en' ? 'tr' : 'en');
  }

  /// Shorthand: returns English or Turkish string based on current locale.
  String tr(String en, String turk) => _locale == 'en' ? en : turk;
}

/// Global shorthand for accessing locale service.
LocaleService get l => LocaleService.instance;
