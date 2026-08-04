import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';

/// Simple placeholder screen for upcoming Projects module pages.
class ProjectsPlaceholderPage extends StatelessWidget {
  const ProjectsPlaceholderPage({
    super.key,
    required this.title,
    this.subtitle = 'This page will be available soon.',
  });

  final String title;
  final String subtitle;

  static Future<T?>? open<T>({
    required String title,
    String subtitle = 'This page will be available soon.',
  }) {
    return Get.to<T>(
      () => ProjectsPlaceholderPage(title: title, subtitle: subtitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.scaffold,
      appBar: AppBar(
        backgroundColor: DashboardColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction_rounded,
                size: 56,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DashboardColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: DashboardColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
