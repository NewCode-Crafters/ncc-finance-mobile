import 'dart:io';
import 'package:bytebank/domain/entities/attachment.dart';

abstract class AttachmentRepository {
  Future<Attachment> uploadSingle({
    required String userId,
    required String transactionId,
    required File file,
  });

  Future<void> deleteAttachment({
    required String userId,
    required String transactionId,
    required Attachment attachment,
  });

  Stream<List<Attachment>> watchAttachments({
    required String userId,
    required String transactionId,
  });
}
