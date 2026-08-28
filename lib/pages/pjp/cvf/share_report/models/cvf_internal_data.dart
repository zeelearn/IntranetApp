// Models for GetPJPCVFEmail.responseData.internal_data[].
class CvfClassInfo {
  CvfClassInfo({
    required this.classId,
    required this.className,
  });

  final int classId;
  final String className;

  factory CvfClassInfo.fromJson(Map<String, dynamic> json) {
    return CvfClassInfo(
      classId: _asInt(json['Class_Id'] ?? json['class_Id'] ?? json['classId']),
      className: _str(json['Class_Name'] ?? json['class_Name'] ?? json['className']),
    );
  }

  Map<String, dynamic> toJson() => {
        'Class_Id': classId,
        'Class_Name': className,
      };
}

class CvfClassCount {
  CvfClassCount({
    required this.classId,
    required this.className,
    this.cnt,
  });

  final int classId;
  final String className;
  int? cnt;

  factory CvfClassCount.fromJson(Map<String, dynamic> json) {
    return CvfClassCount(
      classId: _asInt(json['Class_Id'] ?? json['class_Id']),
      className: _str(json['Class_Name'] ?? json['class_Name']),
      cnt: _asIntOrNull(json['cnt'] ?? json['Cnt'] ?? json['stud_number']),
    );
  }

  Map<String, dynamic> toJson() => {
        'Class_Id': classId,
        'Class_Name': className,
        'cnt': cnt ?? 0,
      };
}

class CvfStudListItem {
  CvfStudListItem({
    required this.classId,
    required this.className,
    this.studNumber,
    this.studNumberAsPerVisit,
  });

  final int classId;
  final String className;
  final int? studNumber;
  final int? studNumberAsPerVisit;

  factory CvfStudListItem.fromJson(Map<String, dynamic> json) {
    return CvfStudListItem(
      classId: _asInt(json['Class_Id']),
      className: _str(json['Class_Name']),
      studNumber: _asIntOrNull(json['stud_number']),
      studNumberAsPerVisit: _asIntOrNull(json['stud_number_as_per_visit']),
    );
  }

  Map<String, dynamic> toJson() => {
        'Class_Id': classId,
        'Class_Name': className,
        'stud_number': studNumber ?? 0,
        'stud_number_as_per_visit': studNumberAsPerVisit ?? 0,
      };
}

class CvfStudCountYear {
  CvfStudCountYear({
    required this.academicYearId,
    this.isCurrAy = false,
    this.studList = const [],
  });

  final int academicYearId;
  final bool isCurrAy;
  final List<CvfStudListItem> studList;

