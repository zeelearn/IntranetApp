import 'package:equatable/equatable.dart';

/// Result of IndentPaymentEmail API.
class PaymentLinkResult extends Equatable {
  const PaymentLinkResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;

  factory PaymentLinkResult.fromJson(Map<String, dynamic> json) {
    final successCode = _asInt(json['success']);
    final data = json['data'];
    var message = 'Unable to generate payment link. Please try again.';

    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map) {
        final map = Map<String, dynamic>.from(first);
        final msg = (map['msg'] ?? map['Msg'] ?? map['message'] ?? '')
            .toString()
            .trim();
        if (msg.isNotEmpty) message = msg;
      } else if (first is String && first.trim().isNotEmpty) {
        message = first.trim();
      }
    } else if (data is String && data.trim().isNotEmpty) {
      message = data.trim();
    } else if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final msg = (map['msg'] ?? map['Msg'] ?? map['message'] ?? '')
          .toString()
          .trim();
      if (msg.isNotEmpty) message = msg;
    } else if (json['message'] != null) {
      final msg = json['message'].toString().trim();
      if (msg.isNotEmpty) message = msg;
    }

    final lower = message.toLowerCase();
    final ok = successCode == 200 ||
        lower.contains('success') ||
        lower.contains('sent') ||
        lower.contains('generated');

    return PaymentLinkResult(success: ok, message: message);
  }

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => [success, message];
}
