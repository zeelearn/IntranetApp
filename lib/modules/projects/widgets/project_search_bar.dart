import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';

class ProjectSearchBar extends StatefulWidget {
  const ProjectSearchBar({
    super.key,
    required this.onChanged,
    required this.onFilterTap,
    this.hint = 'Search by CRM ID, Franchisee, Title...',
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final String hint;

  @override
  State<ProjectSearchBar> createState() => _ProjectSearchBarState();
}

class _ProjectSearchBarState extends State<ProjectSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  color: DashboardColors.textMuted,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: DashboardColors.primary,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: DashboardColors.primary),
                ),
              ),
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: widget.onFilterTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: DashboardColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
