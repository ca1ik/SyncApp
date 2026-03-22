import 'package:flutter/material.dart';

import '../../core/services/locale_service.dart';

/// The three relationship modes that define the app's visual theme,
/// scoring system, and background particle style.
enum RelationshipMode {
  couple, // Sevgili — hearts, romantic theme
  friend, // Arkadaş — galaxy, modern, star particles, friend points
  solo, // Tekli — bubbles, hybrid of couple+friend
}

extension RelationshipModeX on RelationshipMode {
  String get title {
    switch (this) {
      case RelationshipMode.couple:
        return l.tr('Couple', 'Sevgili');
      case RelationshipMode.friend:
        return l.tr('Friend', 'Arkadas');
      case RelationshipMode.solo:
        return l.tr('Solo', 'Tekli');
    }
  }

  String get subtitle {
    switch (this) {
      case RelationshipMode.couple:
        return l.tr(
            'Romantic mode with your partner', 'Partnerinizle romantik mod');
      case RelationshipMode.friend:
        return l.tr(
            'Fun mode with your best friend', 'En iyi arkadasinizla eglence');
      case RelationshipMode.solo:
        return l.tr(
            'Self-care and personal growth', 'Kisisel bakim ve gelisim');
    }
  }

  String get emoji {
    switch (this) {
      case RelationshipMode.couple:
        return '💕';
      case RelationshipMode.friend:
        return '🌟';
      case RelationshipMode.solo:
        return '🫧';
    }
  }

  /// Primary gradient colors per mode
  List<Color> get gradientColors {
    switch (this) {
      case RelationshipMode.couple:
        return const [Color(0xFFE88A6A), Color(0xFFF2B19A)];
      case RelationshipMode.friend:
        return const [Color(0xFF1A1A2E), Color(0xFF16213E)];
      case RelationshipMode.solo:
        return const [Color(0xFF667eea), Color(0xFF764ba2)];
    }
  }

  /// Accent color for cards, buttons
  Color get accentColor {
    switch (this) {
      case RelationshipMode.couple:
        return const Color(0xFFE88A6A);
      case RelationshipMode.friend:
        return const Color(0xFF00D2FF);
      case RelationshipMode.solo:
        return const Color(0xFF667eea);
    }
  }

  /// Point label (couple: love points, friend: friend points, solo: self points)
  String get pointLabel {
    switch (this) {
      case RelationshipMode.couple:
        return l.tr('Love Points', 'Ask Puani');
      case RelationshipMode.friend:
        return l.tr('Friend Points', 'Arkadas Puani');
      case RelationshipMode.solo:
        return l.tr('Self Points', 'Kisisel Puan');
    }
  }

  /// Whether this mode requires a partner
  bool get requiresPartner {
    switch (this) {
      case RelationshipMode.couple:
      case RelationshipMode.friend:
        return true;
      case RelationshipMode.solo:
        return false;
    }
  }
}
