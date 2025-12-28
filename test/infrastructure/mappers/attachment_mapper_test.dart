import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/infrastructure/mappers/attachment_mapper.dart';
import 'package:bytebank/domain/entities/attachment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  test('Attachment mapper toDto and fromDto', () {
    final now = DateTime.now();
    final model = Attachment(
      id: 'a1',
      name: 'f.png',
      contentType: 'image/png',
      size: 100,
      storagePath: '/p',
      downloadUrl: 'u',
      createdAt: now,
    );

    final dto = AttachmentMapper.toDto(model);
    expect(dto.id, equals('a1'));
    expect(dto.createdAt, isA<Timestamp>());

    final mapped = AttachmentMapper.fromDto(dto);
    expect(mapped.id, equals(model.id));
    expect(
      mapped.createdAt.millisecondsSinceEpoch,
      equals(model.createdAt.millisecondsSinceEpoch),
    );
  });
}
