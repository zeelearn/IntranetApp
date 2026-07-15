import 'package:equatable/equatable.dart';

class ProjectListFilter extends Equatable {
  const ProjectListFilter({
    this.feeType,
    this.tierName,
    this.createdBy,
    this.catchmentArea,
    this.approvedFrom,
    this.approvedTo,
    this.deadlineFrom,
    this.deadlineTo,
  });

  final String? feeType;
  final String? tierName;
  final String? createdBy;
  final String? catchmentArea;
  final DateTime? approvedFrom;
  final DateTime? approvedTo;
  final DateTime? deadlineFrom;
  final DateTime? deadlineTo;

  bool get hasActiveFilters =>
      (feeType != null && feeType!.isNotEmpty) ||
      (tierName != null && tierName!.isNotEmpty) ||
      (createdBy != null && createdBy!.isNotEmpty) ||
      (catchmentArea != null && catchmentArea!.isNotEmpty) ||
      approvedFrom != null ||
      approvedTo != null ||
      deadlineFrom != null ||
      deadlineTo != null;

  ProjectListFilter copyWith({
    String? feeType,
    String? tierName,
    String? createdBy,
    String? catchmentArea,
    DateTime? approvedFrom,
    DateTime? approvedTo,
    DateTime? deadlineFrom,
    DateTime? deadlineTo,
    bool clearFeeType = false,
    bool clearTierName = false,
    bool clearCreatedBy = false,
    bool clearCatchmentArea = false,
    bool clearApprovedFrom = false,
    bool clearApprovedTo = false,
    bool clearDeadlineFrom = false,
    bool clearDeadlineTo = false,
  }) {
    return ProjectListFilter(
      feeType: clearFeeType ? null : (feeType ?? this.feeType),
      tierName: clearTierName ? null : (tierName ?? this.tierName),
      createdBy: clearCreatedBy ? null : (createdBy ?? this.createdBy),
      catchmentArea:
          clearCatchmentArea ? null : (catchmentArea ?? this.catchmentArea),
      approvedFrom:
          clearApprovedFrom ? null : (approvedFrom ?? this.approvedFrom),
      approvedTo: clearApprovedTo ? null : (approvedTo ?? this.approvedTo),
      deadlineFrom:
          clearDeadlineFrom ? null : (deadlineFrom ?? this.deadlineFrom),
      deadlineTo: clearDeadlineTo ? null : (deadlineTo ?? this.deadlineTo),
    );
  }

  static const empty = ProjectListFilter();

  @override
  List<Object?> get props => [
        feeType,
        tierName,
        createdBy,
        catchmentArea,
        approvedFrom,
        approvedTo,
        deadlineFrom,
        deadlineTo,
      ];
}
