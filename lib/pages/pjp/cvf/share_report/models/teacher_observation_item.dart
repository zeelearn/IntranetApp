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
}
