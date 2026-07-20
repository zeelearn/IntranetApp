import 'package:equatable/equatable.dart';

/// Parsed task counts from API `taskcount` (e.g. `C-28,IP-0,P-9`).
class TaskSummary extends Equatable {
  const TaskSummary({
    this.completed = 0,
    this.inProgress = 0,
    this.pending = 0,
    this.bpCompleted = 0,
  });

  final int completed;
  final int inProgress;
  final int pending;
  final int bpCompleted;

  factory TaskSummary.parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const TaskSummary();
    }
    var completed = 0;
    var inProgress = 0;
    var pending = 0;
    var bpCompleted = 0;

    for (final part in raw.split(',')) {
      final token = part.trim();
      if (token.isEmpty) continue;
      final dash = token.indexOf('-');
      if (dash <= 0) continue;
      final key = token.substring(0, dash).trim().toUpperCase();
      final value = int.tryParse(token.substring(dash + 1).trim()) ?? 0;
      switch (key) {
        case 'C':
          completed = value;
          break;
        case 'IP':
          inProgress = value;
          break;
        case 'P':
          pending = value;
          break;
        case 'BPC':
        case 'BP':
          bpCompleted = value;
          break;
      }
    }
    return TaskSummary(
      completed: completed,
      inProgress: inProgress,
      pending: pending,
      bpCompleted: bpCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'completed': completed,
        'inProgress': inProgress,
        'pending': pending,
        'bpCompleted': bpCompleted,
      };

  factory TaskSummary.fromJson(Map<String, dynamic> json) => TaskSummary(
        completed: _asInt(json['completed']),
        inProgress: _asInt(json['inProgress']),
        pending: _asInt(json['pending']),
        bpCompleted: _asInt(json['bpCompleted']),
      );

  TaskSummary copyWith({
    int? completed,
    int? inProgress,
    int? pending,
    int? bpCompleted,
  }) {
    return TaskSummary(
      completed: completed ?? this.completed,
      inProgress: inProgress ?? this.inProgress,
      pending: pending ?? this.pending,
      bpCompleted: bpCompleted ?? this.bpCompleted,
    );
  }

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  @override
  List<Object?> get props => [completed, inProgress, pending, bpCompleted];
}
