import 'package:flutter/material.dart';
import 'package:launcher_helper/launcher_helper.dart';
import 'package:red/commons/dark_theme.dart';
import 'package:flutter/services.dart';
import 'core/utils/permission_handling.dart';
import 'package:red/commons/light_theme.dart';

import 'commons/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HandlerOfPermissions().requestPerm();
  runApp(Root());
}

class Root extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("[Root] Under Root Widget");
    print("Asking for permissions");

    return MaterialApp(
      title: 'Red',
      onGenerateRoute: generateRoute,
      themeMode: ThemeMode.system,
      // theme: lightTheme,
      theme: ThemeData(primaryColor: Colors.blue),
      // darkTheme: darkTheme,
      home: HomePage(),
    );
  }
}

class WaitPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: HandlerOfPermissions().requestPerm(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return CircularProgressIndicator();
            if (snapshot.data) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            }
            return Text("Permissions request failed");
          },
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int numberOfInstalledApps;
  ApplicationCollection installedApps;
  var wallpaper;
  PaletteGenerator palette;
  int brightness, brightness2;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    ApplicationCollection apps;
    var imageData, _palette;
    int _brightness, _brightness2;

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

      _brightness2 = await LauncherHelper.getBrightnessFrom(imageData);
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
      brightness2 = _brightness2; 
    });
  }

  @override
  Widget build(BuildContext context) {
    var colors = palette?.colors;
    print("[Home] Under HomePage Screen");
    return Scaffold(
      appBar: AppBar(
        title: Text("Launcher Helper"),
      ),
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
              Text("Below is this wallpaper's dominant Color: "),
              Container(
                height: 50,
                width: 50,
                color: colors != null ? colors?.toList()[0] ?? null : null,
              ),
              Text(
                  'Wallpaper brightness calculated from every pixel is: $brightness'),
              SizedBox(
                height: 5,
              ),
              Text(
                  'Wallpaper brightness calculated from every pixel is (2nd method): $brightness2'),
              SizedBox(
                height: 5,
              ),
              Text("By pure dart (Under experimentations): "),
              (wallpaper != null)
                  ? new Builder(
                      builder: (BuildContext context) {
                        int value =
                            LauncherHelper.calculateBrightness(wallpaper);
                        return Container(
                          child: Column(
                            children: <Widget>[
                              Text('Is wallpaper dark? ${value> 0.5}'),
                              Text('Brightness: ${value}'),
                            ],
                          ),
                        );
                      },
                    )
                  : Container(),
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
  final ApplicationCollection appList;
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
