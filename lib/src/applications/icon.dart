import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../_strings.dart';
import 'icon_shape.dart';
import 'icon_layer.dart';

/// An AppIcon is stateless widget that shows an icon which represents a package.
///
/// AppIcons usually have atleast 1 layer. Though you can provide more depending upon your implementation.
///
/// Extending classes are expected to override [widget] to return their representation of icon as
/// a [Widget] because this uses [widget] in it's [build] method.
///
/// Use [AppIconShape] to change size of AppIcon in descendant widgets.
/// [foreground] must be the upper most layer of an icon.
abstract class AppIcon extends StatelessWidget {
  /// Returns a Layer in [RegularIcon] or a Stack widget
  /// with [foreground] & [background] [IconLayer]s in [AdaptableIcon]s.
  ///
  /// To get [IconLayer]s separately, consider using [foreground] in [RegularIcon] & [foreground] + [background]
  /// in [AdaptableIcon].
  ///
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

  /// The uppermost layer of an icon.
  IconLayer get foreground;

  /// Creates an AppIcon.
  /// launcher_helper library uses this method to create [RegularIcon] or [AdaptableIcon].
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

  /// AppIcon makes uses [widget] in [build] to represent the icon's user interface.
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

/// A single layered legacy android icon
///
/// Use [AppIconShape] to change size of AppIcon in descendant widgets.
class RegularIcon extends AppIcon {
  final Widget _icon;

  /// Creates a [RegularIcon] which has only 1 [IconLayer]
  RegularIcon(IconLayer icon,
      {double radius, double minRadius, double maxRadius})
      : this._icon = icon;

  @override
  IconLayer get widget => _icon;
  @override
  IconLayer get foreground => _icon;
}

/// An adaptive icon which can change visual properties based upon gesture
/// or [AppIconShape].
///
/// Use [AppIconShape] to change shape & size of AppIcon in descendant widgets.
class AdaptableIcon extends AppIcon {
  final Widget _stack;
  final IconLayer _foreground;
  final IconLayer _background;

  /// The foregroud layer of this AppIcon.
  @override
  IconLayer get foreground => _foreground;

  /// The background layer of this AppIcon.
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
