// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/material.dart';

/// A Widget icon that represents an App.
class AppIcon extends StatelessWidget {
  /// Creates a Widget icon that represents an App.
  const AppIcon._({
    Key key,
    @required this.foreground,
    this.background,
    this.radius,
    this.minRadius,
    this.maxRadius,
  })  : assert(radius == null || (minRadius == null && maxRadius == null)),
        super(key: key);

  factory AppIcon.fromMap(Map<dynamic, dynamic> iconMap) {
    final Uint8List iconForegroundData =
        iconMap['iconData'] ?? iconMap['iconForegroundData'];
    final Uint8List iconBackgroundData = iconMap['iconBackgroundData'] ?? null;
    if (iconBackgroundData != null) {
      return AppIcon._(
        foreground: iconForegroundData,
        background: iconBackgroundData,
      );
    } else {
      return AppIcon._(foreground: iconForegroundData);
    }
  }

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget. If the [AppIcon] is to have an image, use
  /// [background] instead.
  final Uint8List foreground;

  /// The background image of the circle. Changing the background
  /// image will cause the avatar to animate to the new image.
  ///
  /// If the [AppIcon] is to have the user's initials, use [foreground] instead.
  final Uint8List background;

  /// The size of the avatar, expressed as the radius (half the diameter).
  ///
  /// If [radius] is specified, then neither [minRadius] nor [maxRadius] may be
  /// specified. Specifying [radius] is equivalent to specifying a [minRadius]
  /// and [maxRadius], both with the value of [radius].
  ///
  /// If neither [minRadius] nor [maxRadius] are specified, defaults to 20
  /// logical pixels. This is the appropriate size for use with
  /// [ListTile.leading].
  ///
  /// Changes to the [radius] are animated (including changing from an explicit
  /// [radius] to a [minRadius]/[maxRadius] pair or vice versa).
  final double radius;

  /// The minimum size of the avatar, expressed as the radius (half the
  /// diameter).
  ///
  /// If [minRadius] is specified, then [radius] must not also be specified.
  ///
  /// Defaults to zero.
  ///
  /// Constraint changes are animated, but size changes due to the environment
  /// itself changing are not. For example, changing the [minRadius] from 10 to
  /// 20 when the [AppIcon] is in an unconstrained environment will cause
  /// the avatar to animate from a 20 pixel diameter to a 40 pixel diameter.
  /// However, if the [minRadius] is 40 and the [AppIcon] has a parent
  /// [SizedBox] whose size changes instantaneously from 20 pixels to 40 pixels,
  /// the size will snap to 40 pixels instantly.
  final double minRadius;

  /// The maximum size of the avatar, expressed as the radius (half the
  /// diameter).
  ///
  /// If [maxRadius] is specified, then [radius] must not also be specified.
  ///
  /// Defaults to [double.infinity].
  ///
  /// Constraint changes are animated, but size changes due to the environment
  /// itself changing are not. For example, changing the [maxRadius] from 10 to
  /// 20 when the [AppIcon] is in an unconstrained environment will cause
  /// the avatar to animate from a 20 pixel diameter to a 40 pixel diameter.
  /// However, if the [maxRadius] is 40 and the [AppIcon] has a parent
  /// [SizedBox] whose size changes instantaneously from 20 pixels to 40 pixels,
  /// the size will snap to 40 pixels instantly.
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

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final double minDiameter = _minDiameter;
    final double maxDiameter = _maxDiameter;
    Widget child = Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Visibility(
          visible: background?.isNotEmpty ?? false,
          child: Image.memory(background),
        ),
        Image.memory(foreground),
      ],
    );
    return AnimatedContainer(
      constraints: BoxConstraints(
        minHeight: minDiameter,
        minWidth: minDiameter,
        maxWidth: maxDiameter,
        maxHeight: maxDiameter,
      ),
      duration: kThemeChangeDuration,
      child: child,
    );
    // return AnimatedContainer(
    //   constraints: BoxConstraints(
    //     minHeight: minDiameter,
    //     minWidth: minDiameter,
    //     maxWidth: maxDiameter,
    //     maxHeight: maxDiameter,
    //   ),
    //   duration: kThemeChangeDuration,
    //   decoration: BoxDecoration(
    //     color: Colors.transparent,
    //     image: background != null
    //         ? DecorationImage(image: MemoryImage(background), fit: BoxFit.cover)
    //         : null,
    //     shape: BoxShape.circle,
    //   ),
    //   child: foreground == null
    //       ? null
    //       : Center(
    //           child: MediaQuery(
    //             // Need to ignore the ambient textScaleFactor here so that the
    //             // text doesn't escape the avatar when the textScaleFactor is large.
    //             data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
    //             child: Image.memory(foreground),
    //           ),
    //         ),
    // );
  }
}
