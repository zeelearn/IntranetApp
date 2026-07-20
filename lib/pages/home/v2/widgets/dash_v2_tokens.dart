import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens extracted from the eKidzee Dashboard V2 Figma (mobile).
class DashV2Colors {
  DashV2Colors._();

  /// Soft gray-blue page background (~#F5F7FA).
  static const Color scaffold = Color(0xFFF5F7FA);

  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8EEF5);

  /// Headings / titles (~#1A1C1E).
  static const Color textDark = Color(0xFF1A1C1E);

  /// Subtitles / labels (~#757575).
  static const Color textMuted = Color(0xFF757575);

  /// Deep royal blue AppBar (~#0056B3).
  static const Color primary = Color(0xFF0056B3);

  /// Accent palette from Figma icons.
  static const Color blue = Color(0xFF1E88E5);
  static const Color green = Color(0xFF43A047);
  static const Color amber = Color(0xFFFB8C00);
  static const Color purple = Color(0xFF8E24AA);
  static const Color pink = Color(0xFFE91E63);
  static const Color teal = Color(0xFF00ACC1);
  static const Color yellow = Color(0xFFF9A825);
  static const Color red = Color(0xFFE53935);

  static const Color bannerStart = Color(0xFFE3F0FF);
  static const Color bannerEnd = Color(0xFFF5F9FF);

  static const double cardRadius = 16;
  static const double iconRadius = 12;

  static Color tint(Color c) => c.withValues(alpha: 0.12);

  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ];
}

class DashV2Text {
  DashV2Text._();

  static TextStyle greeting = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: DashV2Colors.textDark,
    height: 1.25,
  );

  static TextStyle title = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: DashV2Colors.textDark,
  );

  static TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: DashV2Colors.textMuted,
    height: 1.35,
  );

  static TextStyle sectionTitle = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: DashV2Colors.textDark,
  );

  static TextStyle cardTitle = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: DashV2Colors.textDark,
    height: 1.2,
  );

  static TextStyle cardSubtitle = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: DashV2Colors.textMuted,
    height: 1.3,
  );

  static TextStyle kpiValue = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: DashV2Colors.textDark,
    height: 1.1,
  );

  static TextStyle kpiLabel = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: DashV2Colors.textDark,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: DashV2Colors.textMuted,
  );

  static TextStyle footer = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Color(0xFF9E9E9E),
  );

  static TextStyle appBarTitle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.2,
  );

  static TextStyle appBarSubtitle = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.2,
  );

  static TextStyle badge = GoogleFonts.poppins(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1,
  );
}
