import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../launcher_helper.dart';

class IconLayer extends StatelessWidget {
  final Widget layer;
  final Uint8List bytes;

  /// A Transparent layer
  IconLayer._transparent(this.bytes) : layer = SizedBox();

  /// Layer with only 1 color
  IconLayer._mono(Color color, this.bytes)
      : layer = Container(
          color: color,
        );

  /// Layer which is an Image
  IconLayer._image(Image memoryImage, this.bytes) : layer = memoryImage;

  /// Creates a background layer widget
  static Future<IconLayer> background(Uint8List bytes) async {
    var palette = await PaletteUtils.fromUint8List(bytes);
    var colors = palette?.colors;
    if ((colors?.length ?? 0) > 1) {
      return IconLayer._image(
          Image.memory(
            bytes,
            fit: BoxFit.fitWidth,
          ),
          bytes);
    } else if (colors != null) {
      if (colors.isEmpty) {
        int brightness = await LauncherHelper.calculateBrightness(bytes);
        if (brightness == 0) {
          return IconLayer._mono(Colors.black, bytes);
        }
        return IconLayer._mono(Colors.white, bytes);
      }
      // Inflate Layer with 1 color if only 1 color in bytes is present
      return IconLayer._mono(colors.first, bytes);
    } else {
      return IconLayer._mono(Colors.black, bytes);
    }
  }

  /// Creates a foreground layer widget
  static IconLayer foreground(Uint8List bytes) {
    return IconLayer._image(
        Image.memory(
          bytes,
          fit: BoxFit.fitWidth,
        ),
        bytes);
  }

  @override
  Widget build(BuildContext context) {
    return layer;
  }
}

abstract class AppIcon extends StatelessWidget {
  AppIcon({this.radius, this.minRadius, this.maxRadius});

  /// Returns a Layer in [RegularIcon]
  /// Returns a Stack widget with [foreground] & [background] [IconLayer]s in [AdaptableIcon]s.
  /// To get [IconLayer]s separately, consider using [foreground] in [RegularIcon] & [foreground] + [background]
  /// in [AdaptableIcon].
  /// for example:
  /// ```dart
  /// if(icon is RegularIcon)
  ///   icon.foreground
  /// else {
  ///   (icon as AdaptableIcon).foreground
  ///   (icon as AdaptableIcon).background
  /// }
  /// ```
  Widget get icon;

  IconLayer get foreground;

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

  static Future<AppIcon> getIcon(
    Map iconMap,
  ) async {
    final Uint8List iconData = iconMap['iconData'];
    if (iconData == null) {
      final Uint8List iconForegroundData = iconMap['iconForegroundData'];
      final Uint8List iconBackgroundData = iconMap['iconBackgroundData'];
      IconLayer foregroundLayer = IconLayer.foreground(iconForegroundData);
      IconLayer backgroundLayer = await IconLayer.background(iconBackgroundData);
      return AdaptableIcon(
        foregroundLayer,
        backgroundLayer,
      );
    } else {
      IconLayer iconLayer = IconLayer.foreground(iconData);
      return RegularIcon(iconLayer);
    }
  }
}

class RegularIcon extends AppIcon {
  final Widget _icon;

  RegularIcon(IconLayer icon, {double radius, double minRadius, double maxRadius})
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
  IconLayer get icon => _icon;
  @override
  IconLayer get foreground => _icon;
}

class AdaptableIcon extends AppIcon {
  final Widget _stack;
  final IconLayer _foreground;
  IconLayer get foreground => _foreground;
  final IconLayer _background;
  IconLayer get background => _background;
  AdaptableIcon(IconLayer foreground, IconLayer background,
      {double radius, double minRadius, double maxRadius})
      : this._foreground = foreground,
        this._background = background,
        _stack = Stack(
          alignment: Alignment.center,
          children: <IconLayer>[
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
