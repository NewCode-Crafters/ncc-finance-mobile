import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bytebank/features/transactions/models/attachment.dart';
import 'package:bytebank/infrastructure/dtos/attachment_dto.dart';

class AttachmentMapper {
  static Attachment fromDto(AttachmentDto dto) => Attachment(
    id: dto.id,
    name: dto.name,
    contentType: dto.contentType,
    size: dto.size,
    storagePath: dto.storagePath,
    downloadUrl: dto.downloadUrl,
    createdAt: dto.createdAt.toDate(),
  );

  static AttachmentDto toDto(Attachment model) => AttachmentDto(
    id: model.id,
    name: model.name,
    contentType: model.contentType,
    size: model.size,
    storagePath: model.storagePath,
    downloadUrl: model.downloadUrl,
    createdAt: Timestamp.fromDate(model.createdAt),
  );
}
