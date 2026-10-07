import 'package:equatable/equatable.dart';

import 'task_summary.dart';

class ProjectItem extends Equatable {
  const ProjectItem({
    required this.crmId,
    required this.docUrl,
    required this.approvedDate,
    required this.franchiseeCode,
    required this.franchiseeName,
    required this.franchiseeId,
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

  /// Only `true` means confirmed; `null` and `false` are not confirmed.
  final bool? isIllumeDispatchConfirmed;

  /// Only `true` means confirmed; `null` and `false` are not confirmed.
  final bool? isBrandingDispatchConfirmed;

  /// Only `1` enables the CK dispatch button.
  final int showIllumeDispatchBtn;

  /// Only `1` enables the BK dispatch button.
  final int showBrandingDispatchBtn;

  TaskSummary get taskSummary => TaskSummary.parse(taskcount);

  /// Eligible to show CK dispatch UI (indent present + API flag).
  bool get shouldShowCKDispatch =>
      _hasIndentId(illumeIndentId) && showIllumeDispatchBtn == 1;

  /// Eligible to show BK dispatch UI (indent present + API flag).
  bool get shouldShowBKDispatch =>
      _hasIndentId(brandingIndentId) && showBrandingDispatchBtn == 1;

  bool get isCKDispatchConfirmed => isIllumeDispatchConfirmed == true;

  bool get isBKDispatchConfirmed => isBrandingDispatchConfirmed == true;

  /// Enabled clickable "Confirm CK Dispatch".
  bool get canConfirmCKDispatch =>
      shouldShowCKDispatch && !isCKDispatchConfirmed;

  /// Enabled clickable "Confirm BK Dispatch".
  bool get canConfirmBKDispatch =>
      shouldShowBKDispatch && !isBKDispatchConfirmed;

  factory ProjectItem.fromJson(Map<String, dynamic> json) {
    return ProjectItem(
      crmId: _asString(json['CRM_id'] ?? json['project_id']),
      docUrl: _asString(json['Doc_url']),
      approvedDate: _asString(json['approved_date']),
      franchiseeCode: _asString(json['Franchisee_Code']),
      franchiseeName: _asString(json['Franchisee_Name']),
      franchiseeId: _asInt(json['Franchisee_Id']),
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
      illumeIndentId: _asNullableString(json['Illume_Indent_Id']),
      brandingIndentId: _asNullableString(json['Branding_Indent_Id']),
      isIllumeDispatchConfirmed:
          _asNullableBool(json['is_illume_dispatch_confirmed']),
      isBrandingDispatchConfirmed:
          _asNullableBool(json['is_branding_dispatch_confirmed']),
      showIllumeDispatchBtn: _asInt(json['show_illume_dispatch_btn']),
      showBrandingDispatchBtn: _asInt(json['show_branding_dispatch_btn']),
    );
  }

  Map<String, dynamic> toJson() => {
        'CRM_id': crmId,
        'Doc_url': docUrl,
        'approved_date': approvedDate,
        'Franchisee_Code': franchiseeCode,
        'Franchisee_Name': franchiseeName,
        'Franchisee_Id': franchiseeId,
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
      illumeIndentId: clearIllumeIndentId
          ? null
          : (illumeIndentId ?? this.illumeIndentId),
      brandingIndentId: clearBrandingIndentId
          ? null
          : (brandingIndentId ?? this.brandingIndentId),
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

  static String _asString(dynamic v) => v?.toString() ?? '';

  static String? _asNullableString(dynamic v) {
    if (v == null) return null;
    final text = v.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
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
