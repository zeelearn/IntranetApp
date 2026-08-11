import 'package:Intranet/pages/pjp/cvf/share_report/views/widgets/share_report_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared bordered table chrome for share-report dynamic sections.
class ShareReportTable extends StatelessWidget {
  const ShareReportTable({
    super.key,
    required this.columnWidths,
    required this.headers,
    required this.rows,
  });

  final Map<int, TableColumnWidth> columnWidths;
  final List<String> headers;
  final List<List<Widget>> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: ShareReportTheme.border),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.sizeOf(context).width < 600
                ? 520
                : MediaQuery.sizeOf(context).width * 0.42,
          ),
          child: Table(
            columnWidths: columnWidths,
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder(
              horizontalInside: BorderSide(color: ShareReportTheme.border),
              verticalInside: BorderSide(color: ShareReportTheme.border.withValues(alpha: 0.7)),
            ),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: ShareReportTheme.composeHeader),
                children: [
                  for (final h in headers)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Text(
                        h,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ShareReportTheme.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              for (var r = 0; r < rows.length; r++)
                TableRow(
                  decoration: BoxDecoration(
                    color: r.isEven ? Colors.white : const Color(0xFFFAFBFC),
                  ),
                  children: [
                    for (final cell in rows[r])
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: cell,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration shareReportCellDecoration({String? hint}) {
  return InputDecoration(
    isDense: true,
    hintText: hint,
    hintStyle: GoogleFonts.poppins(
      fontSize: 12,
      color: ShareReportTheme.textSecondary.withValues(alpha: 0.7),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: ShareReportTheme.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: ShareReportTheme.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: ShareReportTheme.primary, width: 1.3),
    ),
  );
}

TextStyle shareReportCellTextStyle() => GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: ShareReportTheme.textPrimary,
    );
