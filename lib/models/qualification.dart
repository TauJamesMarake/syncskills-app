class Qualification {
  final String id;
  final String title;
  final String institution;
  final String yearCompleted;
  final String certificateNumber;
  final String certificatePath;
  bool isActive;

  Qualification({
    required this.id,
    required this.title,
    required this.institution,
    required this.yearCompleted,
    required this.certificateNumber,
    required this.certificatePath,
    this.isActive = true,
  });
  get certificateFilePath => certificatePath;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'institution': institution,
      'year_completed': yearCompleted,
      'certificateNumber': certificateNumber,
      'certificatePath': certificatePath,
      'isActive': isActive,
    };
  }

  factory Qualification.fromMap(Map<String, dynamic> map) {
    return Qualification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      institution: map['institution'] ?? '',
      yearCompleted: map['year_completed'] ?? '',
      certificateNumber: map['certificateNumber'] ?? '',
      certificatePath: map['certificatePath'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  String toJson() => toMap().toString();
}
