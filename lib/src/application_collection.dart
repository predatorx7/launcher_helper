// Copyright 2019 Mushaheed Syed. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:launcher_helper/launcher_helper.dart';
import 'icon.dart';
// TODO(predatorx7): Change [ApplicationCollection] to [Packages] or [PackageCollection] & [Application] to [Package]

/// This [ApplicationCollection] is a List of [Application].
///
/// This is not a dart:collection object. It provides a list of [Application] object.
class ApplicationCollection extends Iterable {
  /// List with [Application]s containing information for apps
  List<Application> _apps;

  /// This [ApplicationCollection] constructor generates a List of [Application] from List<Map> of Apps from MethodChannel.
  ApplicationCollection.fromApplications(List<Application> appList)
      : this._apps = appList;

  /// This [ApplicationCollection] constructor generates a List of [Application] from List<Map> of Apps from MethodChannel.
  static Future<ApplicationCollection> fromList(List appList) async {
    List<Application> _apps = [];
    for (var appData in appList) {
      Application appInfo = await Application.create(appData);
      _apps.add(appInfo);
    }
    _apps.sort();
    return ApplicationCollection.fromApplications(_apps);
  }

  /// Number of apps in list.
  /// This property is the same as [totalApps].
  int get length => this.totalApps;

  /// Number of [Application] in this [ApplicationCollection].
  int get totalApps => _apps.length;

  /// Returns [Application] at index `i`.
  Application operator [](int i) => _apps[i];

  @override

  /// Creates a [List] containing the [Application] elements of this [ApplicationCollection] instance.
  ///
  /// The elements are in iteration order.
  /// The list is fixed-length if [growable] is false.
  List<Application> toList({growable = true}) =>
      List<Application>.from(this._apps, growable: growable);

  /// Adds [value] to the end of this list, extending the length by one.
  void add(Application value) {
    this._apps.add(value);
  }

  /// Returns a [Map] view of this.
  /// The map uses the package names of [Applications] in this [ApplicationCollection]
  /// as keys and the corresponding [Applications] as values.
  Map<String, Application> toMap() {
    Map x = {};
    for (var value in this._apps) {
      x[value.packageName] = value;
    }
    return x;
  }

  /// Removes all [Application]s from this [ApplicationCollection];
  /// the length of the [ApplicationCollection] becomes zero.
  void clear() {
    this._apps = [];
  }

  bool contains(Object element) {
    // TODO(predatorx7): Use binary search algorithm
    for (Application app in this._apps) {
      if (element == app) {
        return true;
      }
    }
    return false;
  }

  Application elementAt(int index) {
    return _apps.elementAt(index);
  }

  void forEach(void Function(Application element) f) {
    this._apps.forEach(f);
  }

  int indexOf(Application element, [int start = 0]) {
    return _apps.indexOf(element, start);
  }

  void insert(int index, Application element) {
    _apps.insert(index, element);
  }

  bool get isEmpty => this._apps.isEmpty;

  bool get isNotEmpty => this._apps.isNotEmpty;

  bool remove(Object value) {
    return this._apps.remove(value);
  }

  ///  Removes the [Application] at position [index] from this [ApplicationCollection].
  ///
  /// This method reduces the length of this by one and moves all later objects down by one position.
  Application removeAt(int index) {
    return this._apps.removeAt(index);
  }

  /// Sorts this list according to the order specified by the [compare] function.
  ///
  /// The [compare] function must act as a [Comparator].
  void sort([int Function(Application a, Application b) compare]) {
    // TODO(predatorx7): Implement quicksort
    this._apps.sort(compare);
  }

  /// Returns a new [ApplicationCollection] containing the [Application]s between [start] and [end].
  ///
  /// The new [ApplicationCollection] is a List containing the [Application] of this at positions
  /// greater than or equal to [start] and less than [end] in the same order as they occur in this [ApplicationCollection].
  ApplicationCollection sublist(int start, [int end]) {
    return ApplicationCollection.fromApplications(
        this._apps.sublist(start, end));
  }

  @override
  Iterator<Application> get iterator => _apps.iterator;

  /// Updates this [ApplicationCollection] with [LauncherHelper.updateApplicationCollection].
  /// Set [sort] to true to allow sorting.
  Future<void> update([bool sort = true]) async {
    await LauncherHelper.updateApplicationCollection(this, sort);
  }

