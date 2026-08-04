import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/center_kit_item.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';

Future<CenterKitFilter?> showCenterKitFilterSheet({
  required BuildContext context,
  required CenterKitFilter current,
  required List<String> indentStatuses,
  required List<String> paymentStatuses,
  required List<String> zones,
  required List<String> states,
  required List<String> projectManagers,
}) {
  return showModalBottomSheet<CenterKitFilter>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _CenterKitFilterSheet(
      current: current,
      indentStatuses: indentStatuses,
      paymentStatuses: paymentStatuses,
      zones: zones,
      states: states,
      projectManagers: projectManagers,
    ),
  );
}

class _CenterKitFilterSheet extends StatefulWidget {
  const _CenterKitFilterSheet({
    required this.current,
    required this.indentStatuses,
    required this.paymentStatuses,
    required this.zones,
    required this.states,
    required this.projectManagers,
  });

  final CenterKitFilter current;
  final List<String> indentStatuses;
  final List<String> paymentStatuses;
  final List<String> zones;
  final List<String> states;
  final List<String> projectManagers;

  @override
  State<_CenterKitFilterSheet> createState() => _CenterKitFilterSheetState();
}

class _CenterKitFilterSheetState extends State<_CenterKitFilterSheet> {
  late String? indentStatus;
  late String? paymentStatus;
  late String? zoneCode;
  late String? stateName;
  late String? projectManager;

  @override
  void initState() {
    super.initState();
    indentStatus = widget.current.indentStatus;
    paymentStatus = widget.current.paymentStatus;
    zoneCode = widget.current.zoneCode;
    stateName = widget.current.stateName;
    projectManager = widget.current.projectManager;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Filters',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DashboardColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              _dropdown(
                label: 'Indent Status',
                value: indentStatus,
                options: widget.indentStatuses,
                onChanged: (v) => setState(() => indentStatus = v),
              ),
              const SizedBox(height: 12),
              _dropdown(
                label: 'Payment Status',
                value: paymentStatus,
                options: widget.paymentStatuses,
                onChanged: (v) => setState(() => paymentStatus = v),
              ),
              const SizedBox(height: 12),
              _dropdown(
                label: 'Zone',
                value: zoneCode,
                options: widget.zones,
                onChanged: (v) => setState(() => zoneCode = v),
              ),
              const SizedBox(height: 12),
              _dropdown(
                label: 'State',
                value: stateName,
                options: widget.states,
                onChanged: (v) => setState(() => stateName = v),
              ),
              const SizedBox(height: 12),
              _dropdown(
                label: 'Project Manager',
                value: projectManager,
                options: widget.projectManagers,
                onChanged: (v) => setState(() => projectManager = v),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, CenterKitFilter.empty);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: DashboardColors.primaryFilledButton(),
                      onPressed: () {
                        Navigator.pop(
                          context,
                          CenterKitFilter(
                            indentStatus: indentStatus,
                            paymentStatus: paymentStatus,
                            zoneCode: zoneCode,
                            stateName: stateName,
                            projectManager: projectManager,
                          ),
                        );
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DashboardColors.textMuted,
            ),
          ),
        ),
        DropdownButtonFormField<String?>(
          key: ValueKey('${label}_$value'),
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('All')),
            ...options.map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
