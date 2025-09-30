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
    'createdAt': createdAt.toIso8601String(),
  };

  factory Attachment.fromMap(String id, Map<String, dynamic> map) => Attachment(
    id: id,
    name: map['name'] as String,
    contentType: map['contentType'] as String,
    size: (map['size'] as num).toInt(),
    storagePath: map['storagePath'] as String,
    downloadUrl: map['downloadUrl'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
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
