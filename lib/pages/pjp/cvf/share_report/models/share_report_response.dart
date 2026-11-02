class ShareReportResponse {
  ShareReportResponse({
    required this.success,
    required this.message,
    this.statusCode = 200,
  });

  final bool success;
  final String message;
  final int statusCode;

  factory ShareReportResponse.fromJson(
    Map<String, dynamic> json, {
    int statusCode = 200,
  }) {
    final apiCode = json['statusCode'];
    final code = apiCode is int ? apiCode : statusCode;
    final msg = (json['responseMessage'] ??
            json['message'] ??
            json['Message'] ??
            '')
        .toString()
        .trim();

    final httpOk = statusCode >= 200 && statusCode < 300;
    final apiOk = apiCode == null || apiCode == 200 || json['success'] == true;

    // Prefer nested responseData[0].msg when present (SendPJPCVFEmail).
    var detail = msg;
    final raw = json['responseData'];
    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is Map) {
        final nestedMsg = (first['msg'] ?? first['message'] ?? '').toString().trim();
        if (nestedMsg.isNotEmpty) detail = nestedMsg;
      }
    } else if (raw is Map) {
      final nestedMsg = (raw['msg'] ?? raw['message'] ?? '').toString().trim();
      if (nestedMsg.isNotEmpty) detail = nestedMsg;
    }

    final ok = httpOk && apiOk;
    return ShareReportResponse(
      success: ok,
      message: detail.isEmpty
          ? (ok ? 'Email Sent Successfully!' : 'Unable to send report.')
          : detail,
      statusCode: code,
    );
  }

  factory ShareReportResponse.error(String message, {int statusCode = 500}) {
    return ShareReportResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
