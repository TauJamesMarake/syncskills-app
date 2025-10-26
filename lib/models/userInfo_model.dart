// import 'package:cloud_firestore/cloud_firestore.dart';

class UserPersonalInfo {
  final String fullName;
  final String lastName;
  final String email;
  final String role;
  final String department;
  final String jobTitle;
  final String employmentType;
  final int yearsOfExperience;

  UserPersonalInfo({
    required this.fullName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.department,
    required this.jobTitle,
    required this.employmentType,
    required this.yearsOfExperience,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'department': department,
      'jobTitle': jobTitle,
      'employmentType': employmentType,
      'yearsOfExperience': yearsOfExperience,
    };
  }

  factory UserPersonalInfo.fromMap(Map<String, dynamic> map) {
    return UserPersonalInfo(
      fullName: map['fullName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      department: map['department'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      employmentType: map['employmentType'] ?? '',
      yearsOfExperience: map['yearsOfExperience'] ?? 0,
    );
  }
}
