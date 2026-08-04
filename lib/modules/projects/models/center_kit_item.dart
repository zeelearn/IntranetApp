import 'package:equatable/equatable.dart';

class CenterKitItem extends Equatable {
  const CenterKitItem({
    required this.franchiseeCode,
    required this.franchiseeName,
    required this.zoneCode,
    required this.stateName,
    required this.agreementNo,
    required this.pil,
    required this.apprAmount,
    required this.dueAmount,
    required this.dueDate,
    required this.indentId,
    required this.indentStatus,
    required this.projectManager,
    required this.paymentStatus,
  });

  final String franchiseeCode;
  final String franchiseeName;
  final String zoneCode;
  final String stateName;
  final String agreementNo;
  final double pil;
  final double? apprAmount;
  final double dueAmount;
  final String dueDate;
  final int indentId;
  final String indentStatus;
  final String projectManager;
  final String paymentStatus;

  factory CenterKitItem.fromJson(Map<String, dynamic> json) {
    return CenterKitItem(
      franchiseeCode: _asString(json['Franchisee_Code']),
      franchiseeName: _asString(json['Franchisee_Name']),
      zoneCode: _asString(json['Zone_Code']),
      stateName: _asString(json['State_Name']),
      agreementNo: _asString(json['Agreement_No']),
      pil: _asDouble(json['PIL']),
      apprAmount: _asDoubleOrNull(json['Appr_Amount']),
      dueAmount: _asDouble(json['Due_Amount']),
      dueDate: _asString(json['Due_Date']),
      indentId: _asInt(json['indent_Id'] ?? json['Indent_Id']),
      indentStatus: _asString(json['Indent_Status']),
      projectManager: _asString(json['Project_Manager']),
      paymentStatus: _asString(json['PaymentStatus']),
    );
  }

  Map<String, dynamic> toJson() => {
        'Franchisee_Code': franchiseeCode,
        'Franchisee_Name': franchiseeName,
        'Zone_Code': zoneCode,
        'State_Name': stateName,
        'Agreement_No': agreementNo,
        'PIL': pil,
        'Appr_Amount': apprAmount,
        'Due_Amount': dueAmount,
        'Due_Date': dueDate,
        'indent_Id': indentId,
        'Indent_Status': indentStatus,
        'Project_Manager': projectManager,
        'PaymentStatus': paymentStatus,
      };

  static String _asString(dynamic v) => v?.toString().trim() ?? '';

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _asDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static double? _asDoubleOrNull(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  @override
  List<Object?> get props => [
        franchiseeCode,
        franchiseeName,
        zoneCode,
        stateName,
        agreementNo,
        pil,
        apprAmount,
        dueAmount,
        dueDate,
        indentId,
        indentStatus,
        projectManager,
        paymentStatus,
      ];
}

class CenterKitListResponse extends Equatable {
  const CenterKitListResponse({
    required this.success,
    required this.data,
  });

  final int success;
  final List<CenterKitItem> data;

  factory CenterKitListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = <CenterKitItem>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          list.add(CenterKitItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return CenterKitListResponse(
      success: CenterKitItem._asInt(json['success']),
      data: list,
    );
  }

  @override
  List<Object?> get props => [success, data];
}

class CenterKitFilter extends Equatable {
  const CenterKitFilter({
    this.indentStatus,
    this.paymentStatus,
    this.zoneCode,
    this.stateName,
    this.projectManager,
  });

  static const empty = CenterKitFilter();

  final String? indentStatus;
  final String? paymentStatus;
  final String? zoneCode;
  final String? stateName;
  final String? projectManager;

  bool get hasActiveFilters =>
      (indentStatus?.isNotEmpty ?? false) ||
      (paymentStatus?.isNotEmpty ?? false) ||
      (zoneCode?.isNotEmpty ?? false) ||
      (stateName?.isNotEmpty ?? false) ||
      (projectManager?.isNotEmpty ?? false);

  int get activeCount {
    var n = 0;
    if (indentStatus?.isNotEmpty ?? false) n++;
    if (paymentStatus?.isNotEmpty ?? false) n++;
    if (zoneCode?.isNotEmpty ?? false) n++;
    if (stateName?.isNotEmpty ?? false) n++;
    if (projectManager?.isNotEmpty ?? false) n++;
    return n;
  }

  CenterKitFilter copyWith({
    String? indentStatus,
    String? paymentStatus,
    String? zoneCode,
    String? stateName,
    String? projectManager,
    bool clearIndentStatus = false,
    bool clearPaymentStatus = false,
    bool clearZoneCode = false,
    bool clearStateName = false,
    bool clearProjectManager = false,
  }) {
    return CenterKitFilter(
      indentStatus:
          clearIndentStatus ? null : (indentStatus ?? this.indentStatus),
      paymentStatus:
          clearPaymentStatus ? null : (paymentStatus ?? this.paymentStatus),
      zoneCode: clearZoneCode ? null : (zoneCode ?? this.zoneCode),
      stateName: clearStateName ? null : (stateName ?? this.stateName),
      projectManager: clearProjectManager
          ? null
          : (projectManager ?? this.projectManager),
    );
  }

  @override
  List<Object?> get props => [
        indentStatus,
        paymentStatus,
        zoneCode,
        stateName,
        projectManager,
      ];
}
