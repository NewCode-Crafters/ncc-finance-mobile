import 'package:cloud_firestore/cloud_firestore.dart';

class AttachmentDto {
  final String id;
  final String name;
  final String contentType;
  final int size;
  final String storagePath;
  final String downloadUrl;
  final Timestamp createdAt;

  AttachmentDto({
    required this.id,
    required this.name,
    required this.contentType,
    required this.size,
    required this.storagePath,
    required this.downloadUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'contentType': contentType,
    'size': size,
    'storagePath': storagePath,
    'downloadUrl': downloadUrl,
    'createdAt': createdAt,
  };

  factory AttachmentDto.fromMap(String id, Map<String, dynamic> map) =>
      AttachmentDto(
        id: id,
        name: map['name'] as String? ?? '',
        contentType:
            map['contentType'] as String? ?? 'application/octet-stream',
        size: (map['size'] as num?)?.toInt() ?? 0,
        storagePath: map['storagePath'] as String? ?? '',
        downloadUrl: map['downloadUrl'] as String? ?? '',
        createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      );
}