  /// Update this with a list of new or updated packages.
  ///
  /// Set [sort] to true to allow sorting.
  /// 
  /// Note: This doesn't update packages which has same version name & version code
  /// but different icon. This is to remove the overhead of handling icon to improve performance.
  Future<void> updateWith(List newOrUpdatedPackages, [bool sort = true]) async {
    if (newOrUpdatedPackages?.isEmpty ?? true) return;
    for (Map i in newOrUpdatedPackages) {
      bool shouldAdd = true;
      if (i['shouldRemove']) {
        // App was removed from device
        this.remove(i['packageName']);
        continue;
      }
      for (Application app in this) {
        if (app.packageName == i['packageName']) {
          // Package was already in the list.
          shouldAdd = false;
          // Checking if needs update
          if (app.versionName == i['versionName'] &&
              app.versionCode == i['versionCode']) {
            // Doesn't need update
            break;
          }
          await app.updateFromMap(i);
          continue;
        }
      }
      if (shouldAdd) {
        // Package was not in the list
        var newApp = await Application.create(i);
        this.add(newApp);
      }
    }
    if (sort) {
      this.sort();
    }
  }

  /// Returns true if [other] is same as [Application]s in this.
  bool operator ==(Object other) {
    if (!(other is ApplicationCollection)) return false;
    ApplicationCollection typedOther = other;
    if (typedOther.length != this.length) {
      return false;
    }
    for (Application item in typedOther) {
      if (!(this.contains(item))) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    int _hash = 0;
    for (Application i in this) {
      _hash += i.hashCode;
    }
    return _hash;
  }
}

/// An [Application] which will represent a package.
///
/// It contains package's [label], [packageName] and
/// [icon].
class Application extends Comparable<Application> {
  /// Application label
  String _label;

  /// Application label
  String get label => _label;

  /// Application package name
  final String packageName;

  AppIcon _icon;

  /// The icon which represents this [Application]
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
      this.packageName,
      dynamic versionCode,
      dynamic versionName,
      AppIcon icon})
      : this._label = label,
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

  /// Returns true [icon] of this package is an adaptable icon.
  bool get isAdaptableIcon => (this._icon is AdaptableIcon) ? true : false;

  /// Launches this application.
  Future<bool> launch() async {
    return await LauncherHelper.launchApplication(packageName);
  }

  /// It updates [Application] information using [Launcher.getApplicationInfo].
  Future refresh() async {
    Application appInfo =
        await LauncherHelper.getApplicationInfo(this.packageName);
    this._icon = appInfo.icon;
    this._label = appInfo.label;
    this._versionCode = appInfo.versionCode;
    this._versionName = appInfo.versionName;
  }

  /// Updates this [Application] with other 
  /// if [packageName] is same but [versionName] or [versionCode] is different.
  ///
  /// Returns true if this is updated and false if not.
  bool update(Application other) {
    if (this.packageName == other.packageName &&
        (this.hashCode != other.hashCode)) {
      this._label = other.label;
      this._icon = other._icon;
      this._versionName = other._versionName;
      this._versionCode = other._versionCode;
      return true;
    }
    return false;
  }

  /// Update this [Application] with a map if [packageName] is same but [versionName] or [versionCode] is different.
  ///
  /// Returns true if this is updated.
  Future<bool> updateFromMap(Map other) async {
    if (this.packageName == other['packageName'] &&
        (this._versionCode != other['versionCode'] ||
            this._versionName != other['versionName'])) {
      this._label = other['label'];
      this._icon = await AppIcon.getIcon(other['icon']);
      this._versionCode = other['versionCode'];
      this._versionName = other['versionName'];
      return true;
    }
    return false;
  }

  /// Compares this Application to [other].
  ///
  /// Returns a negative value if `this` is ordered before `other`,
  /// a positive value if `this` is ordered after `other`,
  /// or zero if `this` and `other` are equivalent.
  ///
  /// The ordering is the same as the ordering of labels of this [Application].
  /// The comparison is not case sensitive.
  @override
  int compareTo(Application other) {
    String a = this.label.toLowerCase();
    String b = other.label.toLowerCase();
    // this is equivalent to other
    if (a == b) return 0;
    var _c = [a, b];
    _c.sort();
    if (_c.first == a) {
      // this is ordered before to other
      return -1;
    } else {
      // this is ordered after other
      return 1;
    }
  }

  @override
  bool operator ==(dynamic other) {
    if (other is String) {
      if (this.packageName == other) return true;
    } else if (other is Application) {
      // Not testing Icon as it should only be different for different versions
      return this.label == other.label &&
          this.packageName == other.packageName &&
          this.versionName == other.versionName &&
          this.versionCode == other.versionCode;
    }
    return false;
  }

  @override
  int get hashCode =>
      this.label.hashCode +
      this.packageName.hashCode +
      this.versionName.hashCode +
      this.versionCode.hashCode;
}
