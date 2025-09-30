import 'dart:io';
import 'package:flutter/foundation.dart';

class TransactionAttachmentsNotifier extends ChangeNotifier {
  final List<File> _selected = [];
  List<File> get selected => List.unmodifiable(_selected);

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

  void clear() {
    _selected.clear();
    notifyListeners();
  }
}
