// Copyright 2019 Mushaheed Syed. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:launcher_helper/launcher_helper.dart';
import 'palette_generator.dart';

/// This [ApplicationCollection] is a List of [Application] (which has application information).
/// It needs a list with map of applications obtained from platform operations to create [Application].
///
/// This is not a dart:collection object but provides a list of [Application] object.
class ApplicationCollection {
  /// List with [Application]s containing information for apps
  List<Application> _apps;

  /// This [ApplicationCollection] constructor generates a List of [Application] (which has application information).
  ApplicationCollection(List appList) {
    this._apps = [];
    for (var appData in appList) {
      Application appInfo = Application(
        label: appData["label"],
        packageName: appData["packageName"],
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

/// This [Application] class is a model to contain Application information obtained from [ApplicationCollection]'s list or some other method.
///
/// This represents a package label as [label], package name as [packageName] and
/// icon [iconData] as a [Uint8List].
///
/// Flutter Image widget can be obtained from [getIconAsImage].
/// Color palette for icon can be obtained through [getIconPalette].
class Application {
  /// Application label
  String label;

  /// Application package name
  String packageName;

  /// Application icon
  Uint8List iconData;

  var _versionName;

  /// Application version name
  get versionName => _versionName;

  var _versionCode;

  /// Application version code
  get versionCode => _versionCode;

  /// Creates [Application] with
  Application({String label, String packageName, Uint8List iconData})
      : this.label = label,
        this.packageName = packageName,
        this.iconData = iconData;

  /// Creates [Application] from map
  Application.fromMap(appData)
      : this.label = appData["label"] ?? '',
        this.packageName = appData["packageName"] ?? '',
        this.iconData = appData["icon"] ?? '',
        this._versionCode = appData["versionCode"] ?? '',
        this._versionName = appData["versionName"] ?? '';

  /// Creates a flutter Image widget from obtained iconData [Uint8List]
  Image getIconAsImage() {
    return Image.memory(this.iconData);
  }

  /// Returns palette of colors generated from this [Application]'s [iconData] for use in UI.
  Future<PaletteGenerator> getIconPalette() async {
    return await PaletteGenerator.fromUint8List(this.iconData);
  }

  /// Use this method to update [versionCode] and [versionName] for this [Application] (initially versionName & versionCode would be blank).
  /// It updates [Application] information using [Launcher.getApplicationInfo].
  Future updateInfo() async {
    Application appInfo =
        await LauncherHelper.getApplicationInfo(this.packageName);
    this.iconData = appInfo.iconData;
    this.label = appInfo.label;
    this.packageName = appInfo.packageName;
    this._versionCode = appInfo.versionCode;
    this._versionName = appInfo.versionName;
  }
}
