import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  final String id;
  final String name;
  final String contentType;
  final int size;
  final String storagePath;
  final String downloadUrl;
  final DateTime createdAt;

  const Attachment({
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
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Attachment.fromMap(String id, Map<String, dynamic> map) => Attachment(
    id: id,
    name: map['name'] as String? ?? '',
    contentType: map['contentType'] as String? ?? 'application/octet-stream',
    size: (map['size'] as num?)?.toInt() ?? 0,
    storagePath: map['storagePath'] as String? ?? '',
    downloadUrl: map['downloadUrl'] as String? ?? '',
    createdAt: (map['createdAt'] is Timestamp)
        ? (map['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
  );

  @override
  List<Object?> get props => [
    id,
    name,
    contentType,
    size,
    storagePath,
    downloadUrl,
    createdAt,
  ];
}
