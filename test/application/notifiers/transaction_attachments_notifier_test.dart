import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/application/notifiers/transaction_attachments_notifier.dart';
import 'package:bytebank/domain/entities/attachment.dart';
import 'package:bytebank/domain/use_cases/transactions/upload_attachment_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/delete_attachment_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/watch_attachments_use_case.dart';
import 'package:bytebank/domain/repositories/attachment_repository.dart';

class _FakeAttachmentRepo implements AttachmentRepository {
  final bool uploadThrows;
  final bool deleteThrows;
  final Stream<List<Attachment>>? watchStream;

  bool uploadCalled = false;
  bool deleteCalled = false;

  _FakeAttachmentRepo({
    this.uploadThrows = false,
    this.deleteThrows = false,
    this.watchStream,
  });

  @override
  Future<Attachment> uploadSingle({
    required String userId,
    required String transactionId,
    required File file,
  }) async {
    uploadCalled = true;
    if (uploadThrows) throw Exception('upload failed');
    return Attachment(
      id: 'a1',
      name: file.path,
      contentType: 'application/octet-stream',
      size: 0,
      storagePath: '/path',
      downloadUrl: '/download',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteAttachment({
    required String userId,
    required String transactionId,
    required Attachment attachment,
  }) async {
    deleteCalled = true;
    if (deleteThrows) throw Exception('delete failed');
  }

  @override
  Stream<List<Attachment>> watchAttachments({
    required String userId,
    required String transactionId,
  }) {
    return watchStream ?? Stream.value([]);
  }
}

void main() {
  test('local add/remove/clear updates selection', () {
    final repo = _FakeAttachmentRepo();
    final notifier = TransactionAttachmentsNotifier(
      uploadUseCase: UploadAttachmentUseCase(repo),
      deleteUseCase: DeleteAttachmentUseCase(repo),
      watchUseCase: WatchAttachmentsUseCase(repo),
    );

    final f1 = File('f1');
    final f2 = File('f2');
    notifier.addLocal(f1);
    notifier.addLocal(f2);
    expect(notifier.selected.length, 2);

    notifier.removeLocalAt(0);
    expect(notifier.selected.length, 1);

    notifier.clearLocal();
    expect(notifier.selected, isEmpty);
  });

  test('uploadLocal success sets isLoading and returns attachment', () async {
    final repo = _FakeAttachmentRepo();
    final notifier = TransactionAttachmentsNotifier(
      uploadUseCase: UploadAttachmentUseCase(repo),
      deleteUseCase: DeleteAttachmentUseCase(repo),
      watchUseCase: WatchAttachmentsUseCase(repo),
    );

    final f = File('file');
    final future = notifier.uploadLocal(
      file: f,
      userId: 'u',
      transactionId: 't',
    );
    expect(notifier.isLoading, isTrue);
    final att = await future;
    expect(att, isNotNull);
    expect(repo.uploadCalled, isTrue);
    expect(notifier.isLoading, isFalse);
    expect(notifier.error, isNull);
  });

  test('uploadLocal failure sets error and returns null', () async {
    final repo = _FakeAttachmentRepo(uploadThrows: true);
    final notifier = TransactionAttachmentsNotifier(
      uploadUseCase: UploadAttachmentUseCase(repo),
      deleteUseCase: DeleteAttachmentUseCase(repo),
      watchUseCase: WatchAttachmentsUseCase(repo),
    );

    final f = File('file');
    final att = await notifier.uploadLocal(
      file: f,
      userId: 'u',
      transactionId: 't',
    );
    expect(att, isNull);
    expect(notifier.error, isNotNull);
    expect(notifier.isLoading, isFalse);
  });

  test('commitAll uploads all selected and clears selection', () async {
    final repo = _FakeAttachmentRepo();
    final notifier = TransactionAttachmentsNotifier(
      uploadUseCase: UploadAttachmentUseCase(repo),
      deleteUseCase: DeleteAttachmentUseCase(repo),
      watchUseCase: WatchAttachmentsUseCase(repo),
    );

    final f1 = File('f1');
    final f2 = File('f2');
    notifier.addLocal(f1);
    notifier.addLocal(f2);

    final uploaded = await notifier.commitAll(userId: 'u', transactionId: 't');
    expect(uploaded.length, 2);
    expect(notifier.selected, isEmpty);
    expect(notifier.error, isNull);
  });

  test('commitAll partial failure returns uploaded and keeps error', () async {
    final repo = _FakeAttachmentRepo(uploadThrows: true);
    final notifier = TransactionAttachmentsNotifier(
      uploadUseCase: UploadAttachmentUseCase(repo),
      deleteUseCase: DeleteAttachmentUseCase(repo),
      watchUseCase: WatchAttachmentsUseCase(repo),
    );

    notifier.addLocal(File('one'));
    notifier.addLocal(File('two'));

    final uploaded = await notifier.commitAll(userId: 'u', transactionId: 't');
    // should return empty uploaded and set error
    expect(uploaded, isEmpty);
    expect(notifier.error, isNotNull);
  });

  test('startWatching sets attachmentsStream', () {
    final ctrl = StreamController<List<Attachment>>.broadcast();
    final repo = _FakeAttachmentRepo(watchStream: ctrl.stream);
    final notifier = TransactionAttachmentsNotifier(
      uploadUseCase: UploadAttachmentUseCase(repo),
      deleteUseCase: DeleteAttachmentUseCase(repo),
      watchUseCase: WatchAttachmentsUseCase(repo),
    );

    notifier.startWatching(userId: 'u', transactionId: 't');
    expect(notifier.attachmentsStream, isNotNull);
    ctrl.add([
      Attachment(
        id: '1',
        name: 'n',
        contentType: 't',
        size: 1,
        storagePath: '/p',
        downloadUrl: '/d',
        createdAt: DateTime.now(),
      ),
    ]);
    ctrl.close();
  });

  test('deleteAttachment success and failure flows', () async {
    final repoOk = _FakeAttachmentRepo();
    final notifierOk = TransactionAttachmentsNotifier(
      uploadUseCase: UploadAttachmentUseCase(repoOk),
      deleteUseCase: DeleteAttachmentUseCase(repoOk),
      watchUseCase: WatchAttachmentsUseCase(repoOk),
    );

    final att = Attachment(
      id: 'a',
      name: 'n',
      contentType: 't',
      size: 1,
      storagePath: '/p',
      downloadUrl: '/d',
      createdAt: DateTime.now(),
    );
    final ok = await notifierOk.deleteAttachment(
      userId: 'u',
      transactionId: 't',
      attachment: att,
    );
    expect(ok, isTrue);
    expect(repoOk.deleteCalled, isTrue);

    final repoFail = _FakeAttachmentRepo(deleteThrows: true);
    final notifierFail = TransactionAttachmentsNotifier(
      uploadUseCase: UploadAttachmentUseCase(repoFail),
      deleteUseCase: DeleteAttachmentUseCase(repoFail),
      watchUseCase: WatchAttachmentsUseCase(repoFail),
    );

    final failed = await notifierFail.deleteAttachment(
      userId: 'u',
      transactionId: 't',
      attachment: att,
    );
    expect(failed, isFalse);
    expect(notifierFail.error, isNotNull);
  });
}
