import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../launcher_helper.dart';
import '_icon_shape.dart';

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

  IconLayer._(
      {@required this.layer,
      @required this.bytes,
      @required this.color,
      @required this.adaptable});

  /// Creates a background layer widget
  static Future<IconLayer> background(Uint8List bytes) async {
    var palette = await PaletteUtils.fromUint8List(bytes);
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

  @override
  Widget build(BuildContext context) {
    final _borderRadius =
        AppIconShape.of(context).borderRadius ?? BorderRadius.circular(0);
    if (!adaptable) return layer;
    BoxDecoration decoration = BoxDecoration(
      borderRadius: _borderRadius,
    );
    double scale = AppIconShape.of(context).scale ?? defaultIconScale;
    if (layer is Image) {
      decoration = decoration.copyWith(
        image: DecorationImage(
          // Not scaling image as we need to add icon effects in future
          image: MemoryImage(
            bytes,
          ),
          fit: BoxFit.cover,
        ),
      );
    } else {
      decoration = decoration.copyWith(
        color: this.color,
      );
    }
    Widget child = Container(
      decoration: decoration,
    );
    if (!(layer is Image)) {
      // Layer doesn't need scaling & clipping
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

abstract class AppIcon extends StatelessWidget {
  /// Returns a Layer in [RegularIcon]
  /// or a Stack widget with [foreground] & [background] [IconLayer]s in [AdaptableIcon]s.
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
  Widget get widget;

  IconLayer get foreground;

  static Future<AppIcon> getIcon(
    Map iconMap,
  ) async {
    final Uint8List iconData = iconMap['iconData'];
    if (iconData == null) {
      final Uint8List iconForegroundData = iconMap['iconForegroundData'];
      final Uint8List iconBackgroundData = iconMap['iconBackgroundData'];
      IconLayer foregroundLayer =
          IconLayer.foreground(iconForegroundData, true);
      IconLayer backgroundLayer =
          await IconLayer.background(iconBackgroundData);
      return AdaptableIcon(
        foregroundLayer,
        backgroundLayer,
      );
    } else {
      IconLayer iconLayer = IconLayer.foreground(iconData, false);
      return RegularIcon(iconLayer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double radius = AppIconShape.of(context).radius ?? defaultIconRadius;
    return ConstrainedBox(
      constraints: BoxConstraints.tight(Size.fromRadius(radius)),
      child: widget,
    );
  }
}

class RegularIcon extends AppIcon {
  final Widget _icon;

  RegularIcon(IconLayer icon,
      {double radius, double minRadius, double maxRadius})
      : this._icon = icon;

  @override
  IconLayer get widget => _icon;
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
        );

  @override
  Widget get widget => _stack;
}
