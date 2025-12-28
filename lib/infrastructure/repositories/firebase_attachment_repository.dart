import 'dart:io';
import 'package:bytebank/domain/repositories/attachment_repository.dart';
import 'package:bytebank/domain/entities/attachment.dart';
import 'package:bytebank/infrastructure/data_sources/remote/firebase_transaction_attachment_data_source.dart';

class FirebaseAttachmentRepository implements AttachmentRepository {
  final FirebaseTransactionAttachmentDataSource dataSource;

  FirebaseAttachmentRepository(this.dataSource);

  @override
  Future<Attachment> uploadSingle({
    required String userId,
    required String transactionId,
    required File file,
  }) async {
    final attachment = await dataSource.uploadSingle(
      userId: userId,
      transactionId: transactionId,
      file: file,
    );
    // data source already returns model; if it returned DTO we'd map here.
    return attachment;
  }

  @override
  Future<void> deleteAttachment({
    required String userId,
    required String transactionId,
    required Attachment attachment,
  }) async {
    return dataSource.deleteAttachment(
      userId: userId,
      transactionId: transactionId,
      attachment: attachment,
    );
  }

  @override
  Stream<List<Attachment>> watchAttachments({
    required String userId,
    required String transactionId,
  }) {
    return dataSource.watchAttachments(
      userId: userId,
      transactionId: transactionId,
    );
  }
}
