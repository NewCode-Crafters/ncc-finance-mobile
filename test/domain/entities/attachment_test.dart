import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/domain/entities/attachment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('Attachment toMap and fromMap roundtrip', () {
    final now = DateTime.now();
    final a = Attachment(
      id: 'a1',
      name: 'file.png',
      contentType: 'image/png',
      size: 1234,
      storagePath: '/files/a1',
      downloadUrl: 'https://example.com/a1',
      createdAt: now,
    );

    final map = a.toMap();
    expect(map['name'], equals('file.png'));
    expect(map['contentType'], equals('image/png'));
    expect(map['size'], equals(1234));
    expect(map['storagePath'], equals('/files/a1'));
    expect(map['downloadUrl'], equals('https://example.com/a1'));
    expect(map['createdAt'], isA<Timestamp>());

    final recreated = Attachment.fromMap('a1', {
      'name': 'file.png',
      'contentType': 'image/png',
      'size': 1234,
      'storagePath': '/files/a1',
      'downloadUrl': 'https://example.com/a1',
      'createdAt': Timestamp.fromDate(now),
    });

    expect(recreated.id, equals('a1'));
    expect(recreated.name, equals('file.png'));
    expect(
      recreated.createdAt.millisecondsSinceEpoch,
      equals(now.millisecondsSinceEpoch),
    );
  });
}
