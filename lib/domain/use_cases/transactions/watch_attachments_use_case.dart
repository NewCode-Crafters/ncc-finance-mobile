import 'package:bytebank/domain/repositories/attachment_repository.dart';
import 'package:bytebank/domain/entities/attachment.dart';

class WatchAttachmentsUseCase {
  final AttachmentRepository repository;

  WatchAttachmentsUseCase(this.repository);

  Stream<List<Attachment>> call({
    required String userId,
    required String transactionId,
  }) {
    return repository.watchAttachments(
      userId: userId,
      transactionId: transactionId,
    );
  }
}
