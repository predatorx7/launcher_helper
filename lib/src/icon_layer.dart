import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../launcher_helper.dart';

class IconLayer extends StatelessWidget {
  final Widget layer;
  final Uint8List bytes;
  final Color color;
  final bool adaptable;

  /// Layer with only 1 color
  IconLayer._colored(this.color, this.bytes, {this.adaptable = false})
      : layer = Container(
          color: color,
        );

  /// Layer which is an Image
  IconLayer._image(this.bytes, {this.adaptable = false})
      : layer = Image.memory(bytes),
        this.color = Colors.transparent;

  /// Creates a background layer widget
  static Future<IconLayer> background(Uint8List bytes) async {
    var palette = await PaletteGeneratorUtils.fromUint8List(bytes);
    var colors = palette?.colors;
    if ((colors?.length ?? 0) > 1) {
      // Image has more than 1 color
      return IconLayer._image(bytes, adaptable: true);
    } else if (colors != null) {
      if (colors.isEmpty) {
        // Background color must be white or black
        // TODO(predatorx7): Do synchronously on dart
        int brightness = await LauncherHelper.calculateBrightness(bytes);
        if (brightness == 0) {
          return IconLayer._colored(
            Colors.black,
            bytes,
            adaptable: true,
          );
        }
        return IconLayer._colored(
          Colors.white,
          bytes,
          adaptable: true,
        );
      }
      // There is 1 color in the image.
      // Creating Layer fill with 1 color as only 1 color in bytes is present
      return IconLayer._colored(
        colors.first,
        bytes,
        adaptable: true,
      );
    } else {
      // Using fallback layer color as black
      return IconLayer._colored(
        Colors.black,
        bytes,
        adaptable: true,
      );
    }
  }

  /// Creates a foreground layer widget
  static IconLayer foreground(Uint8List bytes, bool adaptable) {
    return IconLayer._image(
      bytes,
      adaptable: adaptable,
    );
  }

  /// The layer's BoxDecoration. It's used in [AdaptableIcon] to display visual effects.
  ///
  /// This [IconLayer]'s [build] method scales and clips a container which uses
  /// [BoxDecoration] built from this method.
  ///
  /// Use this in your implementation of an App Icon (or any other widget) as
  /// this is how the layer will look without scaling and clipping.
  BoxDecoration buildDecoration(BuildContext context) {
    DecorationImage decorationImage = (bytes != null)
        ? DecorationImage(
            image: MemoryImage(bytes),
          )
        : null;
    if (!adaptable) {
      return BoxDecoration(
        color: this.color,
        image: decorationImage,
      );
    }
    final _borderRadius =
        AppIconShape.of(context).borderRadius ?? BorderRadius.circular(0);
    BoxDecoration decoration = BoxDecoration(
      borderRadius: _borderRadius,
    );
    if (layer is Image) {
      decoration = decoration.copyWith(
        // Not scaling image as we need to add icon effects in future
        image: decorationImage,
      );
    } else {
      decoration = decoration.copyWith(
        color: this.color,
      );
    }
    return decoration;
  }

  @override

  /// Describes the part of the user interface represented by this widget.
  ///
  /// Applies scale transformation & clipping if needed.
  Widget build(BuildContext context) {
    if (!adaptable) return layer;
    final _borderRadius =
        AppIconShape.of(context).borderRadius ?? BorderRadius.circular(0);
    double scale = AppIconShape.of(context).scale ?? defaultIconScale;
    BoxDecoration _decoration = buildDecoration(context);
    Widget child = Container(
      decoration: _decoration,
    );
    if (!(layer is Image)) {
      // Layer is not an image, thus doesn't need scaling & clipping
      return child;
    }
    if (scale != 1.0) {
      // Scaling and clipping image
      // Image was scaled, hence needs clipping
      return ClipRRect(
        clipBehavior: AppIconShape.of(context).clipBehavior ?? Clip.hardEdge,
        borderRadius: _borderRadius,
        child: Transform.scale(
          scale: scale,
          child: child,
        ),
      );
    }
    return child;
  }
}
