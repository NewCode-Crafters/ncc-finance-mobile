import 'dart:io';
import 'package:bytebank/domain/repositories/attachment_repository.dart';
import 'package:bytebank/domain/entities/attachment.dart';

class UploadAttachmentUseCase {
  final AttachmentRepository repository;

  UploadAttachmentUseCase(this.repository);

  Future<Attachment> call({
    required String userId,
    required String transactionId,
    required File file,
  }) {
    return repository.uploadSingle(
      userId: userId,
      transactionId: transactionId,
      file: file,
    );
  }
}
