/// Business row from Projects `GetBusiness` API (`Business_Id` / `Business_Name`).
///
/// These ids are **Projects/BPMS-only** and must not be confused with intranet
/// login `business_ID` values.
class ProjectBusiness {
  const ProjectBusiness({
    required this.businessId,
    required this.businessName,
  });

  final int businessId;
  final String businessName;

  factory ProjectBusiness.fromJson(Map<String, dynamic> json) {
    return ProjectBusiness(
      businessId: _asInt(json['Business_Id'] ?? json['business_Id']),
      businessName: _asString(json['Business_Name'] ?? json['business_Name']),
    );
  }

  Map<String, dynamic> toJson() => {
        'Business_Id': businessId,
        'Business_Name': businessName,
      };

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    final s = value.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return '';
    return s;
  }
}

/// Envelope for `GetBusiness`.
class ProjectBusinessResponse {
  const ProjectBusinessResponse({
    required this.success,
    required this.data,
  });

  final int success;
  final List<ProjectBusiness> data;

  factory ProjectBusinessResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = <ProjectBusiness>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          list.add(ProjectBusiness.fromJson(item));
        } else if (item is Map) {
          list.add(ProjectBusiness.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return ProjectBusinessResponse(
      success: ProjectBusiness._asInt(json['success']),
      data: list,
    );
  }
}
