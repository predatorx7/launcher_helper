// Copyright 2019 Mushaheed Syed. All rights reserved.

// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'palette_generator.dart';

/// This [Applications] generates a List of [AppInfo] (which has application information) for better access.
/// It needs a list with map of applications obtained from platform operations to create [AppInfo].
class Applications {
  /// List with Maps of installed application information
  final List<Map<String, dynamic>> applicationList;
  List<AppInfo> _apps;
  /// List with [AppInfo]s
  List<AppInfo> get apps => _apps;

  Applications(this.applicationList) {
    for (var _appData in applicationList) {
      _apps.add(
        AppInfo(
          label: _appData["label"],
          packageName: _appData["package"],
          iconData: _appData["icon"],
        ),
      );
    }
  }
}

/// [Appinfo] containing Application information obtained from [Applications]'s list.
///
/// This represents a package label as [label], package name as [packageName] and
/// icon [iconData] as a [Uint8List].
///
/// Flutter Image widget can be obtained from [getIconAsImage].
/// Color palette for icon can be obtained through [getIconPalette].
class AppInfo {
  String label;
  String packageName;
  Uint8List iconData;
  AppInfo({this.label, this.packageName, this.iconData});

  /// Creates a flutter Image widget from obtained iconData [Uint8List]
  Image getIconAsImage() {
    return Image.memory(this.iconData);
  }

  Future<PaletteGenerator> getIconPalette() async {
    return await PaletteGenerator.fromUint8List(this.iconData);
  }
}