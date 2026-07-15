import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/project_list_filter.dart';

Future<ProjectListFilter?> showProjectFilterSheet({
  required BuildContext context,
  required ProjectListFilter current,
  required List<String> feeTypes,
  required List<String> tiers,
  required List<String> createdByOptions,
}) {
  return showModalBottomSheet<ProjectListFilter>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _ProjectFilterSheet(
      current: current,
      feeTypes: feeTypes,
      tiers: tiers,
      createdByOptions: createdByOptions,
    ),
  );
}

class _ProjectFilterSheet extends StatefulWidget {
  const _ProjectFilterSheet({
    required this.current,
    required this.feeTypes,
    required this.tiers,
    required this.createdByOptions,
  });

  final ProjectListFilter current;
  final List<String> feeTypes;
  final List<String> tiers;
  final List<String> createdByOptions;

  @override
  State<_ProjectFilterSheet> createState() => _ProjectFilterSheetState();
}

class _ProjectFilterSheetState extends State<_ProjectFilterSheet> {
  late String? feeType;
  late String? tierName;
  late String? createdBy;
  late final TextEditingController catchmentCtrl;

  @override
  void initState() {
    super.initState();
    feeType = widget.current.feeType;
    tierName = widget.current.tierName;
    createdBy = widget.current.createdBy;
    catchmentCtrl =
        TextEditingController(text: widget.current.catchmentArea ?? '');
  }

  @override
  void dispose() {
    catchmentCtrl.dispose();
    super.dispose();
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
              _label('Fee Type'),
              DropdownButtonFormField<String?>(
                key: ValueKey('fee_$feeType'),
                initialValue: feeType,
                decoration: _decoration(),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...widget.feeTypes.map(
                    (e) => DropdownMenuItem(value: e, child: Text(e)),
                  ),
                ],
                onChanged: (v) => setState(() => feeType = v),
              ),
              const SizedBox(height: 12),
              _label('Tier'),
              DropdownButtonFormField<String?>(
                key: ValueKey('tier_$tierName'),
                initialValue: tierName,
                decoration: _decoration(),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...widget.tiers.map(
                    (e) => DropdownMenuItem(value: e, child: Text(e)),
                  ),
                ],
                onChanged: (v) => setState(() => tierName = v),
              ),
              const SizedBox(height: 12),
              _label('Created By'),
              DropdownButtonFormField<String?>(
                key: ValueKey('created_$createdBy'),
                initialValue: createdBy,
                isExpanded: true,
                decoration: _decoration(),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...widget.createdByOptions.map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => createdBy = v),
              ),
              const SizedBox(height: 12),
              _label('Catchment Area'),
              TextField(controller: catchmentCtrl, decoration: _decoration()),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, ProjectListFilter.empty);
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
                          ProjectListFilter(
                            feeType: feeType,
                            tierName: tierName,
                            createdBy: createdBy,
                            catchmentArea: catchmentCtrl.text.trim().isEmpty
                                ? null
                                : catchmentCtrl.text.trim(),
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DashboardColors.textMuted,
          ),
        ),
      );

  InputDecoration _decoration() => InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
}
