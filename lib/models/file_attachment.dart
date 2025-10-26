import 'dart:convert';
import 'package:uuid/uuid.dart';

class FileAttachment {
  final String id;
  final String name;
  final String path;
  final String? mimeType;
  final int? sizeBytes;

  FileAttachment({
    String? id,
    required this.name,
    required this.path,
    this.mimeType,
    this.sizeBytes,
  }) : id = id ?? Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
    };
  }

  factory FileAttachment.fromMap(Map<String, dynamic> map) {
    return FileAttachment(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      path: map['path'] ?? '',
      mimeType: map['mimeType'],
      sizeBytes: map['sizeBytes'],
    );
  }

  String toJson() => json.encode(toMap());
}
