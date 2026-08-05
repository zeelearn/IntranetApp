import 'package:equatable/equatable.dart';

class SendCredentialsResult extends Equatable {
  const SendCredentialsResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  factory SendCredentialsResult.fromJson(Map<String, dynamic> json) {
    final successCode = _asInt(json['success']);
    final data = json['data'];
    var message = 'Unable to send credentials. Please try again.';
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map) {
        final map = Map<String, dynamic>.from(first);
        final msg = (map['msg'] ?? map['Msg'] ?? '').toString().trim();
        if (msg.isNotEmpty) message = msg;
      }
    } else if (json['message'] != null) {
      message = json['message'].toString();
    }

    final ok = successCode == 200 ||
        message.toLowerCase().contains('successfully');
    return SendCredentialsResult(success: ok, message: message);
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => [success, message];
}

class ProjectChartUrl {
  static const base = 'https://chart.zeelearn.com/chart.html';

  static String build(String crmId) {
    final id = crmId.trim();
    return '$base?pid=$id';
  }

  static bool isValidCrmId(String crmId) => crmId.trim().isNotEmpty;
}
