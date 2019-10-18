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
import 'package:permission_handler/permission_handler.dart';

class HandlerOfPermissions {
  Future<bool> requestPerm() async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      print('[HandlerOfPermissions] permission not granted.');
      await PermissionHandler().openAppSettings();
      if (permission != PermissionStatus.granted) {
        print('[HandlerOfPermissions] permission not granted.');
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }
}

void main() async {
  // Obtaining permissions
  await HandlerOfPermissions().requestPerm();
  runApp(Root());
}

class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Red',
        themeMode: ThemeMode.system,
        // theme: lightTheme,
        theme: ThemeData(primaryColor: Colors.blue),
        // darkTheme: darkTheme,
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int numberOfInstalledApps;
  Applications installedApps;
  var wallpaper;
  PaletteGenerator palette;
  int brightness;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    Applications apps;
    var imageData, _palette;
    int _brightness;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // Get all apps
      apps = await LauncherHelper.getApplications;
      // Get wallpaper as binary data
      imageData = await LauncherHelper.getWallpaper;
      // Generate palette
      _palette = await LauncherHelper.wallpaperPalette;
      // Get brightness
      _brightness = await LauncherHelper.getWallpaperBrightness(skipPixel: 50);
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
      brightness = _brightness;
    });
  }

  @override
  Widget build(BuildContext context) {
    var colors = palette?.colors;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: <Widget>[
              new Text("Found $numberOfInstalledApps apps installed"),
              (wallpaper != null)
                  ? new FutureBuilder(
                      future: // Get luminance
                          LauncherHelper.getLuminance(imageData: wallpaper),
                      builder:
                          (BuildContext context, AsyncSnapshot<double> aSnap) {
                        if (aSnap.hasData) {
                          return Container(
                            child: Column(
                              children: <Widget>[
                                Text('Is wallpaper dark? ${aSnap.data > 0.5}'),
                                Text('Luminance: ${aSnap.data}'),
                              ],
                            ),
                          );
                        } else
                          return Container();
                      },
                    )
                  : Container(),
              wallpaper != null
                  ? new Image.memory(wallpaper, fit: BoxFit.scaleDown)
                  : new Center(),
              Container(
                height: 50,
                width: 50,
                color: colors != null ? colors?.toList()[0] ?? null : null,
              ),
              Text(
                  'Wallpaper brightness calculated from every pixel: $brightness'),
              SizedBox(
                height: 5,
              ),
              OutlineButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AppListPage(
                        appList: installedApps,
                      ),
                    ),
                  );
                },
                child: Text('Next Page'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppListPage extends StatelessWidget {
  final Applications appList;
  AppListPage({this.appList});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Installed Apps'),
      ),
      body: ListView.builder(
        itemCount: appList.length,
        itemBuilder: (BuildContext context, int index) {
          var app = appList.toList()[index];
          return ListTile(
            onTap: () {
              LauncherHelper.launchApp(app.packageName);
            },
            leading: Container(
              height: 50,
              width: 50,
              child: Image.memory(
                app.iconData,
              ),
            ),
            title: Text(
              app.label,
            ),
            subtitle: Text(
              app.packageName,
            ),
          );
        },
      ),
    );
  }
}
