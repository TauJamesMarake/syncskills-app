import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'userInfo_model.dart';
import 'qualification.dart';
import 'user_skill.dart';
import 'planned_course.dart';
import 'completed_training.dart';
// ... existing imports (file_attachment & enums used by other model files)

/// Aggregate User model for the app.
///
/// This is intentionally lightweight and composes the existing
/// `UserPersonalInfo` and `Qualification` models. For skills,
/// planned or completed trainings we use flexible List<Map> shapes
/// for now to avoid breaking other parts of the app. You can replace
/// those with dedicated typed models later.
class User {
  final String id;
  final UserPersonalInfo personalInfo;

  /// List of qualifications (uses the existing Qualification model)
  final List<Qualification> qualifications;

  /// User skills
  final List<UserSkill> skills;

  /// Planned trainings (e.g. from CompleteProfileScreen)
  final List<PlannedCourse> plannedTrainings;

  /// Completed trainings (e.g. from CompletedTrainingsScreen)
  final List<CompletedTraining> completedTrainings;

  /// Privacy: "Public" or "Private" (matches UI strings). Consider
  /// migrating to an enum later.
  final String privacy;

  User({
    required this.id,
    required this.personalInfo,
    List<Qualification>? qualifications,
    List<UserSkill>? skills,
    List<PlannedCourse>? plannedTrainings,
    List<CompletedTraining>? completedTrainings,
    this.privacy = 'Public',
  }) : qualifications = qualifications ?? [],
       skills = skills ?? [],
       plannedTrainings = plannedTrainings ?? [],
       completedTrainings = completedTrainings ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personalInfo': personalInfo.toMap(),
      'qualifications': qualifications
          .map(
            (q) => {
              'id': q.id,
              'title': q.title,
              'institution': q.institution,
              'year': q.yearCompleted,
              'certificateNumber': q.certificateNumber,
              'certificatePath': q.certificatePath,
              'isActive': q.isActive,
            },
          )
          .toList(),
      'skills': skills.map((s) => s.toMap()).toList(),
      'plannedTrainings': plannedTrainings.map((p) => p.toMap()).toList(),
      'completedTrainings': completedTrainings.map((c) => c.toMap()).toList(),
      'privacy': privacy,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      personalInfo: map['personalInfo'] != null
          ? UserPersonalInfo.fromMap(
              Map<String, dynamic>.from(map['personalInfo']),
            )
          : UserPersonalInfo(
              fullName: '',
              lastName: '',
              email: '',
              role: '',
              department: '',
              jobTitle: '',
              employmentType: '',
              yearsOfExperience: 0,
            ),
      qualifications: map['qualifications'] != null
          ? List<Qualification>.from(
              (map['qualifications'] as List).map((q) {
                final m = Map<String, dynamic>.from(q);
                return Qualification(
                  id: m['id'] ?? '',
                  title: m['title'] ?? '',
                  institution: m['institution'] ?? '',
                  yearCompleted: m['year'] ?? '',
                  certificateNumber: m['certificateNumber'] ?? '',
                  certificatePath: m['certificatePath'] ?? '',
                  isActive: m['isActive'] ?? true,
                );
              }),
            )
          : [],
      skills: map['skills'] != null
          ? List<UserSkill>.from(
              (map['skills'] as List).map(
                (s) => UserSkill.fromMap(Map<String, dynamic>.from(s)),
              ),
            )
          : [],
      plannedTrainings: map['plannedTrainings'] != null
          ? List<PlannedCourse>.from(
              (map['plannedTrainings'] as List).map(
                (t) => PlannedCourse.fromMap(Map<String, dynamic>.from(t)),
              ),
            )
          : [],
      completedTrainings: map['completedTrainings'] != null
          ? List<CompletedTraining>.from(
              (map['completedTrainings'] as List).map(
                (t) => CompletedTraining.fromMap(Map<String, dynamic>.from(t)),
              ),
            )
          : [],
      privacy: map['privacy'] ?? 'Public',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  // Firestore helper: produce a plain map suitable for writing to Firestore.
  Map<String, dynamic> toFirestore() {
    final m = toMap();
    // Convert ISO strings to Timestamps where appropriate
    // (e.g. planned/completed trainings contain dates in iso format)
    m['plannedTrainings'] = plannedTrainings.map((p) {
      final map = p.toMap();
      if (map['expectedCompletionDate'] != null) {
        map['expectedCompletionDate'] = Timestamp.fromDate(
          DateTime.parse(map['expectedCompletionDate']),
        );
      }
      return map;
    }).toList();

    m['completedTrainings'] = completedTrainings.map((c) {
      final map = c.toMap();
      if (map['startDate'] != null)
        map['startDate'] = Timestamp.fromDate(DateTime.parse(map['startDate']));
      if (map['endDate'] != null)
        map['endDate'] = Timestamp.fromDate(DateTime.parse(map['endDate']));
      return map;
    }).toList();

    // skills and qualifications are already simple maps/strings
    return m;
  }

  // Firestore helper: create User from a DocumentSnapshot
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    // Convert Timestamps back to ISO strings for our fromMap constructor
    if (data['plannedTrainings'] is List) {
      data['plannedTrainings'] = (data['plannedTrainings'] as List).map((t) {
        final m = Map<String, dynamic>.from(t);
        if (m['expectedCompletionDate'] is Timestamp) {
          m['expectedCompletionDate'] =
              (m['expectedCompletionDate'] as Timestamp)
                  .toDate()
                  .toIso8601String();
        }
        return m;
      }).toList();
    }

    if (data['completedTrainings'] is List) {
      data['completedTrainings'] = (data['completedTrainings'] as List).map((
        t,
      ) {
        final m = Map<String, dynamic>.from(t);
        if (m['startDate'] is Timestamp)
          m['startDate'] = (m['startDate'] as Timestamp)
              .toDate()
              .toIso8601String();
        if (m['endDate'] is Timestamp)
          m['endDate'] = (m['endDate'] as Timestamp).toDate().toIso8601String();
        return m;
      }).toList();
    }

    return User.fromMap(Map<String, dynamic>.from(data)..['id'] = doc.id);
  }
}
