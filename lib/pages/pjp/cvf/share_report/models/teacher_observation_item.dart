class TeacherObservationItem {
  TeacherObservationItem({
    this.teacherName = '',
    this.className = '',
    this.appStatus = '',
  });

  String teacherName;
  String className;
  String appStatus;

  static const appStatusOptions = [
    'Active',
    'Inactive',
    'Pending',
    'Not Available',
  ];

  Map<String, dynamic> toJson() => {
        'TeacherName': teacherName.trim(),
        'Class': className.trim(),
        'AppStatus': appStatus.trim(),
      };

  /// Send API object: `{ "tn": "...", "class": "...", "app": "..." }`.
  Map<String, String>? toApiObject() {
    final name = teacherName.trim();
    final cls = className.trim();
    final status = appStatus.trim();
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
    final status = appStatus.trim();
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
      appStatus: parts.length > 2 ? parts.sublist(2).join(' – ') : '',
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
      appStatus: (map['app'] ??
              map['AppStatus'] ??
              map['appStatus'] ??
              map['Status'] ??
              '')
          .toString()
          .trim(),
    );
  }
}
