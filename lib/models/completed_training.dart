import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'file_attachment.dart';

class CompletedTraining {
  final String id;
  final String institution;
  final DateTime? startDate;
  final DateTime? endDate;
  final String certificateReference;
  final FileAttachment? certificate;

  CompletedTraining({
    String? id,
    required this.institution,
    this.startDate,
    this.endDate,
    required this.certificateReference,
    this.certificate,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'institution': institution,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'certificateReference': certificateReference,
      'certificate': certificate?.toMap(),
    };
  }

  factory CompletedTraining.fromMap(Map<String, dynamic> map) {
    return CompletedTraining(
      id: map['id'] ?? '',
      institution: map['institution'] ?? '',
      startDate: map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      certificateReference: map['certificateReference'] ?? '',
      certificate: map['certificate'] != null
          ? FileAttachment.fromMap(Map<String, dynamic>.from(map['certificate']))
          : null,
    );
  }

  String toJson() => json.encode(toMap());
}
