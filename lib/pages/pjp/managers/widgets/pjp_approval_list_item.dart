import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:Intranet/pages/helper/constants.dart';
import 'package:Intranet/pages/helper/utils.dart';
import 'package:flutter/material.dart';

class PjpApprovalListItem extends StatelessWidget {
  const PjpApprovalListItem({
    super.key,
    required this.pjp,
    required this.selected,
    required this.selectable,
    required this.onToggle,
    required this.onOpen,
  });

  final PJPInfo pjp;
  final bool selected;
  final bool selectable;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(pjp.ApprovalStatus);
    final borderColor =
        selected ? const Color(0xFF90CAF9) : const Color(0xFFEEEEEE);
    final bgColor = selected
        ? const Color(0xFFE3F2FD).withValues(alpha: 0.35)
        : Colors.white;
    final categories = pjp.uniqueCategoryNames;
    final cvfCount = pjp.cvfCount;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: selectable
                    ? Checkbox(
                        value: selected,
                        onChanged: (_) => onToggle(),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )
                    : Icon(
                        Icons.lock_outline,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pjp.displayName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            pjp.ApprovalStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if ((pjp.employeeCode ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Code: ${pjp.employeeCode}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${_safeShortDate(pjp.fromDate)} → ${_safeShortDate(pjp.toDate)} · PJP #${pjp.PJP_Id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryLightColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'CVF: $cvfCount',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: kPrimaryLightColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                        Text(
                          'View CVF history',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (categories.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: categories.take(6).map((name) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E5F5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFCE93D8),
                              ),
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
                      if (categories.length > 6)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '+${categories.length - 6} more',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                    if (pjp.remarks.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        pjp.remarks.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'pending') return const Color(0xFFEF6C00);
    if (s.contains('approv')) return const Color(0xFF2E7D32);
    if (s == 'rejected') return Colors.red.shade700;
    return Colors.blueGrey;
  }

  String _safeShortDate(String value) {
    try {
      return Utility.getShortDate(value).toString();
    } catch (_) {
      return value;
    }
  }
}
