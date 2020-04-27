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
    final Uint8List iconBackgroundData = iconMap['iconBackgroundData'];
    if (iconBackgroundData != null) {
      return AppIcon._(
        foreground: iconForegroundData,
        background: iconBackgroundData,
      );
    } else {
      return AppIcon._(foreground: iconForegroundData);
    }
  }

  final Uint8List foreground;

  final Uint8List background;

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

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final double minDiameter = _minDiameter;
    final double maxDiameter = _maxDiameter;
    List<Widget> iconLayerStack = [Image.memory(foreground)];
    if (background != null) iconLayerStack.insert(0, Image.memory(background));
    Widget child = Stack(
      alignment: Alignment.center,
      children: iconLayerStack,
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
