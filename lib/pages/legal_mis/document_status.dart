class Recipient {
  final int signingOrder;
  final String recipientName;
  final String recipientEmail;
  final String? role;
  final String actionType;
  final String actionStatus;

  Recipient({
    required this.signingOrder,
    required this.recipientName,
    required this.recipientEmail,
    this.role,
    required this.actionType,
    required this.actionStatus,
  });

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      signingOrder: json['signing_order'] ?? 0,
      recipientName: json['recipient_name'] ?? '',
      recipientEmail: json['recipient_email'] ?? '',
      role: json['role'],
      actionType: json['action_type'] ?? '',
      actionStatus: json['action_status'] ?? '',
    );
  }
}

class DocumentStatus {
  final String reqId;
  final String reqStatus;
  final String actionTime;
  final String signPercentage;
  final List<Recipient> recipientList;

  DocumentStatus({
    required this.reqId,
    required this.reqStatus,
    required this.actionTime,
    required this.signPercentage,
    required this.recipientList,
  });

  // Factory constructor to create a DocumentStatus from a JSON object.
  factory DocumentStatus.fromJson(Map<String, dynamic> json) {
    var list = json['recepient_list'] as List? ?? [];
    List<Recipient> recipientList =
        list.map((i) => Recipient.fromJson(i)).toList();

    return DocumentStatus(
      reqId: json['req_id'] ?? '',
      reqStatus: json['req_status'] ?? '',
      actionTime: json['action_time'] ?? '',
      signPercentage: json['sign_percentage'] ?? '',
      recipientList: recipientList,
    );
  }
}
