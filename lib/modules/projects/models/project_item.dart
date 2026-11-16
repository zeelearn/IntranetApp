import 'package:equatable/equatable.dart';

import 'task_summary.dart';
import '../utils/indent_action_roles.dart';

class ProjectItem extends Equatable {
  const ProjectItem({
    required this.crmId,
    required this.docUrl,
    required this.approvedDate,
    required this.franchiseeCode,
    required this.franchiseeName,
    required this.franchiseeId,
    this.businessRefId = 0,
    this.canIndentBk = 0,
    required this.deadline,
    required this.createdBy,
    required this.totalNoOfTask,
    required this.catchmentArea,
    required this.taskcount,
    required this.tierName,
    required this.feeType,
    this.title = '',
    this.responsiblePerson = '',
    this.id = '',
    this.illumeIndentId,
    this.brandingIndentId,
    // this.canIndentBk = 0,
    this.isIllumeDispatchConfirmed,
    this.isBrandingDispatchConfirmed,
    this.showIllumeDispatchBtn = 0,
    this.showBrandingDispatchBtn = 0,
  });

  final String crmId;
  final String docUrl;
  final String approvedDate;
  final String franchiseeCode;
  final String franchiseeName;
  final int franchiseeId;
  final int businessRefId;
  final int canIndentBk;
  final String deadline;
  final String createdBy;
  final int totalNoOfTask;
  final String catchmentArea;
  final String taskcount;
  final String tierName;
  final String feeType;
  final String title;
  final String responsiblePerson;
  final String id;

  /// Illume / CK indent id from GetAllProjectList_new.
  final String? illumeIndentId;

  /// Branding / BK indent id from GetAllProjectList_new.
  final String? brandingIndentId;

  /// API permission flag for Branding Kit and other finance actions.
  // final int canIndentBk;

  /// Only `true` means confirmed; `null` and `false` are not confirmed.
  final bool? isIllumeDispatchConfirmed;

  /// Only `true` means confirmed; `null` and `false` are not confirmed.
  final bool? isBrandingDispatchConfirmed;

  /// Only `1` enables the CK dispatch button.
  final int showIllumeDispatchBtn;

  /// Only `1` enables the BK dispatch button.
  final int showBrandingDispatchBtn;

  TaskSummary get taskSummary => TaskSummary.parse(taskcount);

  /// Shows CK dispatch UI when an indent exists and dispatch is allowed or done.
  bool get shouldShowCKDispatch =>
      _hasIndentId(illumeIndentId) &&
      (showIllumeDispatchBtn == 1 || isCKDispatchConfirmed);

  /// Shows BK dispatch UI when an indent exists and dispatch is allowed or done.
  bool get shouldShowBKDispatch =>
      _hasIndentId(brandingIndentId) &&
      (showBrandingDispatchBtn == 1 || isBKDispatchConfirmed);

  bool get canShowBrandingKit =>
      IndentActionRoles.canAccessFinanceActions(canIndentBk);

  bool get isCKDispatchConfirmed => isIllumeDispatchConfirmed == true;

  bool get isBKDispatchConfirmed => isBrandingDispatchConfirmed == true;

  /// Enabled clickable "Confirm CK Dispatch".
  bool get canConfirmCKDispatch =>
      shouldShowCKDispatch && !isCKDispatchConfirmed;

  /// Enabled clickable "Confirm BK Dispatch".
  bool get canConfirmBKDispatch =>
      shouldShowBKDispatch && !isBKDispatchConfirmed;

  bool get canAddBrandingOrder => canIndentBk == 1;

