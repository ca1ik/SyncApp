// lib/core/theme/app_theme.dart
// Sakinleştirici UI temaları — yumuşak gradyanlar, sıcak renkler.
// Provider ile kullanıcı seçimine göre dinamik olarak değiştirilir.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SyncThemeVariant {
  calmSunset, // Sıcak turuncu-pembe gradyan
  oceanBreeze, // Mavi-yeşil sakinleştirici
  midnightSoft, // Koyu, göz yorucu olmayan
  morningDew, // Açık yeşil-sarı
  rosePetal, // Romantik pembe-gül
  lavenderDream, // Lavanta huzuru
  cherryBlossom, // Kiraz çiçeği
  goldenHour, // Altın saat sıcaklığı
  arcticAurora, // Kuzey ışıkları
}

class AppTheme {
  AppTheme._();

  // --- Sunset Tema Renkleri (varsayılan) ---
  static const Color sunsetPrimary = Color(0xFFE8896A);
  static const Color sunsetSecondary = Color(0xFFF2B19A);
  static const Color sunsetBg = Color(0xFFFFF8F5);
  static const Color sunsetSurface = Color(0xFFFFEDE5);
  static const Color sunsetText = Color(0xFF3D2B1F);
  static const Color sunsetTextLight = Color(0xFF8C6552);

  // --- Ocean Tema Renkleri ---
  static const Color oceanPrimary = Color(0xFF4DA8A0);
  static const Color oceanSecondary = Color(0xFF80C9C3);
  static const Color oceanBg = Color(0xFFF0FAFA);
  static const Color oceanSurface = Color(0xFFDDF2F0);
  static const Color oceanText = Color(0xFF1A3A38);
  static const Color oceanTextLight = Color(0xFF4A7A76);

  // --- Midnight Tema Renkleri ---
  static const Color midnightPrimary = Color(0xFF9B7EDE);
  static const Color midnightSecondary = Color(0xFFBBA2F0);
  static const Color midnightBg = Color(0xFF1A1628);
  static const Color midnightSurface = Color(0xFF241E38);
  static const Color midnightText = Color(0xFFF0EDF8);
  static const Color midnightTextLight = Color(0xFFAA9ECC);

  // --- Gölge & Gradyanlar ---
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFFD4BA), Color(0xFFF2A784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFFB2E8E4), Color(0xFF4DA8A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient midnightGradient = LinearGradient(
    colors: [Color(0xFF2A1F4A), Color(0xFF1A1628)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData buildTheme(SyncThemeVariant variant) {
    switch (variant) {
      case SyncThemeVariant.calmSunset:
        return _buildMaterial(
          primary: sunsetPrimary,
          secondary: sunsetSecondary,
          background: sunsetBg,
          surface: sunsetSurface,
          onPrimary: Colors.white,
          onBackground: sunsetText,
          brightness: Brightness.light,
        );
      case SyncThemeVariant.oceanBreeze:
        return _buildMaterial(
          primary: oceanPrimary,
          secondary: oceanSecondary,
          background: oceanBg,
          surface: oceanSurface,
          onPrimary: Colors.white,
          onBackground: oceanText,
          brightness: Brightness.light,
        );
      case SyncThemeVariant.midnightSoft:
        return _buildMaterial(
          primary: midnightPrimary,
          secondary: midnightSecondary,
          background: midnightBg,
          surface: midnightSurface,
          onPrimary: Colors.white,
          onBackground: midnightText,
          brightness: Brightness.dark,
        );
      case SyncThemeVariant.morningDew:
        return _buildMaterial(
          primary: const Color(0xFF7DBD8C),
          secondary: const Color(0xFFA8D9B0),
          background: const Color(0xFFF4FBF5),
          surface: const Color(0xFFE0F4E4),
          onPrimary: Colors.white,
          onBackground: const Color(0xFF1E3D24),
          brightness: Brightness.light,
        );
      case SyncThemeVariant.rosePetal:
        return _buildMaterial(
          primary: const Color(0xFFE06B8F),
          secondary: const Color(0xFFF2A3B8),
          background: const Color(0xFFFFF0F3),
          surface: const Color(0xFFFFE0E8),
          onPrimary: Colors.white,
          onBackground: const Color(0xFF3D1522),
          brightness: Brightness.light,
        );
      case SyncThemeVariant.lavenderDream:
        return _buildMaterial(
          primary: const Color(0xFF8B7EC8),
          secondary: const Color(0xFFB5A8E0),
          background: const Color(0xFFF5F2FF),
          surface: const Color(0xFFEAE4F8),
          onPrimary: Colors.white,
          onBackground: const Color(0xFF2A1F4A),
          brightness: Brightness.light,
        );
      case SyncThemeVariant.cherryBlossom:
        return _buildMaterial(
          primary: const Color(0xFFD4869C),
          secondary: const Color(0xFFF0B6C8),
          background: const Color(0xFFFFF5F8),
          surface: const Color(0xFFFFE8EF),
          onPrimary: Colors.white,
          onBackground: const Color(0xFF3A1A28),
          brightness: Brightness.light,
        );
      case SyncThemeVariant.goldenHour:
        return _buildMaterial(
          primary: const Color(0xFFD4A843),
          secondary: const Color(0xFFECC872),
          background: const Color(0xFFFFFBF0),
          surface: const Color(0xFFFFF3D6),
          onPrimary: Colors.white,
          onBackground: const Color(0xFF3D2E10),
          brightness: Brightness.light,
        );
      case SyncThemeVariant.arcticAurora:
        return _buildMaterial(
          primary: const Color(0xFF5AA5C8),
          secondary: const Color(0xFF7DD4C8),
          background: const Color(0xFF0C1A28),
          surface: const Color(0xFF142838),
          onPrimary: Colors.white,
          onBackground: const Color(0xFFE0F0F8),
          brightness: Brightness.dark,
        );
    }
  }

  static ThemeData _buildMaterial({
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
    required Color onPrimary,
    required Color onBackground,
    required Brightness brightness,
  }) =>
      ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: ColorScheme(
          brightness: brightness,
          primary: primary,
          onPrimary: onPrimary,
          secondary: secondary,
          onSecondary: onPrimary,
          error: const Color(0xFFCF6679),
          onError: Colors.white,
          surface: surface,
          onSurface: onBackground,
        ),
        scaffoldBackgroundColor: background,
        textTheme: GoogleFonts.nunitoSansTextTheme(
          brightness == Brightness.dark
              ? ThemeData.dark().textTheme
              : ThemeData.light().textTheme,
        ).apply(bodyColor: onBackground, displayColor: onBackground),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: onPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
}
