import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';
import 'package:Intranet/modules/projects/models/indent_item.dart';
import 'package:Intranet/modules/projects/utils/project_date_utils.dart';

class IndentCard extends StatelessWidget {
  const IndentCard({
    super.key,
    required this.item,
    this.index = 0,
    this.onGeneratePaymentLink,
    this.onBrandingKit,
    this.isGeneratingPaymentLink = false,
    this.showPaymentLink = true,
  });

  final IndentItem item;
  final int index;
  final VoidCallback? onGeneratePaymentLink;
  final VoidCallback? onBrandingKit;
  final bool isGeneratingPaymentLink;
  final bool showPaymentLink;

  @override
  Widget build(BuildContext context) {
    final paymentColor = _statusColor(item.paymentStatus);
    final projectColor = _statusColor(item.projectStatus);
    final indentColor = _statusColor(item.indentStatus);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 240 + (index * 30).clamp(0, 300)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 8),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.franchiseeName.isEmpty
                              ? '—'
                              : item.franchiseeName,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: DashboardColors.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.franchiseeCode.isEmpty
                              ? 'Code —'
                              : item.franchiseeCode,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: DashboardColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    label: '#${item.indentId}',
                    color: DashboardColors.primary,
                    filled: true,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _Chip(label: item.indentStatus, color: indentColor),
                  _Chip(label: 'Pay: ${item.paymentStatus}', color: paymentColor),
                  _Chip(
                    label: 'Project: ${item.projectStatus}',
                    color: projectColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _AmountTile(
                      label: 'PIL',
                      value: ProjectDateUtils.formatAmount(item.pil),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _AmountTile(
                      label: 'Approved',
                      value: item.apprAmount == null
                          ? '—'
                          : ProjectDateUtils.formatAmount(item.apprAmount!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _AmountTile(
                      label: 'Due',
                      value: ProjectDateUtils.formatAmount(item.dueAmount),
                      emphasize: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _MetaRow(
                icon: Icons.event_outlined,
                text:
                    'Due ${ProjectDateUtils.formatReadable(item.dueDate)}',
              ),
              const SizedBox(height: 4),
              _MetaRow(
                icon: Icons.location_on_outlined,
                text:
                    '${item.stateName.isEmpty ? '—' : item.stateName} · Zone ${item.zoneCode.isEmpty ? '—' : item.zoneCode}',
              ),
              const SizedBox(height: 4),
              _MetaRow(
                icon: Icons.description_outlined,
                text:
                    'Agreement ${item.agreementNo.isEmpty ? '—' : item.agreementNo}',
              ),
              const SizedBox(height: 4),
              _MetaRow(
                icon: Icons.person_outline_rounded,
                text: item.createdBy.isEmpty ? '—' : item.createdBy,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (showPaymentLink) ...[
                    Expanded(
                      child: _ActionButton(
                        icon: isGeneratingPaymentLink
                            ? null
                            : Icons.link_rounded,
                        label: isGeneratingPaymentLink
                            ? 'Sending...'
                            : 'Payment Link',
                        color: DashboardColors.primary,
                        onTap: isGeneratingPaymentLink
                            ? null
                            : onGeneratePaymentLink,
                        loading: isGeneratingPaymentLink,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.palette_outlined,
                      label: 'Branding Kit',
                      color: DashboardColors.purple,
                      onTap: onBrandingKit,
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

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('complet') || s.contains('approv') || s.contains('clear')) {
      return DashboardColors.success;
    }
    if (s.contains('reject') || s.contains('cancel') || s.contains('fail')) {
      return DashboardColors.error;
    }
    if (s.contains('progress') || s.contains('partial')) {
      return DashboardColors.warning;
    }
    return DashboardColors.primary;
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: emphasize
            ? DashboardColors.errorLight
            : DashboardColors.primaryLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: DashboardColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: emphasize ? DashboardColors.error : DashboardColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    this.filled = false,
  });

  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: filled ? Colors.white : color,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: DashboardColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: DashboardColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    this.icon,
    this.onTap,
    this.loading = false,
  });

  final IconData? icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.35)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (loading)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          else if (icon != null)
            Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
