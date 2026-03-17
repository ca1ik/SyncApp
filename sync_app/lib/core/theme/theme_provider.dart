// lib/core/theme/theme_provider.dart
// Provider: kullanıcının seçtiği sakinleştirici UI temasını yönetir.
// AppThemeProvider, ChangeNotifier ile tüm ağaca tema değişimini iletir.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_app/core/constants/app_constants.dart';
import 'package:sync_app/core/theme/app_theme.dart';

class AppThemeProvider extends ChangeNotifier {
  SyncThemeVariant _variant = SyncThemeVariant.calmSunset;

  SyncThemeVariant get variant => _variant;
  ThemeData get themeData => AppTheme.buildTheme(_variant);

  LinearGradient get activeGradient {
    switch (_variant) {
      case SyncThemeVariant.calmSunset:
        return AppTheme.sunsetGradient;
      case SyncThemeVariant.oceanBreeze:
        return AppTheme.oceanGradient;
      case SyncThemeVariant.midnightSoft:
        return AppTheme.midnightGradient;
      case SyncThemeVariant.morningDew:
        return const LinearGradient(
          colors: [Color(0xFFCCEDD2), Color(0xFF7DBD8C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.prefThemeKey);
    if (saved != null) {
      final idx = SyncThemeVariant.values.indexWhere((v) => v.name == saved);
      if (idx >= 0) {
        _variant = SyncThemeVariant.values[idx];
        notifyListeners();
      }
    }
  }

  Future<void> setTheme(SyncThemeVariant variant) async {
    _variant = variant;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefThemeKey, variant.name);
  }
}
