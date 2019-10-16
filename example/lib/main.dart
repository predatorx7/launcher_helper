import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:launcher_assist/launcher_assist.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var numberOfInstalledApps;
  var installedApps;
  var wallpaper;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    var apps, imageData;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // Get all apps
      apps = await LauncherAssist.getAllApps;
      // Get wallpaper as binary data
      imageData = await LauncherAssist.getWallpaper;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            new Text("Found $numberOfInstalledApps apps installed"),
            new RaisedButton(
              child: new Text("Launch Something"),
              onPressed: () {
                // Launch the first app available
                LauncherAssist.launchApp(installedApps[0]["package"]);
              },
            ),
//            wallpaper != null
//                ? new Image.memory(wallpaper, fit: BoxFit.scaleDown)
//                : new Center(),
            Visibility(
              child: Image.memory(wallpaper, fit: BoxFit.scaleDown),
              replacement: const SizedBox.shrink(), // new Center(),
              visible: wallpaper != null,
            ),
          ],
        ),
      ),
    );
  }
}
