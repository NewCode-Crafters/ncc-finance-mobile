import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/domain/use_cases/transactions/upload_attachment_use_case.dart';
import 'package:bytebank/domain/entities/attachment.dart';
import 'package:bytebank/domain/repositories/attachment_repository.dart';

class _FakeRepository implements AttachmentRepository {
  late String receivedUserId;
  late String receivedTransactionId;
  late File receivedFile;
  final Attachment toReturn;

  _FakeRepository(this.toReturn);

  @override
  Future<Attachment> uploadSingle({
    required String userId,
    required String transactionId,
    required File file,
  }) async {
    receivedUserId = userId;
    receivedTransactionId = transactionId;
    receivedFile = file;
    return toReturn;
  }

  @override
  Future<void> deleteAttachment({
    required String userId,
    required String transactionId,
    required Attachment attachment,
  }) async {}

  @override
  Stream<List<Attachment>> watchAttachments({
    required String userId,
    required String transactionId,
  }) => const Stream.empty();
}

void main() {
  test(
    'UploadAttachmentUseCase forwards to repository and returns attachment',
    () async {
      final fakeAttachment = Attachment(
        id: 'a1',
        name: 'file.png',
        contentType: 'image/png',
        size: 1024,
        storagePath: 'path',
        downloadUrl: 'http://',
        createdAt: DateTime.now(),
      );

      final fakeRepo = _FakeRepository(fakeAttachment);
      final useCase = UploadAttachmentUseCase(fakeRepo);

      final file = File('test_resources/dummy.png');

      final result = await useCase.call(
        userId: 'u1',
        transactionId: 't1',
        file: file,
      );

      expect(result, equals(fakeAttachment));
      expect(fakeRepo.receivedUserId, 'u1');
      expect(fakeRepo.receivedTransactionId, 't1');
      expect(fakeRepo.receivedFile.path, file.path);
    },
  );
}
