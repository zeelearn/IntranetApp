import 'package:equatable/equatable.dart';

/// Initial tab when opening Project Details from the project list.
enum ProjectDetailTab {
  communication,
  indent,
  tasks,
  documents,
}

class FranchiseeDetails extends Equatable {
  const FranchiseeDetails({
    this.attendee = '',
    this.operatingStatus = '',
    this.franchiseeCode = '',
    this.franchiseeName = '',
    this.franchiseeId = 0,
    this.address1 = '',
    this.address2 = '',
    this.place = '',
    this.pinCode = '',
    this.cityName = '',
    this.stateName = '',
    this.emailId = '',
    this.mobileNo = '',
    this.franId = '',
    this.tierId = 0,
    this.tierName = '',
    this.feeType = '',
    this.currentAcadYearId = 0,
    this.leadId = '',
    this.locationType = '',
  });

  final String attendee;
  final String operatingStatus;
  final String franchiseeCode;
  final String franchiseeName;
  final int franchiseeId;
  final String address1;
  final String address2;
  final String place;
  final String pinCode;
  final String cityName;
  final String stateName;
  final String emailId;
  final String mobileNo;
  final String franId;
  final int tierId;
  final String tierName;
  final String feeType;
  final int currentAcadYearId;
  final String leadId;
  final String locationType;

  bool get isActive {
    final s = operatingStatus.trim().toUpperCase();
    return s == 'A' || s == 'ACTIVE';
  }

  String get statusLabel => isActive ? 'Active' : 'InActive';

  factory FranchiseeDetails.fromJson(Map<String, dynamic> json) {
    return FranchiseeDetails(
      attendee: _str(json['Attendee']),
      operatingStatus: _str(json['Operating_Status']),
      franchiseeCode: _str(json['Franchisee_Code']),
      franchiseeName: _str(json['Franchisee_Name']),
      franchiseeId: _int(json['Franchisee_Id']),
      address1: _str(json['Address1']),
      address2: _str(json['Address2']),
      place: _str(json['Place']),
      pinCode: _str(json['Pin_Code']),
      cityName: _str(json['City_Name']),
      stateName: _str(json['State_Name']),
      emailId: _str(json['Email_Id']),
      mobileNo: _str(json['Mobile_No']),
      franId: _str(json['FranId']),
      tierId: _int(json['Tier_id']),
      tierName: _str(json['Tier_Name']),
      feeType: _str(json['Fee_Type']),
      currentAcadYearId: _int(json['CurrentAcadYear_ID']),
      leadId: _str(json['LeadId']),
      locationType: _str(json['Location_Type']),
    );
  }

  Map<String, dynamic> toJson() => {
        'Attendee': attendee,
        'Operating_Status': operatingStatus,
        'Franchisee_Code': franchiseeCode,
        'Franchisee_Name': franchiseeName,
        'Franchisee_Id': franchiseeId,
        'Address1': address1,
        'Address2': address2,
        'Place': place,
        'Pin_Code': pinCode,
        'City_Name': cityName,
        'State_Name': stateName,
        'Email_Id': emailId,
        'Mobile_No': mobileNo,
        'FranId': franId,
        'Tier_id': tierId,
        'Tier_Name': tierName,
        'Fee_Type': feeType,
        'CurrentAcadYear_ID': currentAcadYearId,
        'LeadId': leadId,
        'Location_Type': locationType,
      };

  static String _str(dynamic v) => v?.toString().trim() ?? '';

  static int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [franchiseeId, franchiseeCode, leadId];
}

class IndentDetailItem extends Equatable {
  const IndentDetailItem({
    required this.indentId,
    required this.academicYearId,
    required this.indentType,
    required this.indentNo,
    required this.indentDate,
    required this.indentAmount,
    required this.apprAmount,
    required this.docketNo,
    required this.indentStatus,
    required this.dueAmount,
    required this.createdBy,
  });

  final int indentId;
  final int academicYearId;
  final String indentType;
  final String indentNo;
  final String indentDate;
  final double indentAmount;
  final double apprAmount;
  final String docketNo;
  final String indentStatus;
  final double dueAmount;
  final String createdBy;

  double get paidAmount {
    final paid = apprAmount - dueAmount;
    return paid < 0 ? 0 : paid;
  }

