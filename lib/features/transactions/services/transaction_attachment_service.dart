import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/attachment.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

class TransactionAttachmentService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const _maxBytes = 10 * 1024 * 1024; // 10MB

  TransactionAttachmentService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  void validateFile({required File file, required String? contentType}) {
    final length = file.lengthSync();
    if (length > _maxBytes) {
      throw Exception('Arquivo excede 10MB.');
    }
    final allowed = RegExp(r'^(image/.*|application/pdf)$');
    if (contentType == null || !allowed.hasMatch(contentType)) {
      throw Exception('Tipo de arquivo não suportado. Use imagem ou PDF.');
    }
  }

  String storagePath({
    required String userId,
    required String transactionId,
    required String fileId,
    required String fileName,
  }) {
    final safeName = fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
    // store attachments grouped by user and transaction for easier management
    return 'users/$userId/transactions/$transactionId/attachments/$fileId-$safeName';
  }

  Future<Attachment> uploadSingle({
    required String userId,
    required String transactionId,
    required File file,
  }) async {
    final fileName = p.basename(file.path);
    final contentType = lookupMimeType(file.path);
    validateFile(file: file, contentType: contentType);

    final fileId = _firestore.collection('~').doc().id;
    final path = storagePath(
      userId: userId,
      transactionId: transactionId,
      fileId: fileId,
      fileName: fileName,
    );

    final ref = _storage.ref().child(path);

    try {
      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: contentType),
      );
      final url = await task.ref.getDownloadURL();

      final attachment = Attachment(
        id: fileId,
        name: fileName,
        contentType: contentType ?? 'application/octet-stream',
        size: file.lengthSync(),
        storagePath: path,
        downloadUrl: url,
        createdAt: DateTime.now(),
      );

      // Firestore references
      final attachmentsCol = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .collection('attachments');

      final attachmentDocRef = attachmentsCol.doc(fileId);
      final parentTransactionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId);

      // Lightweight summary stored in the parent transaction document's attachments array
      final attachmentSummary = {
        'id': attachment.id,
        'name': attachment.name,
        'downloadUrl': attachment.downloadUrl,
        'size': attachment.size,
        'contentType': attachment.contentType,
        'storagePath': attachment.storagePath,
        'createdAt': Timestamp.fromDate(attachment.createdAt),
      };

      // Use a batch so both the subcollection doc and the parent's attachments array are updated atomically
      final batch = _firestore.batch();
      batch.set(attachmentDocRef, attachment.toMap());
      batch.set(parentTransactionRef, {
        'attachments': FieldValue.arrayUnion([attachmentSummary]),
      }, SetOptions(merge: true));

      await batch.commit();

      return attachment;
    } catch (e) {
      try {
        await ref.delete();
      } catch (_) {}
      rethrow;
    }
  }

  Future<void> deleteAttachment({
    required String userId,
    required String transactionId,
    required Attachment attachment,
  }) async {
    final attachmentDocRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .collection('attachments')
        .doc(attachment.id);

    final parentTransactionRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId);

    final attachmentSummary = {
      'id': attachment.id,
      'name': attachment.name,
      'downloadUrl': attachment.downloadUrl,
      'size': attachment.size,
      'contentType': attachment.contentType,
      'storagePath': attachment.storagePath,
      'createdAt': Timestamp.fromDate(attachment.createdAt),
    };

    final batch = _firestore.batch();
    batch.delete(attachmentDocRef);
    batch.update(parentTransactionRef, {
      'attachments': FieldValue.arrayRemove([attachmentSummary]),
    });
    await batch.commit();

    await _storage.ref().child(attachment.storagePath).delete();
  }

  Stream<List<Attachment>> watchAttachments({
    required String userId,
    required String transactionId,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .collection('attachments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Attachment.fromMap(d.id, d.data())).toList(),
        );
  }
}
