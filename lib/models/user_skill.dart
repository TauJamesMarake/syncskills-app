import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'enums.dart';

class UserSkill {
  final String id;
  final String skillName;
  final ProficiencyLevel level;
  final DateTime addedAt;

  UserSkill({
    String? id,
    required this.skillName,
    this.level = ProficiencyLevel.novice,
    DateTime? addedAt,
  })  : id = id ?? Uuid().v4(),
        addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'skillName': skillName,
      'level': level.name,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory UserSkill.fromMap(Map<String, dynamic> map) {
    return UserSkill(
      id: map['id'] ?? '',
      skillName: map['skillName'] ?? '',
      level: map['level'] != null
          ? ProficiencyLevelX.fromString(map['level'])
          : ProficiencyLevel.novice,
      addedAt: map['addedAt'] != null
          ? DateTime.parse(map['addedAt'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
}
