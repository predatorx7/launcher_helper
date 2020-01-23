import 'dart:math' as math;

/// This can be used to denote a pixel of single color value.
class Pixel {
  /// A 32 bit value representing this color.
  ///
  /// The bits are assigned as follows:
  ///
  /// * Bits 24-31 are the alpha value.
  /// * Bits 16-23 are the red value.
  /// * Bits 8-15 are the green value.
  /// * Bits 0-7 are the blue value.
  final int value;

  Pixel(int value) : value = value & 0xFFFFFFFF;

  /// The alpha channel of this color in an 8 bit value.
  int get alpha => (0xFF000000 & value) >> 24;

  /// The red channel of this color in an 8 bit value.
  int get red => (0x00FF0000 & value) >> 16;

  /// The blue channel of this color in an 8 bit value.
  int get blue => (0x0000FF00 & value) >> 8;

  /// The green channel of this color in an 8 bit value.
  int get green => (0x000000FF & value) >> 0;

  // See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
  double _linearizeColorComponent(double component) {
    if (component <= 0.03928) return component / 12.92;
    return math.pow((component + 0.055) / 1.055, 2.4);
  }

  /// Returns a brightness value between 0 for darkest and 1 for lightest.
  ///
  /// Represents the relative luminance of the color. This value is computationally
  /// expensive to calculate.
  ///
  /// See <https://en.wikipedia.org/wiki/Relative_luminance>.
  double computeLuminance() {
    // See <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
    final double R = _linearizeColorComponent(red / 0xFF);
    final double G = _linearizeColorComponent(green / 0xFF);
    final double B = _linearizeColorComponent(blue / 0xFF);
    return 0.2126 * R + 0.7152 * G + 0.0722 * B;
  }
}
