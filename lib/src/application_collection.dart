// Copyright 2019 Mushaheed Syed. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:launcher_helper/launcher_helper.dart';
import '_icon.dart';

/// This [ApplicationCollection] is a List of [Application] (which has application information).
///
/// This is not a dart:collection object. It provides a list of [Application] object.
class ApplicationCollection {
  /// List with [Application]s containing information for apps
  List<Application> _apps;

  /// This [ApplicationCollection] constructor generates a List of [Application] (which has application information) from List<Map> of Apps from MethodChannel.
  ApplicationCollection.fromApplications(List<Application> appList)
      : this._apps = appList;

  /// This [ApplicationCollection] constructor generates a List of [Application] (which has application information) from List<Map> of Apps from MethodChannel.
  static Future<ApplicationCollection> fromList(List appList) async {
    List<Application> _apps = [];
    for (var appData in appList) {
      Application appInfo = await Application.create(appData);
      _apps.add(appInfo);
    }
    return ApplicationCollection.fromApplications(_apps);
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

  AppIcon _icon;

  AppIcon get icon => _icon;

  var _versionName;

  /// Application version name
  get versionName => _versionName;

  var _versionCode;

  /// Application version code
  get versionCode => _versionCode;

  /// Creates [Application] with
  Application(
      {String label,
      String packageName,
      dynamic versionCode,
      dynamic versionName,
      AppIcon icon})
      : this.label = label,
        this.packageName = packageName,
        this._versionCode = versionCode,
        this._versionName = versionName,
        this._icon = icon;

  /// Asynchronously creates [Application] from map
  static Future<Application> create(Map applicationMap) async {
    AppIcon icon = await AppIcon.getIcon(applicationMap['icon']);
    return Application(
      label: applicationMap["label"],
      packageName: applicationMap['packageName'],
      versionCode: applicationMap['versionCode'],
      versionName: applicationMap['versionName'],
      icon: icon,
    );
  }

  bool get isAdaptableIcon => (this._icon is AdaptableIcon) ? true : false;

  /// It updates [Application] information using [Launcher.getApplicationInfo].
  Future update() async {
    Application appInfo =
        await LauncherHelper.getApplicationInfo(this.packageName);
    this._icon = appInfo.icon;
    this.label = appInfo.label;
    this.packageName = appInfo.packageName;
    this._versionCode = appInfo.versionCode;
    this._versionName = appInfo.versionName;
  }
}