  factory ProjectItem.fromJson(Map<String, dynamic> json) {
    return ProjectItem(
      crmId: _asString(json['CRM_id'] ?? json['project_id']),
      docUrl: _asString(json['Doc_url']),
      approvedDate: _asString(json['approved_date']),
      franchiseeCode: _asString(json['Franchisee_Code']),
      franchiseeName: _asString(json['Franchisee_Name']),
      franchiseeId: _asInt(json['Franchisee_Id']),
      businessRefId: _asInt(json['BusinessRef_Id']),
      canIndentBk: _asInt(_field(json, 'CanIndentBK')),
      deadline: _asString(json['deadline']),
      createdBy: _asString(json['CreatedBy']),
      totalNoOfTask: _asInt(json['TotalNoOfTask']),
      catchmentArea: _asString(json['CatchmentArea']),
      taskcount: _asString(json['taskcount']),
      tierName: _asString(json['Tier_Name']),
      feeType: _asString(json['Fee_Type']),
      title: _asString(json['Title'] ?? json['title']),
      responsiblePerson: _asString(
        json['Responsible_person'] ?? json['responsiblePerson'],
      ),
      id: _asString(json['id']),
      illumeIndentId: _asNullableString(_field(json, 'Illume_Indent_Id')),
      brandingIndentId: _asNullableString(_field(json, 'Branding_Indent_Id')),
      isIllumeDispatchConfirmed:
          _asNullableBool(_field(json, 'is_illume_dispatch_confirmed')),
      isBrandingDispatchConfirmed:
          _asNullableBool(_field(json, 'is_branding_dispatch_confirmed')),
      showIllumeDispatchBtn: _asInt(_field(json, 'show_illume_dispatch_btn')),
      showBrandingDispatchBtn:
          _asInt(_field(json, 'show_branding_dispatch_btn')),
    );
  }

  Map<String, dynamic> toJson() => {
        'CRM_id': crmId,
        'Doc_url': docUrl,
        'approved_date': approvedDate,
        'Franchisee_Code': franchiseeCode,
        'Franchisee_Name': franchiseeName,
        'Franchisee_Id': franchiseeId,
        'BusinessRef_Id': businessRefId,
        'CanIndentBK': canIndentBk,
        'deadline': deadline,
        'CreatedBy': createdBy,
        'TotalNoOfTask': totalNoOfTask,
        'CatchmentArea': catchmentArea,
        'taskcount': taskcount,
        'Tier_Name': tierName,
        'Fee_Type': feeType,
        'Title': title,
        'Responsible_person': responsiblePerson,
        'id': id,
        'Illume_Indent_Id': illumeIndentId,
        'Branding_Indent_Id': brandingIndentId,
        'CanIndentBK': canIndentBk,
        'is_illume_dispatch_confirmed': isIllumeDispatchConfirmed,
        'is_branding_dispatch_confirmed': isBrandingDispatchConfirmed,
        'show_illume_dispatch_btn': showIllumeDispatchBtn,
        'show_branding_dispatch_btn': showBrandingDispatchBtn,
      };

  ProjectItem copyWith({
    String? crmId,
    String? docUrl,
    String? approvedDate,
    String? franchiseeCode,
    String? franchiseeName,
    int? franchiseeId,
    int? businessRefId,
    int? canIndentBk,
    String? deadline,
    String? createdBy,
    int? totalNoOfTask,
    String? catchmentArea,
    String? taskcount,
    String? tierName,
    String? feeType,
    String? title,
    String? responsiblePerson,
    String? id,
    String? illumeIndentId,
    String? brandingIndentId,
    // int? canIndentBk,
    bool? isIllumeDispatchConfirmed,
    bool? isBrandingDispatchConfirmed,
    int? showIllumeDispatchBtn,
    int? showBrandingDispatchBtn,
    bool clearIllumeIndentId = false,
    bool clearBrandingIndentId = false,
    bool clearIsIllumeDispatchConfirmed = false,
    bool clearIsBrandingDispatchConfirmed = false,
  }) {
    return ProjectItem(
      crmId: crmId ?? this.crmId,
      docUrl: docUrl ?? this.docUrl,
      approvedDate: approvedDate ?? this.approvedDate,
      franchiseeCode: franchiseeCode ?? this.franchiseeCode,
      franchiseeName: franchiseeName ?? this.franchiseeName,
      franchiseeId: franchiseeId ?? this.franchiseeId,
      businessRefId: businessRefId ?? this.businessRefId,
      canIndentBk: canIndentBk ?? this.canIndentBk,
      deadline: deadline ?? this.deadline,
      createdBy: createdBy ?? this.createdBy,
      totalNoOfTask: totalNoOfTask ?? this.totalNoOfTask,
      catchmentArea: catchmentArea ?? this.catchmentArea,
      taskcount: taskcount ?? this.taskcount,
      tierName: tierName ?? this.tierName,
      feeType: feeType ?? this.feeType,
      title: title ?? this.title,
      responsiblePerson: responsiblePerson ?? this.responsiblePerson,
      id: id ?? this.id,
      illumeIndentId:
          clearIllumeIndentId ? null : (illumeIndentId ?? this.illumeIndentId),
      brandingIndentId: clearBrandingIndentId
          ? null
          : (brandingIndentId ?? this.brandingIndentId),
      // canIndentBk: canIndentBk ?? this.canIndentBk,
      isIllumeDispatchConfirmed: clearIsIllumeDispatchConfirmed
          ? null
          : (isIllumeDispatchConfirmed ?? this.isIllumeDispatchConfirmed),
      isBrandingDispatchConfirmed: clearIsBrandingDispatchConfirmed
          ? null
          : (isBrandingDispatchConfirmed ?? this.isBrandingDispatchConfirmed),
      showIllumeDispatchBtn:
          showIllumeDispatchBtn ?? this.showIllumeDispatchBtn,
      showBrandingDispatchBtn:
          showBrandingDispatchBtn ?? this.showBrandingDispatchBtn,
    );
  }

