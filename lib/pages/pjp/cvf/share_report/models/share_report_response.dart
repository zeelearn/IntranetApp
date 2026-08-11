class ShareReportResponse {
  ShareReportResponse({
    required this.success,
    required this.message,
    this.statusCode = 200,
  });

  final bool success;
  final String message;
  final int statusCode;

  factory ShareReportResponse.fromJson(Map<String, dynamic> json, {int statusCode = 200}) {
    final code = statusCode;
    final msg = (json['responseMessage'] ??
            json['message'] ??
            json['Message'] ??
            '')
        .toString();
    final ok = code >= 200 &&
        code < 300 &&
        (json['statusCode'] == null ||
            json['statusCode'] == 200 ||
            json['success'] == true);
    return ShareReportResponse(
      success: ok,
      message: msg.isEmpty
          ? (ok ? 'Report sent successfully.' : 'Unable to send report.')
          : msg,
      statusCode: (json['statusCode'] is int) ? json['statusCode'] as int : code,
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
