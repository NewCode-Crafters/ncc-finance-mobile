import 'package:bytebank/domain/repositories/attachment_repository.dart';
import 'package:bytebank/domain/entities/attachment.dart';

class DeleteAttachmentUseCase {
  final AttachmentRepository repository;

  DeleteAttachmentUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String transactionId,
    required Attachment attachment,
  }) {
    return repository.deleteAttachment(
      userId: userId,
      transactionId: transactionId,
      attachment: attachment,
    );
  }
}
