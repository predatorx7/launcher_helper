// Copyright 2019 Mushaheed Syed. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'palette_generator.dart';

/// This [ApplicationCollection] generates a List of [Application] (which has application information) for better access.
/// It needs a list with map of applications obtained from platform operations to create [Application].
///
/// This is not a dart:collection object but provides a list of [Application] object.
class ApplicationCollection {
  /// List with [Application]s containing information for apps
  List<Application> _apps;

  ApplicationCollection(List appList) {
    this._apps = [];
    for (var appData in appList) {
      Application appInfo = Application(
        label: appData["label"],
        packageName: appData["package"],
        iconData: appData["icon"],
      );
      this._apps.add(appInfo);
    }
  }

  int get length => _apps.length;

  /// Creates a [List] containing the [Application] elements of this [ApplicationCollection] instance.
  ///
  /// The elements are in iteration order.
  /// The list is fixed-length if [growable] is false.
  List<Application> toList({growable = false}) =>
      List<Application>.from(this._apps, growable: growable);
}

/// [Application] containing Application information obtained from [ApplicationCollection]'s list.
///
/// This represents a package label as [label], package name as [packageName] and
/// icon [iconData] as a [Uint8List].
///
/// Flutter Image widget can be obtained from [getIconAsImage].
/// Color palette for icon can be obtained through [getIconPalette].
class Application {
  String label;
  String packageName;
  Uint8List iconData;
  Application({String label, String packageName, Uint8List iconData})
      : this.label = label,
        this.packageName = packageName,
        this.iconData = iconData;

  /// Creates a flutter Image widget from obtained iconData [Uint8List]
  Image getIconAsImage() {
    return Image.memory(this.iconData);
  }

  /// Returns palette of colors generated from this [Application]'s [iconData].
  Future<PaletteGenerator> getIconPalette() async {
    return await PaletteGenerator.fromUint8List(this.iconData);
  }
}
