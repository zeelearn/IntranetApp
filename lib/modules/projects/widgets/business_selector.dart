import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/api/response/login_response.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';

class BusinessSelector extends StatelessWidget {
  const BusinessSelector({
    super.key,
    required this.businesses,
    required this.selectedBusinessId,
    required this.selectedLabel,
    required this.onChanged,
    this.compact = false,
  });

  final List<BusinessApplications> businesses;
  final int? selectedBusinessId;
  final String selectedLabel;
  final ValueChanged<int?> onChanged;

  /// Compact chip style for app bar (white filled on primary blue).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(compact ? 10 : 12),
      onTap: () => _openPicker(context),
      child: Container(
        height: compact ? 36 : 44,
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(compact ? 10 : 12),
        ),
        child: Row(
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Icon(
              Icons.business_rounded,
              size: compact ? 16 : 18,
              color: DashboardColors.primary,
            ),
            SizedBox(width: compact ? 6 : 8),
            Flexible(
              child: Text(
                selectedLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w500,
                  color: DashboardColors.textDark,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: compact ? 18 : 24,
              color: DashboardColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final result = await showModalBottomSheet<_BusinessPickResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                ListTile(
                  title: Text(
                    'All Business',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  trailing: selectedBusinessId == null
                      ? const Icon(Icons.check, color: DashboardColors.primary)
                      : null,
                  onTap: () => Navigator.pop(
                    context,
                    const _BusinessPickResult(null),
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: businesses.length,
                    itemBuilder: (context, index) {
                      final item = businesses[index];
                      final selected = selectedBusinessId == item.businessID;
                      return ListTile(
                        title: Text(
                          item.businessName,
                          style: GoogleFonts.poppins(),
                        ),
                        trailing: selected
                            ? const Icon(
                                Icons.check,
                                color: DashboardColors.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(
                          context,
                          _BusinessPickResult(item.businessID),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      onChanged(result.businessId);
    }
  }
}

class _BusinessPickResult {
  const _BusinessPickResult(this.businessId);
  final int? businessId;
}
