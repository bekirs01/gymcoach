import 'package:flutter/material.dart';

/// Dark premium palette — calm, production-ready surfaces.
abstract final class PremiumColors {
  static const Color midnightTop = Color(0xFF080C14);
  static const Color midnightMid = Color(0xFF0C111B);
  static const Color midnightBottom = Color(0xFF101622);

  static const Color accentBlue = Color(0xFF6B8FC7);
  static const Color accentBlueSoft = Color(0xFF5A7DB0);

  static const Color textPrimary = Color(0xFFECEFF4);
  static const Color textSecondary = Color(0xFF9CA8B8);
  static const Color textMuted = Color(0xFF6E7A8A);

  static const Color surface = Color(0xFF141A24);
  static const Color surfaceRaised = Color(0xFF1A2230);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color dockFill = Color(0xE8121824);

  static const Color successGreen = Color(0xFF6BBF8A);

  static const Color tabActive = Color(0xFF2E4058);
  static const Color bannerBlue = Color(0xFF4A7FB0);
  static const Color bannerOrange = Color(0xFFB8733A);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [midnightTop, midnightMid, midnightBottom],
  );
}

/// Spacing scale used across premium Home UI.
abstract final class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Corner radii for premium iOS-like shapes.
abstract final class PremiumRadii {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
  static const double xxl = 26;
  static const double pill = 999;
}
