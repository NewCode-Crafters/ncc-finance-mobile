import 'package:flutter/material.dart';

class ColorHelper {
  static Color getColorFromString(String str) {
    // A simple hash function to generate a color.
    int hash = 0;
    for (int i = 0; i < str.length; i++) {
      hash = str.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final finalHash = hash % 0xFFFFFF; // Ensure it's a valid 24-bit color
    final baseColor = Color(0xFF000000 | finalHash);

    final hsl = HSLColor.fromColor(baseColor);
    final clampedHsl = hsl
        .withLightness(hsl.lightness.clamp(0.2, 0.6))
        .withSaturation(hsl.saturation.clamp(0.5, 1.0));

    return clampedHsl.toColor().withAlpha(255);
  }
}

/// Use `someColor.withOpacitySafe(0.6)` instead of `withOpacity`.
extension ColorOpacityExtension on Color {
  Color withOpacitySafe(double opacity) {
    final clamped = opacity.clamp(0.0, 1.0);
    return withAlpha((clamped * 255).round());
  }
}

Color colorWithOpacity(Color color, double opacity) =>
    color.withOpacitySafe(opacity);
