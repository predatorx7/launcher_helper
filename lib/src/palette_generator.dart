// Copyright 2019 Mushaheed Syed. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:flutter/widgets.dart' show MemoryImage;
import 'package:palette_generator/palette_generator.dart';
export 'package:palette_generator/palette_generator.dart';

/// Additional methods for [PaletteGenerator]
extension PaletteUtils on PaletteGenerator {
  /// Creates a [PaletteGenerator] from [Uint8List] image data asynchronously.
  ///
  /// The [region] specifies the part of the image to inspect for color
  /// candidates. By default it uses the entire image. Must not be equal to
  /// [Rect.zero], and must not be larger than the image dimensions.
  ///
  /// The [maximumColorCount] sets the maximum number of colors that will be
  /// returned in the [PaletteGenerator]. The default is 16 colors.
  ///
  /// The [filters] specify a lost of [PaletteFilter] instances that can be used
  /// to include certain colors in the list of colors. The default filter is
  /// an instance of [AvoidRedBlackWhitePaletteFilter], which stays away from
  /// whites, blacks, and low-saturation reds.
  ///
  /// The [targets] are a list of target color types, specified by creating
  /// custom [PaletteTarget]s. By default, this is the list of targets in
  /// [PaletteTarget.baseTargets].
  ///
  /// The [imageData] must not be null.
  ///
  /// **Note**:
  /// - You can use `computeLuminance()` method of [dominantColor] of type `Color` obtained from
  /// generated Palette.
  static Future<PaletteGenerator> fromUint8List(
    Uint8List imageData, {
    Rect region,
    int maximumColorCount,
    List<PaletteFilter> filters,
    List<PaletteTarget> targets,
  }) async {
    assert(imageData != null);
    return await PaletteGenerator.fromImageProvider(
      MemoryImage(imageData),
    );
  }
}
