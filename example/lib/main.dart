import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:launcher_helper/launcher_helper.dart';
import 'package:provider/provider.dart';

import 'utils/permission_handling.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Requesting runtime permissions
    HandlerOfPermissions().askOnce();
    // Providers to handle data across the app
    return MultiProvider(
      providers: [
        // This handles data for a wallpaper
        ChangeNotifierProvider<WallpaperPageModel>(
          create: (context) => WallpaperPageModel(),
        ),
        // This handles data regarding installed applications
        ChangeNotifierProvider<ApplicationPageModel>(
          create: (context) => ApplicationPageModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Red',
        themeMode: ThemeMode.system,
        theme: ThemeData(primaryColor: Colors.blue),
        home: Showcase(),
      ),
    );
  }
}

/// The showcase to present example usage of some methods in the library
class Showcase extends StatefulWidget {
  @override
  _ShowcaseState createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase> {
  @override
  Widget build(BuildContext context) {
    Widget wallpaperPageButton = ShowcaseButton(
      title: "Wallpaper",
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WallpaperPage(),
          ),
        );
      },
    );
    Widget applicationsPageButton = ShowcaseButton(
      title: "Applications",
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ApplicationsPage(),
          ),
        );
      },
    );
    return Scaffold(
      body: ListView(
        children: [
          wallpaperPageButton,
          applicationsPageButton,
        ],
      ),
    );
  }
}

class WallpaperPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              // Refreshes to check if wallpaper has been changed
              Provider.of<WallpaperPageModel>(context, listen: false).refresh();
            },
            child: Text('Refresh wallpaper'),
          ),
        ],
      ),
      body: Consumer<WallpaperPageModel>(
        builder: (context, model, _) {
          return Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                // Shows wallpaper if available. Else shows a progress indicator
                model.hasWallpaper
                    ? model.wallpaper
                    : CircularProgressIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ApplicationsPage extends StatelessWidget {
  // a callback which is ran after the frame callback.
  void initPostFrame(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Provider.of<ApplicationPageModel>(context, listen: false).init(),
    );
  }

  @override
  Widget build(BuildContext context) {
    initPostFrame(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(
            // Number of installed applications which can be launched
            Provider.of<ApplicationPageModel>(context).count.toString(),
          ),
          actions: [
            FlatButton(
              onPressed: () {
                // Updates the application collection
                Provider.of<ApplicationPageModel>(context, listen: false)
                    .refresh();
              },
              child: Text('Refresh'),
            ),
          ]),
      body: Consumer<ApplicationPageModel>(
        builder: (context, model, _) {
          if (model.count == 0) {
            return Center(
              // displays a progress indicator if the list is empty
              child: CircularProgressIndicator(),
            );
          }
          return AppIconShape(
            // Here the model provides the shape which will be used by AppIconShape consumers
            data: model.iconShape,
            child: ListView.builder(
              itemCount: model.count,
              itemBuilder: (context, index) {
                // An Application on this collection at index location
                Application app = model.apps[index];
                // Other information of the app
                String subtitle =
                    '${app.packageName}\n${app.versionName}.${app.versionCode}';
                return ListTile(
                  // package name is unique hence can be used in key creation
                  key: new ObjectKey(app.packageName),
                  onTap: () {
                    // Open Icon's shape customizer page
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ShapeCustomizerPage(app),
                      ),
                    );
                  },
                  // the icon of this app
                  leading: app.icon,
                  // the label of this app
                  title: Text(app.label),
                  subtitle: Text(subtitle),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ShapeCustomizerPage extends StatelessWidget {
  final Application app;
  const ShapeCustomizerPage(
    this.app, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationPageModel>(
      builder: (context, model, _) {
        return Scaffold(
          backgroundColor: Colors.grey[400],
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(app.label),
                SizedBox(
                  width: 5,
                ),
                // Shows a red warning if the icon is not adaptable
                app.isAdaptableIcon
                    ? SizedBox()
                    : Container(
                        color: Colors.red,
                        child: Text(
                          'Not adaptable',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      )
              ],
            ),
          ),
          body: AppIconShape(
            data: model.iconShape,
            child: ListView(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: app
                          .icon, // this icon will be affected by the modifications
                    ),
                  ],
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: FlatButton(
                    color: Colors.cyan,
                    child: Text(
                      'Open',
                    ),
                    onPressed: () {
                      app.launch(); // launches the app
                    },
                  ),
                ),
                Heading('Change Icon shape'),
                SizedBox(height: 10),
                // below buttons allow the shape to be changed with some predefined data
                OutlineButton(
                  child: Text('Circular'),
                  onPressed: () {
                    // This constructor creates shape data of a circular icon
                    model.setIconShape(AppIconShapeData.circular());
                  },
                ),
                OutlineButton(
                  child: Text('Square'),
                  onPressed: () {
                    model.setIconShape(AppIconShapeData.square());
                  },
                ),
                OutlineButton(
                  child: Text('Squircle'),
                  onPressed: () {
                    model.setIconShape(AppIconShapeData.squircle());
                  },
                ),
                OutlineButton(
                  child: Text('Teardrop'),
                  onPressed: () {
                    model.setIconShape(AppIconShapeData.teardrop());
                  },
                ),
                Divider(),
                // Below option changes icon size i.e radius
                Heading('Change Icon radius ${model.iconShape.radius}'),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Slider(
                    // This slider controls the radius of icons
                    value: model.iconShape.radius,
                    min: 20,
                    max: 100,
                    onChanged: (double value) {
                      AppIconShape.of(context).copyWith(
                        radius: value,
                      );
                      model.setIconShape(
                        AppIconShape.of(context).copyWith(
                          radius: value,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Heading extends StatelessWidget {
  final String text;

  const Heading(
    this.text, {
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class ShowcaseButton extends StatelessWidget {
  final String title;
  final void Function() onPressed;
  final EdgeInsetsGeometry margin;
  const ShowcaseButton({Key key, this.title, this.onPressed, this.margin})
      : assert(title != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.all(12),
      child: OutlineButton(
        child: Text(title ?? ''),
        onPressed: onPressed,
      ),
    );
  }
}

class WallpaperPageModel extends ChangeNotifier {
  Uint8List _wallpaperData;
  Image wallpaper;
  bool _hasWallpaper = false;
  bool get hasWallpaper => _hasWallpaper;

  WallpaperPageModel() {
    init();
  }

  // Asynchronously sets wallpaper. Used only once or in the constructor.
  init() async {
    // Retrieves the wallpaper
    _wallpaperData = await LauncherHelper.getWallpaper;
    wallpaper = Image.memory(_wallpaperData);
    _hasWallpaper = true;
    notifyListeners();
  }

  // Updates wallpaper if changed
  Future<void> refresh() async {
    // Fresh copy of wallpaper is obtained
    var sub = await LauncherHelper.getWallpaper;
    // The new and existing wallpaper is compared
    if (sub.length == _wallpaperData.length) {
      bool same = true;
      for (var i = 0; i < sub.length; i++) {
        // Comparing bytes at same index of both new and old wallpaper
        same = (sub[i] == _wallpaperData[i]);
        if (!same) break;
      }

      if (same) {
        // the wallpaper is same as before, hence no changes shall be made/notified
        return;
      }
    }
    // The new wallpaper is different
    // Making changes in the app to display new wallpaper 
    _wallpaperData = sub;
    wallpaper = Image.memory(_wallpaperData);
    notifyListeners();
  }
}

class ApplicationPageModel extends ChangeNotifier {
  ApplicationCollection _applicationCollection;
  ApplicationCollection get apps => _applicationCollection;
  bool _hasApplications = false;
  int get count => apps?.length ?? 0;
  bool get hasApplications => _hasApplications;
  AppIconShapeData _iconShape = AppIconShapeData.circular();

  // Describes an icon's shape.
  // This will be passed to AppIconShape's data.
  AppIconShapeData get iconShape => _iconShape;

  // Setting icon shape through this method.
  void setIconShape(AppIconShapeData iconShape) {
    _iconShape = iconShape;
    notifyListeners();
  }

  ApplicationPageModel();

  // Asynchronously fetches all applications. Used only once as this is an expensive operation.
  init() async {
    if (hasApplications) return;
    // Retrievig applications
    _applicationCollection = await LauncherHelper.getApplications();
    _hasApplications = true;
    notifyListeners();
  }

  // Updating changes in the applications
  Future<void> refresh() async {
    // updates application without much performance issues.
    await _applicationCollection.update();
    notifyListeners();
  }
}
