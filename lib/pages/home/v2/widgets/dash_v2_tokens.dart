import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashV2Colors {
  DashV2Colors._();
  static const Color scaffold = Color(0xFFF4F6FB);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFEDF1F7);
  static const Color textDark = Color(0xFF1F2A44);
  static const Color textMuted = Color(0xFF8A94A6);
  static const Color primary = Color(0xFF1565C0); // deep blue AppBar
  static const Color blue = Color(0xFF4C6FFF);
  static const Color green = Color(0xFF2BB673);
  static const Color amber = Color(0xFFFFA63D);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC5990);
  static const Color teal = Color(0xFF14B8A6);
  static const Color red = Color(0xFFEF4E6B);
  static Color tint(Color c) => c.withValues(alpha: 0.12);
}

class DashV2Text {
  DashV2Text._();
  static TextStyle title = GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: DashV2Colors.textDark);
  static TextStyle subtitle = GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w400, color: DashV2Colors.textMuted);
  static TextStyle sectionTitle = GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: DashV2Colors.textDark);
  static TextStyle cardTitle = GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: DashV2Colors.textDark);
  static TextStyle cardSubtitle = GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400, color: DashV2Colors.textMuted);
  static TextStyle kpiValue = GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: DashV2Colors.textDark);
  static TextStyle caption = GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400, color: DashV2Colors.textMuted);
  static TextStyle appBarTitle = GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
  static TextStyle appBarSubtitle = GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70);
}
