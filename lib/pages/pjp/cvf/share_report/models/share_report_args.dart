import 'package:Intranet/api/response/pjp/pjplistresponse.dart';
import 'package:intl/intl.dart';

/// Navigation args for Share Centre Visit Report — no extra PJP/CVF API.
class ShareReportArgs {
  const ShareReportArgs({
    required this.cvf,
    this.pjp,
    this.facilitatorName = '',
    this.bpEmail = '',
    this.ccEmails = const [],
  });

  final GetDetailedPJP cvf;
  final PJPInfo? pjp;
  final String facilitatorName;

  /// Static recipient — not editable in UI.
  final String bpEmail;

  /// Static CC list — not editable in UI.
  final List<String> ccEmails;

  String get pjpId {
    final fromCvf = (cvf.PJP_Id ?? '').trim();
    if (fromCvf.isNotEmpty && fromCvf != '0') return fromCvf;
    return (pjp?.PJP_Id ?? '').trim();
  }

  String get cvfId => cvf.PJPCVF_Id.trim();

  String get centreName {
    final name = cvf.franchiseeName.trim();
    if (name.isNotEmpty && name.toLowerCase() != 'null') return name;
    return 'Centre';
  }

  String get bpName {
    final name = (pjp?.displayName ?? '').trim();
    if (name.isNotEmpty && name.toLowerCase() != 'null' && name != 'NA') {
      return name;
    }
    return centreName;
  }

  String get bpCode {
    final code = cvf.franchiseeCode.trim();
    if (code.isNotEmpty && code.toLowerCase() != 'null') return code;
    return '—';
  }

  String get managerName {
    final name = (pjp?.managerName ?? '').trim();
    return name.isEmpty ? '—' : name;
  }

  String get visitDateRaw => cvf.visitDate.trim();

  String get pjpStatus {
    final s = (pjp?.ApprovalStatus ?? cvf.approvalStatus).trim();
    return s.isEmpty ? (cvf.Status.trim().isEmpty ? '—' : cvf.Status.trim()) : s;
  }

  String get cvfStatus {
    final s = cvf.Status.trim();
    return s.isEmpty ? '—' : s;
  }

  String get remarks {
    final r = (pjp?.remarks ?? cvf.remarks).toString().trim();
    if (r.isEmpty || r.toLowerCase() == 'null' || r == 'NA') return '—';
    return r;
  }

  String get pjpDateRange {
    final from = _formatDate(pjp?.fromDate ?? cvf.pjpFromDate ?? '');
    final to = _formatDate(pjp?.toDate ?? cvf.pjpToDate ?? '');
    if (from == '—' && to == '—') {
      return _formatDate(visitDateRaw);
    }
    if (from == to) return from;
    return '$from – $to';
  }

  String get checkInAddress {
    final a = cvf.AddressIn.trim();
    if (a.isEmpty || a == 'NA' || a.toLowerCase() == 'null') {
      return 'No check-in address available';
    }
    return a;
  }

  String get checkOutAddress {
    final a = cvf.AddressOut.trim();
    if (a.isEmpty || a == 'NA' || a.toLowerCase() == 'null') {
      return 'No check-out address available';
    }
    return a;
  }

  String get checkInDateTime => _formatDateTime(cvf.DateTimeIn);
  String get checkOutDateTime => _formatDateTime(cvf.DateTimeOut);

  /// True when visit is checked out / completed.
  bool get isCheckedOut {
    if (cvf.Status.trim().toLowerCase() == 'completed') return true;
    final out = cvf.DateTimeOut.trim();
    if (out.isEmpty || out == 'NA') return false;
    return !out.startsWith('1900-01-01');
  }

  String get pdfFileName => 'CVF_Report_$cvfId.pdf';

  static String _formatDate(String raw) {
    final text = raw.trim();
    if (text.isEmpty || text == 'NA') return '—';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(text));
    } catch (_) {
      return text;
    }
  }

  static String _formatDateTime(String raw) {
    final text = raw.trim();
    if (text.isEmpty || text == 'NA' || text.startsWith('1900-01-01')) {
      return '—';
    }
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(text));
    } catch (_) {
      return text;
    }
  }
}
