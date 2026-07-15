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

  TaskSummary get taskSummary => TaskSummary.parse(taskcount);

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
    );
  }

  static String _asString(dynamic v) => v?.toString() ?? '';

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
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
      ];
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
