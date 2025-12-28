import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/domain/entities/image_source_type.dart';

void main() {
  test('ImageSourceType enum values', () {
    expect(ImageSourceType.values.contains(ImageSourceType.camera), isTrue);
    expect(ImageSourceType.values.contains(ImageSourceType.gallery), isTrue);
  });
}