  factory IndentDetailItem.fromJson(Map<String, dynamic> json) {
    return IndentDetailItem(
      indentId: FranchiseeDetails._int(json['Indent_Id']),
      academicYearId: FranchiseeDetails._int(json['Academicyear_Id']),
      indentType: FranchiseeDetails._str(json['Indent_Type']),
      indentNo: FranchiseeDetails._str(json['Indent_No']),
      indentDate: FranchiseeDetails._str(json['Indent_Date']),
      indentAmount: _double(json['Indent_Amount']),
      apprAmount: _double(json['Appr_Amount']),
      docketNo: FranchiseeDetails._str(json['Docket_No']),
      indentStatus: FranchiseeDetails._str(json['Indent_Status']),
      dueAmount: _double(json['Due_Amount']),
      createdBy: FranchiseeDetails._str(json['Created_By']),
    );
  }

  Map<String, dynamic> toJson() => {
        'Indent_Id': indentId,
        'Academicyear_Id': academicYearId,
        'Indent_Type': indentType,
        'Indent_No': indentNo,
        'Indent_Date': indentDate,
        'Indent_Amount': indentAmount,
        'Appr_Amount': apprAmount,
        'Docket_No': docketNo,
        'Indent_Status': indentStatus,
        'Due_Amount': dueAmount,
        'Created_By': createdBy,
      };

  static double _double(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [indentId, indentNo];
}

class ProjectDocumentItem extends Equatable {
  const ProjectDocumentItem({
    required this.name,
    required this.docUrl,
  });

  final String name;
  final String docUrl;

  factory ProjectDocumentItem.fromJson(Map<String, dynamic> json) {
    return ProjectDocumentItem(
      name: FranchiseeDetails._str(json['Name']),
      docUrl: FranchiseeDetails._str(json['DocURL'] ?? json['DocUrl']),
    );
  }

  Map<String, dynamic> toJson() => {
        'Name': name,
        'DocURL': docUrl,
      };

  @override
  List<Object?> get props => [name, docUrl];
}

class ProjectCommunicationItem extends Equatable {
  const ProjectCommunicationItem({
    required this.rowId,
    required this.id,
    required this.msgType,
    required this.toAddress,
    required this.ccAddress,
    required this.emailSubject,
    required this.emailBody,
    required this.emailStatus,
    required this.createdDate,
    required this.createdTime,
    required this.response,
  });

  final int rowId;
  final int id;
  final String msgType;
  final String toAddress;
  final String ccAddress;
  final String emailSubject;
  final String emailBody;
  final String emailStatus;
  final String createdDate;
  final String createdTime;
  final String response;

  /// Plain-text preview stripped of HTML tags.
  String get bodyPreview {
    final stripped = plainTextBody;
    if (stripped.length <= 160) return stripped;
    return '${stripped.substring(0, 160)}…';
  }

  /// Decoded body ready for HTML / plain rendering (handles `&lt;` escaped HTML).
  String get decodedEmailBody {
    final raw = emailBody.trim();
    if (raw.isEmpty) return '';
    final looksEscaped = raw.contains('&lt;') &&
        !RegExp(r'<(p|div|br|table|html|body|span)\b', caseSensitive: false)
            .hasMatch(raw);
    return looksEscaped ? _unescapeHtml(raw) : raw;
  }

  bool get isHtmlBody {
    final b = decodedEmailBody.toLowerCase();
    return b.contains('<html') ||
        b.contains('<body') ||
        b.contains('<div') ||
        b.contains('<p') ||
        b.contains('<br') ||
        b.contains('<table') ||
        b.contains('<span') ||
        b.contains('<ul') ||
        b.contains('<li');
  }

  String get plainTextBody {
    return decodedEmailBody
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .trim();
  }

  static String _unescapeHtml(String input) {
    return input
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAllMapped(
          RegExp(r'&#(\d+);'),
          (m) => String.fromCharCode(int.parse(m[1]!)),
        )
        .replaceAllMapped(
          RegExp(r'&#x([0-9a-fA-F]+);'),
          (m) => String.fromCharCode(int.parse(m[1]!, radix: 16)),
        );
  }

  factory ProjectCommunicationItem.fromJson(Map<String, dynamic> json) {
    return ProjectCommunicationItem(
      rowId: FranchiseeDetails._int(json['RowID']),
      id: FranchiseeDetails._int(json['ID']),
      msgType: FranchiseeDetails._str(json['Msg_Type']),
      toAddress: FranchiseeDetails._str(json['To_Address']),
      ccAddress: FranchiseeDetails._str(json['CC_Address']),
      emailSubject: FranchiseeDetails._str(json['Email_Subject']),
      emailBody: FranchiseeDetails._str(json['Email_Body']),
      emailStatus: FranchiseeDetails._str(json['Email_Status']),
      createdDate: FranchiseeDetails._str(json['Created_Date']),
      createdTime: FranchiseeDetails._str(json['createdtime']),
      response: FranchiseeDetails._str(json['Response']),
    );
  }

