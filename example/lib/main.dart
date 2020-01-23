import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:launcher_helper/launcher_helper.dart';
import 'package:flutter/services.dart';
import 'core/utils/permission_handling.dart';
import 'package:image_picker/image_picker.dart';

import 'commons/routes.dart';

void main() async {
  // Requesting runtime permissions
  HandlerOfPermissions().requestPerm();
  runApp(Root());
}

class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red',
      onGenerateRoute: generateRoute,
      themeMode: ThemeMode.system,
      theme: ThemeData(primaryColor: Colors.blue),
      home: ShowCase(),
    );
  }
}

class ShowCase extends StatefulWidget {
  @override
  _ShowCaseState createState() => _ShowCaseState();
}

class _ShowCaseState extends State<ShowCase> {
  // Static method to show a [SnackBar] with `message`
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showFailure(
      String message, BuildContext context) {
    print("[Failure] $message");
    return Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Showcase"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("For Wallpaper"),
            onTap: () async {
              // Platform messages may fail, so we use a try/catch PlatformException.
              try {
                // Get wallpaper as binary data
                Uint8List imageData = await LauncherHelper.getWallpaper;
                // Pushing show Wallpaper page
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ShowWallpaper(
                      imageData,
                    ),
                  ),
                );
              } on PlatformException {
                String message = 'Failed to get wallpaper, check permissions';
                showFailure(message, context);
              }
            },
          ),
          ListTile(
            title: Text("For any image"),
            onTap: () async {
              // Platform messages may fail, so we use a try/catch PlatformException.
              try {
                // Get image from image picker
                io.File image =
                    await ImagePicker.pickImage(source: ImageSource.gallery);

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ShowImage(
                      // using readAsBytesSync to get Uint8List from image
                      image.readAsBytesSync(),
                    ),
                  ),
                );
              } catch (e) {
                String message = 'Failed to get image';
                showFailure(message, context);
              }
            },
          ),
          ListTile(
            title: Text("For Device applications"),
            onTap: () async {
              // Platform messages may fail, so we use a try/catch PlatformException.
              try {
                // Get all apps
                ApplicationCollection apps =
                    await LauncherHelper.getApplications;
                // Do something
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AppListPage(
                      appList: apps,
                    ),
                  ),
                );
              } on PlatformException {
                String message = 'Failed to get apps';
                showFailure(message, context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class ShowWallpaper extends StatefulWidget {
  final Uint8List imageData;
  const ShowWallpaper(this.imageData);

  @override
  _ShowWallpaperState createState() => _ShowWallpaperState();
}

class _ShowWallpaperState extends State<ShowWallpaper> {
  int brightness;
  double luminance, brightnessDart;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Methods for wallpaper"),
      ),
      body: GridView.count(
        crossAxisCount: 1,
        mainAxisSpacing: 5,
        children: <Widget>[
          Card(
            child: GridTile(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(
                  widget.imageData,
                ),
              ),
              footer: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text("Home screen wallpaper"),
              ),
            ),
          ),
          ListTile(
            title: Text(
                "Tap to check wallpaper brightness (using native method)\nReturns a brightness level between 0 and 255, where 0 = totally black and 255 = totally bright."),
            subtitle: Text(brightness?.toString() ?? ""),
            onTap: () async {
              brightness =
                  await LauncherHelper.calculateBrightness(widget.imageData);
              print("Brightness (native): $brightness");
              setState(() {
                brightness = brightness;
              });
            },
          ),
        ],
      ),
    );
  }
}

class ShowImage extends StatefulWidget {
  final Uint8List imageData;
  const ShowImage(this.imageData);

  @override
  _ShowImageState createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  int brightness;
  double luminance, brightnessDart;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Methods for any image"),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(
                  widget.imageData,
                  fit: BoxFit.fitWidth,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text("This is the image you picked"),
              ),
            ),
          ),
          ListTile(
            title: Text(
                "Tap to check image brightness (using native method)\nReturns a brightness level between 0 and 255, where 0 = totally black and 255 = totally bright."),
            subtitle: Text(brightness?.toString() ?? ""),
            onTap: () async {
              // Method to calculate brightness using native method from platform channel
              brightness =
                  await LauncherHelper.calculateBrightness(widget.imageData);
              print("Brightness (native): $brightness");
              // updates brightness state
              setState(() {
                brightness = brightness;
              });
            },
          ),
        ],
      ),
    );
  }
}

class AppListPage extends StatelessWidget {
  final ApplicationCollection appList;
  AppListPage({this.appList});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Installed ${appList.length} Apps'),
      ),
      body: ListView.builder(
        itemCount: appList.length,
        itemBuilder: (BuildContext context, int index) {
          var app = appList.toList()[index];
          return ListTile(
            onTap: () {
              // LauncherHelper.launchApp(app.packageName);
              return customDialogBox(app, context);
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

Future customDialogBox(Application app, BuildContext context) async {
  await app.updateInfo();
  bool isEnabled, doesExist;
  try {
    isEnabled = await LauncherHelper.isApplicationEnabled(app.packageName);
    doesExist = await LauncherHelper.doesApplicationExist(app.packageName);
  } on PlatformException {
    print("Platform error");
  }
  var palette = await LauncherHelper.generatePalette(app.iconData);
  Color dominantColor = palette.colors.first;
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: new Container(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // dialog top
              new Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundImage: Image.memory(app.iconData).image,
                    ),
                  ),
                  new Container(
                    child: new Text(
                      app.label,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),

              // dialog centre
              new Container(
                child: Text(app.packageName),
              ),
              new Container(
                child: Text("Version name: ${app.versionName}"),
              ),
              new Container(
                child: Text("Version code: ${app.versionCode}"),
              ),
              new Container(
                child: Text("Is app enabled? : $isEnabled"),
              ),
              new Container(
                child: Text("Does app exist?: $doesExist"),
              ),

              // dialog bottom
              Text("Dominant color"),
              Container(
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.all(8),
                color: dominantColor,
                height: 50,
                width: 50,
              ),
              RaisedButton(
                onPressed: () {
                  LauncherHelper.launchApp(app.packageName);
                },
                child: Text("Launch"),
              ),
            ],
          ),
        ),
      );
    },
  );
}
