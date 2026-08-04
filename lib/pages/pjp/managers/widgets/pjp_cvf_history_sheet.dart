import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:flutter/material.dart';

Future<void> showPjpCvfHistorySheet(BuildContext context, PJPInfo pjp) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PjpCvfHistorySheet(pjp: pjp),
  );
}

class _PjpCvfHistorySheet extends StatelessWidget {
  const _PjpCvfHistorySheet({required this.pjp});

  final PJPInfo pjp;

  @override
  Widget build(BuildContext context) {
    final cvfs = pjp.getDetailedPJP ?? const <GetDetailedPJP>[];
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pjp.displayName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'CVF History · ${cvfs.length} visit(s) · PJP #${pjp.PJP_Id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (cvfs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.assignment_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'No CVF details available',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  itemCount: cvfs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _CvfDetailCard(cvf: cvfs[index], index: index + 1);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CvfDetailCard extends StatelessWidget {
  const _CvfDetailCard({required this.cvf, required this.index});

  final GetDetailedPJP cvf;
  final int index;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(cvf.Status);
    final categories = (cvf.purpose ?? const <Purpose>[])
        .map((p) => p.categoryName.trim())
        .where((n) => n.isNotEmpty && n.toUpperCase() != 'NA')
        .toSet()
        .toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kPrimaryLightColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kPrimaryLightColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _display(cvf.franchiseeName),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF263238),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _display(cvf.Status).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Franchisee Code',
            value: _display(cvf.franchiseeCode),
          ),
          _InfoRow(
            icon: Icons.confirmation_number_outlined,
            label: 'PJPCVF Id',
            value: _display(cvf.PJPCVF_Id),
          ),
          _InfoRow(
            icon: Icons.category_outlined,
            label: 'Activity',
            value: _display(cvf.ActivityTitle),
          ),
          _InfoRow(
            icon: Icons.event_outlined,
            label: 'Visit',
            value:
                '${_safeDate(cvf.visitDate)} · ${_display(cvf.visitTime)}',
          ),
          if (_hasValue(cvf.DateTimeIn))
            _InfoRow(
              icon: Icons.login,
              label: 'Check In',
              value: _safeDateTime(cvf.DateTimeIn),
            ),
          if (_hasValue(cvf.DateTimeOut))
            _InfoRow(
              icon: Icons.logout,
              label: 'Check Out',
              value: _safeDateTime(cvf.DateTimeOut),
            ),
          if (_hasValue(cvf.Address) || _hasValue(cvf.CheckInAddress))
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: _hasValue(cvf.CheckInAddress)
                  ? cvf.CheckInAddress
                  : cvf.Address,
            ),
          if (_hasValue(cvf.remarks))
            _InfoRow(
              icon: Icons.notes_outlined,
              label: 'Remarks',
              value: cvf.remarks,
            ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: categories.map((name) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCE93D8)),
                  ),
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    final s = status.trim().toLowerCase();
    if (s.contains('complet')) return const Color(0xFF2E7D32);
    if (s.contains('check in')) return const Color(0xFFEF6C00);
    if (s.contains('cancel') || s.contains('reject')) {
      return Colors.red.shade700;
    }
    return kPrimaryLightColor;
  }

  bool _hasValue(String? value) {
    final v = (value ?? '').trim();
    return v.isNotEmpty && v.toUpperCase() != 'NA' && v != 'null';
  }

  String _display(String? value) {
    return _hasValue(value) ? value!.trim() : '-';
  }

  String _safeDate(String value) {
    if (!_hasValue(value)) return '-';
    try {
      return Utility.getShortDate(value).toString();
    } catch (_) {
      return value;
    }
  }

  String _safeDateTime(String value) {
    if (!_hasValue(value)) return '-';
    try {
      return Utility.getShortDateTime(value).toString();
    } catch (_) {
      return value;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF37474F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
