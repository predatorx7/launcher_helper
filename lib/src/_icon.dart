import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../launcher_helper.dart';

class Layer extends StatelessWidget {
  final Widget layer;

  /// A Transparent layer
  Layer._transparent() : layer = SizedBox();

  /// Layer with only 1 color
  Layer._mono(Color color)
      : layer = Container(
          color: color,
        );

  /// Layer which is an Image
  Layer._image(Image memoryImage) : layer = memoryImage;

  /// Creates a background layer widget
  static Future<Layer> background(Uint8List bytes) async {
    var palette = await PaletteGenerator.fromUint8List(bytes);
    var colors = palette?.colors;
    if ((colors?.length ?? 0) > 1) {
      return Layer._image(Image.memory(
        bytes,
        fit: BoxFit.fitWidth,
      ));
    } else if (colors != null) {
      // Inflate Layer with 1 color if only 1 color in bytes is present
      if(colors.isEmpty){
        return Layer._transparent();
      }
      return Layer._mono(colors.first);
    } else {
      return Layer._transparent();
    }
  }

  /// Creates a foreground layer widget
  static Layer foreground(Uint8List bytes) {
    return Layer._image(Image.memory(
      bytes,
      fit: BoxFit.fitWidth,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return layer;
  }
}

abstract class Icon extends StatelessWidget {
  Icon({this.radius, this.minRadius, this.maxRadius});

  Widget get icon;

  final double radius;

  final double minRadius;

  final double maxRadius;

  // The default radius if nothing is specified.
  static const double _defaultRadius = 20.0;

  // The default min if only the max is specified.
  static const double _defaultMinRadius = 0.0;

  // The default max if only the min is specified.
  static const double _defaultMaxRadius = double.infinity;

  double get _minDiameter {
    if (radius == null && minRadius == null && maxRadius == null) {
      return _defaultRadius * 2.0;
    }
    return 2.0 * (radius ?? minRadius ?? _defaultMinRadius);
  }

  double get _maxDiameter {
    if (radius == null && minRadius == null && maxRadius == null) {
      return _defaultRadius * 2.0;
    }
    return 2.0 * (radius ?? maxRadius ?? _defaultMaxRadius);
  }

  static Future<Icon> getIcon(Map iconMap) async {
    final Uint8List iconData = iconMap['iconData'];
    if (iconData == null) {
      final Uint8List iconForegroundData = iconMap['iconForegroundData'];
      final Uint8List iconBackgroundData = iconMap['iconBackgroundData'];
      Layer foregroundLayer = Layer.foreground(iconForegroundData);
      Layer backgroundLayer = await Layer.background(iconBackgroundData);
      return AdaptableIcon(foregroundLayer, backgroundLayer);
    } else {
      Layer iconLayer = Layer.foreground(iconData);
      return RegularIcon(iconLayer);
    }
  }
}

class RegularIcon extends Icon {
  final Widget _icon;
  RegularIcon(Layer icon, {double radius, double minRadius, double maxRadius})
      : this._icon = icon,
        super(radius: radius, minRadius: minRadius, maxRadius: maxRadius);

  @override
  Widget build(BuildContext context) {
    final double minDiameter = _minDiameter;
    final double maxDiameter = _maxDiameter;
    return AnimatedContainer(
      constraints: BoxConstraints(
        minHeight: minDiameter,
        minWidth: minDiameter,
        maxWidth: maxDiameter,
        maxHeight: maxDiameter,
      ),
      duration: kThemeChangeDuration,
      child: icon,
    );
  }

  @override
  Widget get icon => _icon;
}

class AdaptableIcon extends Icon {
  final Widget _stack;
  final Layer foreground;
  final Layer background;
  AdaptableIcon(Layer foreground, Layer background,
      {double radius, double minRadius, double maxRadius})
      : this.foreground = foreground,
        this.background = background,
        _stack = Stack(
          alignment: Alignment.center,
          children: <Layer>[
            background,
            foreground,
          ],
        ),
        super(radius: radius, minRadius: minRadius, maxRadius: maxRadius);

  @override
  Widget build(BuildContext context) {
    final double minDiameter = _minDiameter;
    final double maxDiameter = _maxDiameter;
    return AnimatedContainer(
      constraints: BoxConstraints(
        minHeight: minDiameter,
        minWidth: minDiameter,
        maxWidth: maxDiameter,
        maxHeight: maxDiameter,
      ),
      duration: kThemeChangeDuration,
      child: icon,
    );
  }

  @override
  Widget get icon => _stack;
}
