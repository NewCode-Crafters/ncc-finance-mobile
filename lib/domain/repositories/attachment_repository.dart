import 'dart:io';
import 'package:bytebank/features/transactions/models/attachment.dart';

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
