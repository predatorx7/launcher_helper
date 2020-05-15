import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:launcher_helper/src/_strings.dart';

import '../launcher_helper.dart';
export 'icon_shape.dart';
export 'icon_layer.dart';

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
    final Uint8List iconData = iconMap[Strings.iconData];
    if (iconData == null) {
      final Uint8List iconForegroundData = iconMap[Strings.iconForegroundData];
      final Uint8List iconBackgroundData = iconMap[Strings.iconBackgroundData];
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
    return AnimatedContainer(
      curve: Curves.fastOutSlowIn,
      duration: kThemeChangeDuration,
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
