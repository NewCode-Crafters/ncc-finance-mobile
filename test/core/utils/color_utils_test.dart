import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bytebank/core/utils/color_utils.dart';

void main() {
  test('getColorFromString produces deterministic color', () {
    final a = ColorHelper.getColorFromString('Alice');
    final b = ColorHelper.getColorFromString('Alice');
    expect(a, equals(b));
  });

  test(
    'getColorFromString produces different colors for different strings',
    () {
      final a = ColorHelper.getColorFromString('Alice');
      final b = ColorHelper.getColorFromString('Bob');
      expect(a != b, isTrue);
    },
  );

  test('withOpacitySafe clamps values and keeps alpha correct', () {
    final c = Colors.red;
    final half = c.withOpacitySafe(0.5);
    final expectedHalfAlpha = (0.5.clamp(0.0, 1.0) * 255).round();
    expect(((half.toARGB32() >> 24) & 0xFF), equals(expectedHalfAlpha));

    final over = c.withOpacitySafe(2.0);
    expect(((over.toARGB32() >> 24) & 0xFF), equals(255));

    final under = c.withOpacitySafe(-1.0);
    expect(((under.toARGB32() >> 24) & 0xFF), equals(0));
  });

  test('colorWithOpacity helper delegates to withOpacitySafe', () {
    final c = Colors.blue;
    final r1 = colorWithOpacity(c, 0.2);
    final r2 = c.withOpacitySafe(0.2);
    expect(r1, equals(r2));
  });
}
