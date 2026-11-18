import 'package:equatable/equatable.dart';
import 'package:Intranet/modules/projects/utils/indent_action_roles.dart';

class IndentItem extends Equatable {
  const IndentItem({
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
    required this.createdBy,
    required this.paymentStatus,
    required this.projectStatus,
    required this.businessRefId,
    this.canIndentBk = 0,
    this.brandingIndentId,
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
  final String createdBy;
  final String paymentStatus;
  final String projectStatus;
  final int businessRefId;

  /// From Pentemind_Illume_Status `CanIndentBK`. Only `1` grants finance actions.
  final int canIndentBk;

  /// Branding indent id if created.
  final String? brandingIndentId;

  /// Compatibility alias for existing callers.
  int get franchiseeId => businessRefId;

  /// Payment link is allowed only when payment is not completed.
  bool get canGeneratePaymentLink =>
      paymentStatus.trim().toLowerCase() != 'completed';

  /// Branding Kit / finance actions when API flag is 1.
  bool get canAccessFinanceActions =>
      IndentActionRoles.canAccessFinanceActions(canIndentBk);

  /// Show Branding Kit when `CanIndentBK == 1`.
  bool get canShowBrandingKit => canAccessFinanceActions;

  /// Returns true if a Branding Kit indent has already been created.
  bool get hasBrandingIndent =>
      brandingIndentId != null && brandingIndentId!.trim().isNotEmpty;

  /// Message displayed when a Branding Kit indent already exists.
  String get brandingIndentMessage =>
      'Branding Kit indent already created with Indent Id ${brandingIndentId?.trim()}.';

  factory IndentItem.fromJson(Map<String, dynamic> json) {
    return IndentItem(
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
      createdBy: _asString(json['Created_By']),
      paymentStatus: _asString(json['PaymentStatus']),
      projectStatus: _asString(json['ProjectStatus']),
      businessRefId: _asInt(json['BusinessRef_Id'] ?? json['Franchisee_Id']),
      canIndentBk: _asInt(_field(json, 'CanIndentBK')),
      brandingIndentId: _asNullableString(_field(json, 'Branding_Indent_Id')),
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
        'Created_By': createdBy,
        'PaymentStatus': paymentStatus,
        'ProjectStatus': projectStatus,
        'BusinessRef_Id': businessRefId,
        'CanIndentBK': canIndentBk,
        'Branding_Indent_Id': brandingIndentId,
      };

  static String? _asNullableString(dynamic v) {
    if (v == null) return null;
    final text = v.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  static String _asString(dynamic v) => v?.toString().trim() ?? '';

  static dynamic _field(Map<String, dynamic> json, String key) {
    if (json.containsKey(key)) return json[key];
    final normalizedKey = key.replaceAll('_', '').toLowerCase();
    for (final entry in json.entries) {
      if (entry.key.replaceAll('_', '').toLowerCase() == normalizedKey) {
        return entry.value;
      }
    }
    return null;
  }

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is bool) return v ? 1 : 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    final text = v.toString().trim().toLowerCase();
    if (text == 'true' || text == 'yes') return 1;
    if (text == 'false' || text == 'no') return 0;
    return num.tryParse(text)?.toInt() ?? 0;
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
        createdBy,
        paymentStatus,
        projectStatus,
        businessRefId,
        canIndentBk,
        brandingIndentId,
      ];
}

class IndentListResponse extends Equatable {
  const IndentListResponse({
    required this.success,
    required this.data,
  });

  final int success;
  final List<IndentItem> data;

  factory IndentListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = <IndentItem>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          list.add(IndentItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return IndentListResponse(
      success: IndentItem._asInt(json['success']),
      data: list,
    );
  }

  @override
  List<Object?> get props => [success, data];
}

class IndentListFilter extends Equatable {
  const IndentListFilter({
    this.indentStatus,
    this.paymentStatus,
    this.projectStatus,
    this.zoneCode,
    this.stateName,
  });

  static const empty = IndentListFilter();

  final String? indentStatus;
  final String? paymentStatus;
  final String? projectStatus;
  final String? zoneCode;
  final String? stateName;

  bool get hasActiveFilters =>
      (indentStatus?.isNotEmpty ?? false) ||
      (paymentStatus?.isNotEmpty ?? false) ||
      (projectStatus?.isNotEmpty ?? false) ||
      (zoneCode?.isNotEmpty ?? false) ||
      (stateName?.isNotEmpty ?? false);

  int get activeCount {
    var n = 0;
    if (indentStatus?.isNotEmpty ?? false) n++;
    if (paymentStatus?.isNotEmpty ?? false) n++;
    if (projectStatus?.isNotEmpty ?? false) n++;
    if (zoneCode?.isNotEmpty ?? false) n++;
    if (stateName?.isNotEmpty ?? false) n++;
    return n;
  }

  IndentListFilter copyWith({
    String? indentStatus,
    String? paymentStatus,
    String? projectStatus,
    String? zoneCode,
    String? stateName,
    bool clearIndentStatus = false,
    bool clearPaymentStatus = false,
    bool clearProjectStatus = false,
    bool clearZoneCode = false,
    bool clearStateName = false,
  }) {
    return IndentListFilter(
      indentStatus:
          clearIndentStatus ? null : (indentStatus ?? this.indentStatus),
      paymentStatus:
          clearPaymentStatus ? null : (paymentStatus ?? this.paymentStatus),
      projectStatus:
          clearProjectStatus ? null : (projectStatus ?? this.projectStatus),
      zoneCode: clearZoneCode ? null : (zoneCode ?? this.zoneCode),
      stateName: clearStateName ? null : (stateName ?? this.stateName),
    );
  }

  @override
  List<Object?> get props => [
        indentStatus,
        paymentStatus,
        projectStatus,
        zoneCode,
        stateName,
      ];
}
