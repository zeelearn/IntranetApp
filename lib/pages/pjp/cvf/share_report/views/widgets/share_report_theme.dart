import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/pages/helper/constants.dart';

/// Material 3 visual tokens for Share Centre Visit Report.
class ShareReportTheme {
  ShareReportTheme._();

  static const Color primary = kPrimaryLightColor; // #0277BD
  static const Color scaffold = Color(0xFFF0F4F8);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE0E6ED);
  static const Color textPrimary = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF5F6B7A);
  static const Color chipBg = Color(0xFFE8F1F8);
  static const Color composeHeader = Color(0xFFF8FAFC);

  static TextStyle get title => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get sectionTitle => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get label => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      );

  static TextStyle get body => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.45,
      );

  static TextStyle get emailMeta => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      );

  static TextStyle get emailBody => GoogleFonts.poppins(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.55,
      );

  static TextStyle get subject => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  /// Masks `john.doe@example.com` → `j***@e***.com`
  static String maskEmail(String email) {
    final value = email.trim();
    if (value.isEmpty) return '—';
    final at = value.indexOf('@');
    if (at <= 0 || at >= value.length - 1) return '•••@•••';

    final local = value.substring(0, at);
    final domain = value.substring(at + 1);
    final maskedLocal = local.length == 1
        ? '*'
        : '${local[0]}${'*' * (local.length - 1).clamp(2, 6)}';

    final dot = domain.lastIndexOf('.');
    if (dot <= 0) {
      return '$maskedLocal@${domain[0]}***';
    }
    final name = domain.substring(0, dot);
    final tld = domain.substring(dot);
    final maskedDomain = name.isEmpty
        ? '***'
        : '${name[0]}${'*' * (name.length - 1).clamp(2, 5)}';
    return '$maskedLocal@$maskedDomain$tld';
  }

  static String maskEmailList(List<String> emails) {
    if (emails.isEmpty) return '—';
    return emails.map(maskEmail).join(', ');
  }
}
