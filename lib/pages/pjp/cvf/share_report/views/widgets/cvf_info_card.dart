import 'package:Intranet/pages/pjp/cvf/share_report/controllers/share_report_controller.dart';
import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/share_report_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CvfInfoCard extends StatelessWidget {
  const CvfInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ShareReportController>();
    final args = c.args;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ShareReportTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ShareReportTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: ShareReportTheme.chipBg,
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 18,
                  color: ShareReportTheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'CVF Details',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ShareReportTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            args.centreName,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ShareReportTheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _meta('BP Name', c.bpName),
              _meta('BP Code', c.bpCode),
              _meta('Visit Date', c.visitDateDisplay),
              _meta(
                'Facilitator',
                c.facilitatorName.isEmpty ? '—' : c.facilitatorName,
              ),
              _meta('PJP ID', c.pjpId.isEmpty ? '—' : c.pjpId),
              _meta('CVF ID', c.cvfId),
              _meta('CVF Status', args.cvfStatus),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: ShareReportTheme.border),
          const SizedBox(height: 12),
          Text(
            'PJP Remark',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: ShareReportTheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ShareReportTheme.border),
            ),
            child: Text(
              args.remarks == '—' ? 'No remarks available' : args.remarks,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: args.remarks == '—'
                    ? ShareReportTheme.textSecondary
                    : ShareReportTheme.textPrimary,
                fontStyle:
                    args.remarks == '—' ? FontStyle.italic : FontStyle.normal,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(String label, String value) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ShareReportTheme.label),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ShareReportTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
