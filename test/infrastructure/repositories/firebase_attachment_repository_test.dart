import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/infrastructure/repositories/firebase_attachment_repository.dart';
import 'package:bytebank/infrastructure/data_sources/remote/firebase_transaction_attachment_data_source.dart';
import 'package:bytebank/features/transactions/models/attachment.dart';

class _FakeDataSource extends FirebaseTransactionAttachmentDataSource {
  late String receivedUserId;
  late String receivedTransactionId;
  late File receivedFile;
  final Attachment toReturn;

  _FakeDataSource(this.toReturn) : super(firestore: null, storage: null);

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
    'FirebaseAttachmentRepository forwards uploadSingle to data source',
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

      final ds = _FakeDataSource(fakeAttachment);
      final repo = FirebaseAttachmentRepository(ds);

      final file = File('test_resources/dummy.png');
      final result = await repo.uploadSingle(
        userId: 'u1',
        transactionId: 't1',
        file: file,
      );

      expect(result, equals(fakeAttachment));
      expect(ds.receivedUserId, 'u1');
      expect(ds.receivedTransactionId, 't1');
      expect(ds.receivedFile.path, file.path);
    },
  );
}