  factory CvfStudCountYear.fromJson(Map<String, dynamic> json) {
    return CvfStudCountYear(
      academicYearId: _asInt(json['academicyear_id'] ?? json['academic_year_id']),
      isCurrAy: _asInt(json['is_curr_ay']) == 1 ||
          _str(json['is_curr_ay']).toLowerCase() == 'true',
      studList: _mapList(json['stud_list'], CvfStudListItem.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
        'academicyear_id': academicYearId,
        'is_curr_ay': isCurrAy ? 1 : 0,
        'stud_list': studList.map((e) => e.toJson()).toList(),
      };
}

class CvfKitListItem {
  CvfKitListItem({
    required this.classId,
    required this.className,
    this.kitNumber,
  });

  final int classId;
  final String className;
  final int? kitNumber;

  factory CvfKitListItem.fromJson(Map<String, dynamic> json) {
    return CvfKitListItem(
      classId: _asInt(json['Class_Id']),
      className: _str(json['Class_Name']),
      kitNumber: _asIntOrNull(json['kit_number']),
    );
  }

  Map<String, dynamic> toJson() => {
        'Class_Id': classId,
        'Class_Name': className,
        'kit_number': kitNumber ?? 0,
      };
}

class CvfKitCountYear {
  CvfKitCountYear({
    required this.academicYearId,
    this.kitList = const [],
  });

  final int academicYearId;
  final List<CvfKitListItem> kitList;

  factory CvfKitCountYear.fromJson(Map<String, dynamic> json) {
    return CvfKitCountYear(
      academicYearId: _asInt(json['academicyear_id'] ?? json['academic_year_id']),
      kitList: _mapList(json['kit_list'], CvfKitListItem.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
        'academicyear_id': academicYearId,
        'kit_list': kitList.map((e) => e.toJson()).toList(),
      };
}

/// One item from `enr_status_array` — e.g. `"SENIOR KG - Batch 2"`.
class CvfEnrStatusItem {
  CvfEnrStatusItem({
    this.batch = '',
    this.totalChild,
    this.teacherName = '',
    this.doj = '',
    this.tutelage = '',
    this.pto,
  });

  String batch;

  /// Null when API sends null — UI shows empty.
  int? totalChild;
  String teacherName;
  String doj;
  String tutelage;

  /// Null when API sends null — UI shows empty.
  int? pto;

  factory CvfEnrStatusItem.fromJson(Map<String, dynamic> json) {
    return CvfEnrStatusItem(
      batch: _str(json['batch'] ?? json['Batch']),
      totalChild: _asIntOrNull(
        json['totalChild'] ?? json['total_child'] ?? json['tot'],
      ),
      teacherName: _str(
        json['teacherName'] ?? json['Teacher_Name'] ?? json['tn'],
      ),
      doj: _str(json['doj'] ?? json['DOJ']),
      tutelage: _str(json['tutelage'] ?? json['tt']),
      pto: _asIntOrNull(json['pto'] ?? json['PTO']),
    );
  }

  Map<String, dynamic> toJson() => {
        'batch': batch,
        'totalChild': totalChild ?? 0,
        'teacherName': teacherName.trim(),
        'doj': doj.trim(),
        'tutelage': tutelage.trim().toUpperCase(),
        'pto': pto ?? 0,
      };
}

/// First element of `internal_data` used by Share Report enrolment tables.
class CvfInternalData {
  CvfInternalData({
    this.franchiseeCode = '',
    this.franchiseeName = '',
    this.contactPerson = '',
    this.requestedPenteMind = 'No',
    this.classList = const [],
    this.studCountArray = const [],
    this.kitCountArray = const [],
    this.headCnt = const [],
    this.regCnt = const [],
    this.enrStatusArray = const [],
    this.isDraft = true,
    this.isSubmitted = false,
    this.dateOfVisit = '',
    this.am = '',
    this.yearOfEstablishment = 0,
    this.isBrandingIndented = '',
    this.brandingIndentDetails = '',
    this.academicYearId = 0,
    this.cm = const [],
    this.rawExtras = const {},
  });

  String franchiseeCode;
  String franchiseeName;
  String contactPerson;

  /// Centre branding Yes/No — UI toggle is always disabled.
  String requestedPenteMind;

  List<CvfClassInfo> classList;
  List<CvfStudCountYear> studCountArray;
  List<CvfKitCountYear> kitCountArray;
  List<CvfClassCount> headCnt;
  List<CvfClassCount> regCnt;
  List<CvfEnrStatusItem> enrStatusArray;

  bool isDraft;
  bool isSubmitted;
  String dateOfVisit;
  String am;
  int yearOfEstablishment;
  String isBrandingIndented;
  String brandingIndentDetails;
  int academicYearId;
  List<Map<String, dynamic>> cm;

  /// Preserved unknown keys for round-trip on send.
  Map<String, dynamic> rawExtras;

  bool get brandingUpgraded {
    final t = requestedPenteMind.trim().toLowerCase();
    return t == 'yes' || t == 'y' || t == '1' || t == 'true';
  }

  List<String> get classHeaders =>
      classList.map((e) => e.className).where((e) => e.isNotEmpty).toList();

  int? headCountOrNull(int classId) {
    for (final c in headCnt) {
      if (c.classId == classId) return c.cnt;
    }
    return null;
  }

  int headCountFor(int classId) => headCountOrNull(classId) ?? 0;

  void setHeadCount(int classId, int? value) {
    for (final c in headCnt) {
      if (c.classId == classId) {
        c.cnt = value;
        return;
      }
    }
  }

  int? regCountOrNull(int classId) {
    for (final c in regCnt) {
      if (c.classId == classId) return c.cnt;
    }
    return null;
  }

  int regCountFor(int classId) => regCountOrNull(classId) ?? 0;

  void setRegCount(int classId, int? value) {
    for (final c in regCnt) {
      if (c.classId == classId) {
        c.cnt = value;
        return;
      }
    }
  }

  factory CvfInternalData.fromJson(Map<String, dynamic> json) {
    final known = {
      'Franchisee_code',
      'Franchisee_name',
      'ContactPerson',
      'Requested_PenteMind',
      'class_list',
      'stud_count_array',
      'kit_count_array',
      'head_cnt',
      'reg_cnt',
      'enr_status_array',
      'is_draft',
      'is_submitted',
      'dateOfVisit',
      'AM',
      'YearOfEstablishment',
      'IsBrandingIndented',
      'BrandingIndentDetails',
      'academic_year_id',
      'cm',
    };

    final extras = <String, dynamic>{};
    json.forEach((k, v) {
      if (!known.contains(k)) extras[k] = v;
    });

    return CvfInternalData(
      franchiseeCode: _str(json['Franchisee_code'] ?? json['franchisee_code']),
      franchiseeName: _str(json['Franchisee_name'] ?? json['franchisee_name']),
      contactPerson: _str(json['ContactPerson'] ?? json['contactPerson']),
      requestedPenteMind: _str(
        json['Requested_PenteMind'] ?? json['requested_PenteMind'],
        fallback: 'No',
      ),
      classList: _mapList(json['class_list'], CvfClassInfo.fromJson),
      studCountArray: _mapList(json['stud_count_array'], CvfStudCountYear.fromJson),
      kitCountArray: _mapList(json['kit_count_array'], CvfKitCountYear.fromJson),
      headCnt: _mapList(json['head_cnt'], CvfClassCount.fromJson),
      regCnt: _mapList(json['reg_cnt'], CvfClassCount.fromJson),
      enrStatusArray: _mapList(json['enr_status_array'], CvfEnrStatusItem.fromJson),
      isDraft: _asBool(json['is_draft'], fallback: true),
      isSubmitted: _asBool(json['is_submitted'], fallback: false),
      dateOfVisit: _str(json['dateOfVisit']),
      am: _str(json['AM']),
      yearOfEstablishment: _asInt(json['YearOfEstablishment']),
      isBrandingIndented: _str(json['IsBrandingIndented']),
      brandingIndentDetails: _str(json['BrandingIndentDetails']),
      academicYearId: _asInt(json['academic_year_id']),
      cm: _mapList(
        json['cm'],
        (m) => Map<String, dynamic>.from(m),
      ),
      rawExtras: extras,
    ).._ensureCountsForClasses();
  }

  /// Guarantee head/reg rows exist for every class in [classList].
  /// Missing rows start with null cnt so UI shows empty (not forced 0).
  void _ensureCountsForClasses() {
    for (final cls in classList) {
      if (!headCnt.any((c) => c.classId == cls.classId)) {
        headCnt = [
          ...headCnt,
          CvfClassCount(
            classId: cls.classId,
            className: cls.className,
            cnt: null,
          ),
        ];
      }
      if (!regCnt.any((c) => c.classId == cls.classId)) {
        regCnt = [
          ...regCnt,
          CvfClassCount(
            classId: cls.classId,
            className: cls.className,
            cnt: null,
          ),
        ];
      }
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...rawExtras,
      'Franchisee_code': franchiseeCode,
      'Franchisee_name': franchiseeName,
      'ContactPerson': contactPerson,
      'Requested_PenteMind': requestedPenteMind,
      'cm': cm,
      'stud_count_array': studCountArray.map((e) => e.toJson()).toList(),
      'kit_count_array': kitCountArray.map((e) => e.toJson()).toList(),
      'class_list': classList.map((e) => e.toJson()).toList(),
      'is_draft': isDraft,
      'dateOfVisit': dateOfVisit,
      'is_submitted': isSubmitted,
      'AM': am,
      'YearOfEstablishment': yearOfEstablishment,
      'IsBrandingIndented': isBrandingIndented,
      'BrandingIndentDetails': brandingIndentDetails,
      'academic_year_id': academicYearId,
      'head_cnt': headCnt.map((e) => e.toJson()).toList(),
      'reg_cnt': regCnt.map((e) => e.toJson()).toList(),
      'enr_status_array': enrStatusArray.map((e) => e.toJson()).toList(),
    };
  }

  static CvfInternalData? firstFrom(dynamic raw) {
    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is Map) {
        return CvfInternalData.fromJson(Map<String, dynamic>.from(first));
      }
    }
    if (raw is Map) {
      return CvfInternalData.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }
}

String _str(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return fallback;
  return text;
}

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return 0;
  return int.tryParse(text) ?? 0;
}

/// Returns `null` when value is null / blank / `"null"` so UI can show empty.
int? _asIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return int.tryParse(text);
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  final t = value.toString().trim().toLowerCase();
  if (t == '1' || t == 'true' || t == 'yes') return true;
  if (t == '0' || t == 'false' || t == 'no') return false;
  return fallback;
}

List<T> _mapList<T>(
  dynamic raw,
  T Function(Map<String, dynamic>) mapper,
) {
  if (raw is! List) return const [];
  final out = <T>[];
  for (final e in raw) {
    if (e is Map) out.add(mapper(Map<String, dynamic>.from(e)));
  }
  return out;
}