  static bool _hasIndentId(String? value) =>
      value != null && value.trim().isNotEmpty;

  static dynamic _field(Map<String, dynamic> json, String key) {
    if (json.containsKey(key)) return json[key];
    final normalizedKey = _normalizeKey(key);
    for (final entry in json.entries) {
      if (_normalizeKey(entry.key) == normalizedKey) return entry.value;
    }
    return null;
  }

  static String _normalizeKey(String key) =>
      key.replaceAll('_', '').toLowerCase();

  static String _asString(dynamic v) => v?.toString() ?? '';

  static String? _asNullableString(dynamic v) {
    if (v == null) return null;
    final text = v.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
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

  /// Only explicit true / 1 / "true" → true; false / 0 / "false" → false;
  /// null / empty / unknown → null.
  static bool? _asNullableBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) {
      if (v == 1) return true;
      if (v == 0) return false;
      return null;
    }
    final text = v.toString().trim().toLowerCase();
    if (text.isEmpty || text == 'null') return null;
    if (text == 'true' || text == '1' || text == 'yes' || text == 'y') {
      return true;
    }
    if (text == 'false' || text == '0' || text == 'no' || text == 'n') {
      return false;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        crmId,
        docUrl,
        approvedDate,
        franchiseeCode,
        franchiseeName,
        franchiseeId,
        businessRefId,
        canIndentBk,
        deadline,
        createdBy,
        totalNoOfTask,
        catchmentArea,
        taskcount,
        tierName,
        feeType,
        title,
        responsiblePerson,
        id,
        illumeIndentId,
        brandingIndentId,
        canIndentBk,
        isIllumeDispatchConfirmed,
        isBrandingDispatchConfirmed,
        showIllumeDispatchBtn,
        showBrandingDispatchBtn,
      ];
}

/// CK (Illume) or BK (Branding) dispatch confirmation.
enum DispatchConfirmType { ck, bk }

extension DispatchConfirmTypeX on DispatchConfirmType {
  String get label => this == DispatchConfirmType.ck ? 'CK' : 'BK';

  String get shortName => label;
}

class ProjectListResponse extends Equatable {
  const ProjectListResponse({
    required this.success,
    required this.data,
  });

  final int success;
  final List<ProjectItem> data;

  factory ProjectListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = <ProjectItem>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          list.add(ProjectItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return ProjectListResponse(
      success: ProjectItem._asInt(json['success']),
      data: list,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data.map((e) => e.toJson()).toList(growable: false),
      };

  ProjectListResponse copyWith({
    int? success,
    List<ProjectItem>? data,
  }) {
    return ProjectListResponse(
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [success, data];
}