  Map<String, dynamic> toJson() => {
        'RowID': rowId,
        'ID': id,
        'Msg_Type': msgType,
        'To_Address': toAddress,
        'CC_Address': ccAddress,
        'Email_Subject': emailSubject,
        'Email_Body': emailBody,
        'Email_Status': emailStatus,
        'Created_Date': createdDate,
        'createdtime': createdTime,
        'Response': response,
      };

  @override
  List<Object?> get props => [rowId, id];
}

class ProjectDetailData extends Equatable {
  const ProjectDetailData({
    required this.franDetails,
    required this.indentDetails,
    required this.documents,
    required this.communication,
    this.syncedAt,
  });

  final FranchiseeDetails franDetails;
  final List<IndentDetailItem> indentDetails;
  final List<ProjectDocumentItem> documents;
  final List<ProjectCommunicationItem> communication;
  final DateTime? syncedAt;

  int get totalIndents => indentDetails.length;

  double get totalIndentAmount =>
      indentDetails.fold(0, (sum, e) => sum + e.indentAmount);

  double get totalDueAmount =>
      indentDetails.fold(0, (sum, e) => sum + e.dueAmount);

  double get totalPaidAmount =>
      indentDetails.fold(0, (sum, e) => sum + e.paidAmount);

  factory ProjectDetailData.fromJson(Map<String, dynamic> json) {
    final franRaw = json['franDetails'];
    final fran = franRaw is Map
        ? FranchiseeDetails.fromJson(Map<String, dynamic>.from(franRaw))
        : const FranchiseeDetails();

    List<T> parseList<T>(
      dynamic raw,
      T Function(Map<String, dynamic>) map,
    ) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => map(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    }

    DateTime? synced;
    final syncedRaw = json['syncedAt']?.toString();
    if (syncedRaw != null && syncedRaw.isNotEmpty) {
      synced = DateTime.tryParse(syncedRaw);
    }

    return ProjectDetailData(
      franDetails: fran,
      indentDetails: parseList(json['indentDetails'], IndentDetailItem.fromJson),
      documents: parseList(json['documents'], ProjectDocumentItem.fromJson),
      communication:
          parseList(json['communication'], ProjectCommunicationItem.fromJson),
      syncedAt: synced,
    );
  }

  /// Parses API envelope `data[0]` (or first map in nested lists).
  factory ProjectDetailData.fromApiEnvelope(Map<String, dynamic> decoded) {
    final raw = decoded['data'];
    Map<String, dynamic>? first;
    if (raw is List && raw.isNotEmpty) {
      final item = raw.first;
      if (item is Map) {
        first = Map<String, dynamic>.from(item);
      }
    } else if (raw is Map) {
      first = Map<String, dynamic>.from(raw);
    }
    if (first == null) {
      return ProjectDetailData(
        franDetails: const FranchiseeDetails(),
        indentDetails: const [],
        documents: const [],
        communication: const [],
        syncedAt: DateTime.now(),
      );
    }
    return ProjectDetailData.fromJson(first).copyWith(syncedAt: DateTime.now());
  }

  Map<String, dynamic> toJson() => {
        'franDetails': franDetails.toJson(),
        'indentDetails':
            indentDetails.map((e) => e.toJson()).toList(growable: false),
        'documents': documents.map((e) => e.toJson()).toList(growable: false),
        'communication':
            communication.map((e) => e.toJson()).toList(growable: false),
        if (syncedAt != null) 'syncedAt': syncedAt!.toIso8601String(),
      };

  ProjectDetailData copyWith({
    FranchiseeDetails? franDetails,
    List<IndentDetailItem>? indentDetails,
    List<ProjectDocumentItem>? documents,
    List<ProjectCommunicationItem>? communication,
    DateTime? syncedAt,
  }) {
    return ProjectDetailData(
      franDetails: franDetails ?? this.franDetails,
      indentDetails: indentDetails ?? this.indentDetails,
      documents: documents ?? this.documents,
      communication: communication ?? this.communication,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  bool get isStaleForToday {
    final at = syncedAt;
    if (at == null) return true;
    final now = DateTime.now();
    return at.year != now.year || at.month != now.month || at.day != now.day;
  }

  @override
  List<Object?> get props =>
      [franDetails, indentDetails, documents, communication, syncedAt];
}
