/// MIT License
/// Copyright (c) 2019 Syed Mushaheed
/// Permission is hereby granted, free of charge, to any person obtaining a copy of this
/// software and associated documentation files (the "Software"), to deal in the
/// Software without restriction, including without limitation the rights to use, copy,
/// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
/// and to permit persons to whom the Software is furnished to do so, subject to the
/// following conditions:
///
/// The above copyright notice and this permission notice shall be included in all copies
/// or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
/// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
/// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
/// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
/// ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
/// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
/// OTHER DEALINGS IN THE SOFTWARE.
/// ---------------------------------------------------------------------------------------
/// Modifications Copyright 2019 Mushaheed Syed
/// Copyright 2017 Ashraff Hathibelagal
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///     http://www.apache.org/licenses/LICENSE-2.0
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:launcher_helper/launcher_helper.dart';
import 'package:palette_generator/palette_generator.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {var numberOfInstalledApps;
  var installedApps;
  var wallpaper;
  PaletteGenerator palette;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    var apps, imageData, _palette;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // Get all apps
      apps = await LauncherHelper.getAllApps;
      // Get wallpaper as binary data
      imageData = await LauncherHelper.getWallpaper;
      // Get Color palette (generated from wallpaper)
      _palette = await LauncherHelper.palette;
    } on PlatformException {
      print('Failed to get apps or wallpaper');
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      numberOfInstalledApps = apps.length;
      installedApps = apps;
      wallpaper = imageData;
      palette = _palette;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          new Text("Found $numberOfInstalledApps apps installed"),
          new RaisedButton(
            child: new Text("Launch Something"),
            onPressed: () {
              // Launch the first app available
              LauncherHelper.launchApp(installedApps[0]["package"]);
            },
          ),
          wallpaper != null
              ? new Image.memory(wallpaper, fit: BoxFit.scaleDown)
              : new Center(),
          Container(
            height: 50,
            width: 50,
            color: palette.colors.toList()[0],
          ),
          SingleChildScrollView(
            child: Text(installedApps.toString()),
          ),
        ],
      ),
    );
  }
}
