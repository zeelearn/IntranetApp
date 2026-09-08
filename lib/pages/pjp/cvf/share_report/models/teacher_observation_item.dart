class TeacherObservationItem {
  TeacherObservationItem({
    this.teacherName = '',
    this.className = '',
    this.appStatus = '',
  });

  String teacherName;
  String className;

  /// Canonical App Status — one of [appStatusOptions], or empty.
  String appStatus;

  static const appStatusOptions = [
    'Active',
    'Inactive',
    'Pending',
    'Not Available',
  ];

  /// Maps API / user casing variants to a canonical option.
  /// Returns `''` when empty or unrecognized (safe for DropdownButton).
  static String normalizeAppStatus(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return '';

    for (final option in appStatusOptions) {
      if (option.toLowerCase() == text.toLowerCase()) {
        return option;
      }
    }

    // Common aliases from backend / older drafts.
    final compact = text.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
    const aliases = <String, String>{
      'active': 'Active',
      'inactive': 'Inactive',
      'pending': 'Pending',
      'notavailable': 'Not Available',
      'na': 'Not Available',
      'n/a': 'Not Available',
      'yes': 'Active',
      'no': 'Inactive',
      'y': 'Active',
      'n': 'Inactive',
    };
    return aliases[compact] ?? aliases[text.toLowerCase()] ?? '';
  }

  /// Value safe for [DropdownButtonFormField]: option match or `null`.
  String? get dropdownAppStatus {
    final normalized = normalizeAppStatus(appStatus);
    if (normalized.isEmpty) return null;
    return appStatusOptions.contains(normalized) ? normalized : null;
  }

  bool get hasValidAppStatus => dropdownAppStatus != null;

  Map<String, dynamic> toJson() => {
        'TeacherName': teacherName.trim(),
        'Class': className.trim(),
        'AppStatus': normalizeAppStatus(appStatus),
      };

  /// Send API object: `{ "tn": "...", "class": "...", "app": "..." }`.
  Map<String, String>? toApiObject() {
    final name = teacherName.trim();
    final cls = className.trim();
    final status = normalizeAppStatus(appStatus);
    if (name.isEmpty && cls.isEmpty && status.isEmpty) return null;
    return {
      'tn': name,
      'class': cls,
      'app': status,
    };
  }

  /// Legacy / preview string: `"Teacher 1 – LKG – Active"`.
  String toApiString() {
    final name = teacherName.trim();
    final cls = className.trim();
    final status = normalizeAppStatus(appStatus);
    if (name.isEmpty && cls.isEmpty && status.isEmpty) return '';
    return [name, cls, status].where((e) => e.isNotEmpty).join(' – ');
  }

  factory TeacherObservationItem.fromApiString(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return TeacherObservationItem();
    final parts = text
        .split(RegExp(r'\s*[–—-]\s*'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return TeacherObservationItem();
    return TeacherObservationItem(
      teacherName: parts.isNotEmpty ? parts[0] : '',
      className: parts.length > 1 ? parts[1] : '',
      appStatus: parts.length > 2
          ? normalizeAppStatus(parts.sublist(2).join(' – '))
          : '',
    );
  }

  factory TeacherObservationItem.fromApiObject(Map<String, dynamic> map) {
    return TeacherObservationItem(
      teacherName: (map['tn'] ??
              map['TeacherName'] ??
              map['teacherName'] ??
              map['Name'] ??
              '')
          .toString()
          .trim(),
      className: (map['class'] ??
              map['Class'] ??
              map['className'] ??
              map['ClassName'] ??
              '')
          .toString()
          .trim(),
      appStatus: normalizeAppStatus(
        (map['app'] ??
                map['AppStatus'] ??
                map['appStatus'] ??
                map['Status'] ??
                '')
            .toString(),
      ),
    );
  }
}
