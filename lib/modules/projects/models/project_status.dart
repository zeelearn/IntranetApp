import 'package:equatable/equatable.dart';

class ProjectStatus extends Equatable {
  const ProjectStatus({
    required this.statusId,
    required this.count,
  });

  final int statusId;
  final int count;

  factory ProjectStatus.fromJson(Map<String, dynamic> json) {
    return ProjectStatus(
      statusId: _asInt(json['status_id']),
      count: _asInt(json['c']),
    );
  }

  Map<String, dynamic> toJson() => {
        'status_id': statusId,
        'c': count,
      };

  ProjectStatus copyWith({
    int? statusId,
    int? count,
  }) {
    return ProjectStatus(
      statusId: statusId ?? this.statusId,
      count: count ?? this.count,
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [statusId, count];
}
