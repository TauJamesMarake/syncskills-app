import 'dart:convert';
import 'package:uuid/uuid.dart';

class PlannedCourse {
  final String id;
  final String courseTitle;
  final DateTime? expectedCompletionDate;

  PlannedCourse({
    String? id,
    required this.courseTitle,
    this.expectedCompletionDate,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseTitle': courseTitle,
      'expectedCompletionDate': expectedCompletionDate?.toIso8601String(),
    };
  }

  factory PlannedCourse.fromMap(Map<String, dynamic> map) {
    return PlannedCourse(
      id: map['id'] ?? '',
      courseTitle: map['courseTitle'] ?? '',
      expectedCompletionDate: map['expectedCompletionDate'] != null
          ? DateTime.parse(map['expectedCompletionDate'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());
}
