// Copyright 2019 Mushaheed Syed. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/widgets.dart'
    show
        AsyncSnapshot,
        BoxDecoration,
        BuildContext,
        FutureBuilder,
        SizedBox,
        Widget;
import 'package:launcher_helper/launcher_helper.dart';
import '_icon.dart';
import 'palette_generator.dart';

/// This [ApplicationCollection] is a List of [Application] (which has application information).
///
/// This is not a dart:collection object. It provides a list of [Application] object.
class ApplicationCollection {
  /// List with [Application]s containing information for apps
  List<Application> _apps;

  /// This [ApplicationCollection] constructor generates a List of [Application] (which has application information) from List<Map> of Apps from MethodChannel.
  ApplicationCollection.fromList(List appList) {
    this._apps = [];
    for (var appData in appList) {
      Application appInfo = Application.fromMap(appData);
      this._apps.add(appInfo);
    }
  }

  /// Number of apps in list.
  /// This property is the same as [totalApps].
  int get length => this.totalApps;

  /// Number of [Application] in this [ApplicationCollection].
  int get totalApps => _apps.length;

  /// Returns [Application] at index `i`.
  Application operator [](int i) => _apps[i];

  /// Creates a [List] containing the [Application] elements of this [ApplicationCollection] instance.
  ///
  /// The elements are in iteration order.
  /// The list is fixed-length if [growable] is false.
  List<Application> toList({growable = false}) =>
      List<Application>.from(this._apps, growable: growable);
}

/// This [Application] class is a model to contain Application information.
///
/// This represents a package label as [label], package name as [packageName] and
/// icon [_iconDataMap] as a [Uint8List].
///
/// Flutter Image widget can be obtained from [getIconAsImage].
/// Color palette for icon can be obtained through [getIconPalette].
///
/// Package updates may change their versionName or versionCode. Thus, initially [versionName] & [versionCode] is kept empty when retrieved from [LauncherHelper.getApplications].
/// Use [update] before using these.
class Application {
  /// Application label
  String label;

  /// Application package name
  String packageName;

  /// Application icon
  Map<dynamic, dynamic> _iconDataMap;

  var _versionName;

  /// Application version name
  get versionName => _versionName;

  var _versionCode;

  /// Application version code
  get versionCode => _versionCode;

  /// Creates [Application] with
  Application({String label, String packageName, Map<dynamic, dynamic> icon})
      : this.label = label,
        this.packageName = packageName,
        this._iconDataMap = icon;

  /// Creates [Application] from map
  Application.fromMap(appData)
      : this.label = appData["label"] ?? '',
        this.packageName = appData["packageName"] ?? '',
        this._iconDataMap = appData["icon"],
        this._versionCode = appData["versionCode"] ?? '',
        this._versionName = appData["versionName"] ?? '';

  bool get isAdaptableIcon {
    if (this._iconDataMap['iconBackgroundData'] == null) {
      return false;
    }
    return true;
  }

  final String _iconDat = 'iconData';
  final String _iconFg = 'iconForegroundData';
  final String _iconBg = 'iconBackgroundData';

  Uint8List get iconForeground =>
      this._iconDataMap[_iconFg] ?? this._iconDataMap[_iconDat];
  Uint8List get iconBackground => this._iconDataMap[_iconBg];

  /// Creates a flutter Image widget from obtained iconData [Uint8List]
  FutureBuilder<AppIcon> getAppIcon() {
    return FutureBuilder(
      future: AppIcon.getIcon(_iconDataMap),
      builder: (BuildContext context, AsyncSnapshot<AppIcon> asyncFuture) {
        if (asyncFuture.hasData) {
          return asyncFuture.data;
        }
        return SizedBox();
      },
    );
  }

  Future<AppIcon> getAppIconAsync({BoxDecoration decoration}) async {
    return AppIcon.getIcon(_iconDataMap);
  }

  /// Returns palette of colors generated from this [Application]'s [_iconDataMap] for use in UI.
  Future<PaletteGenerator> getIconPalette() async {
    return await PaletteUtils.fromUint8List(this.iconForeground);
  }

  /// It updates [Application] information using [Launcher.getApplicationInfo].
  Future update() async {
    Application appInfo =
        await LauncherHelper.getApplicationInfo(this.packageName);
    this._iconDataMap = appInfo._iconDataMap;
    this.label = appInfo.label;
    this.packageName = appInfo.packageName;
    this._versionCode = appInfo.versionCode;
    this._versionName = appInfo.versionName;
  }
}
