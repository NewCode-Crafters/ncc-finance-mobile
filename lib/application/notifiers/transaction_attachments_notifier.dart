import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:bytebank/domain/entities/attachment.dart';
import 'package:bytebank/domain/use_cases/transactions/delete_attachment_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/upload_attachment_use_case.dart';
import 'package:bytebank/domain/use_cases/transactions/watch_attachments_use_case.dart';

class TransactionAttachmentsNotifier extends ChangeNotifier {
  final UploadAttachmentUseCase _uploadUseCase;
  final DeleteAttachmentUseCase _deleteUseCase;
  final WatchAttachmentsUseCase _watchUseCase;

  TransactionAttachmentsNotifier({
    required UploadAttachmentUseCase uploadUseCase,
    required DeleteAttachmentUseCase deleteUseCase,
    required WatchAttachmentsUseCase watchUseCase,
  }) : _uploadUseCase = uploadUseCase,
       _deleteUseCase = deleteUseCase,
       _watchUseCase = watchUseCase;

  final List<File> _selected = [];
  List<File> get selected => List.unmodifiable(_selected);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Stream<List<Attachment>>? _attachmentsStream;

  void addLocal(File file) {
    _selected.add(file);
    notifyListeners();
  }

  void removeLocalAt(int index) {
    if (index >= 0 && index < _selected.length) {
      _selected.removeAt(index);
      notifyListeners();
    }
  }

  void clearLocal() {
    _selected.clear();
    notifyListeners();
  }

  /// Start watching attachments for a transaction and expose the stream.
  void startWatching({required String userId, required String transactionId}) {
    _attachmentsStream = _watchUseCase.call(
      userId: userId,
      transactionId: transactionId,
    );
    notifyListeners();
  }

  Stream<List<Attachment>>? get attachmentsStream => _attachmentsStream;

  Future<Attachment?> uploadLocal({
    required File file,
    required String userId,
    required String transactionId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _uploadUseCase.call(
        file: file,
        userId: userId,
        transactionId: transactionId,
      );
      return result;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Attachment>> commitAll({
    required String userId,
    required String transactionId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final List<Attachment> uploaded = [];
    try {
      for (final f in List<File>.from(_selected)) {
        final r = await _uploadUseCase.call(
          file: f,
          userId: userId,
          transactionId: transactionId,
        );
        uploaded.add(r);
      }
      clearLocal();
      return uploaded;
    } catch (e) {
      _error = e.toString();
      return uploaded;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAttachment({
    required String userId,
    required Attachment attachment,
    required String transactionId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _deleteUseCase.call(
        userId: userId,
        transactionId: transactionId,
        attachment: attachment,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
