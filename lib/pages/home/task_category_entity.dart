import 'package:flutter/material.dart';

class TaskCategoryEntity {
  final List<TaskCategoryItemEntity> taskCategoryList;

  TaskCategoryEntity({required this.taskCategoryList});
}

class TaskCategoryItemEntity  {
  final int? id;
  final String title;

  final LinearGradient gradient;
  final dynamic action;

  TaskCategoryItemEntity(
      {this.id, required this.title,required this.gradient,required this.action});

  TaskCategoryItemEntity copyWith({
    int? id,
    String? title,
    LinearGradient? gradient,
    dynamic action
  }) {
    return TaskCategoryItemEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      gradient: gradient ?? this.gradient,
      action : action ?? this.action
    );
  }
}
