import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:launcher_helper/launcher_helper.dart';
import 'package:provider/provider.dart';

import 'commons/routes.dart';
import 'utils/permission_handling.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Requesting runtime permissions
    HandlerOfPermissions().askOnce();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WallpaperPageModel>(
          create: (context) => WallpaperPageModel(),
        ),
        ChangeNotifierProvider<ApplicationPageModel>(
          create: (context) => ApplicationPageModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Red',
        onGenerateRoute: generateRoute,
        themeMode: ThemeMode.system,
        theme: ThemeData(primaryColor: Colors.blue),
      ),
    );
  }
}

class Showcase extends StatefulWidget {
  @override
  _ShowcaseState createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ShowcaseButton(
            title: "Wallpaper",
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => WallpaperPage()));
            },
          ),
          ShowcaseButton(
            title: "Applications",
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ApplicationsPage()));
            },
          ),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            Provider.of<ApplicationPageModel>(context).count.toString(),
          ),
          actions: [
            FlatButton(
              onPressed: () {
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
              child: CircularProgressIndicator(),
            );
          }
          return AppIconShape(
            data: model.iconShape,
            child: ListView.builder(
              itemCount: model.count,
              itemBuilder: (context, index) {
                Application app = model.apps[index];
                String subtitle =
                    '${app.packageName}\n${app.versionName}.${app.versionCode}';
                return ListTile(
                  key: new ObjectKey(app.packageName),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ApplicationPage(app),
                      ),
                    );
                  },
                  leading: app.icon,
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

class ApplicationPage extends StatelessWidget {
  final Application app;
  const ApplicationPage(
    this.app, {
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();
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
          body: ListView(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AppIconShape(
                      data: model.iconShape,
                      child: app.icon,
                    ),
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
                    LauncherHelper.launchApplication(app.packageName);
                  },
                ),
              ),
              Heading('Change Icon shape'),
              SizedBox(height: 10),
              OutlineButton(
                child: Text('Circular'),
                onPressed: () {
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
              Heading('Change Icon scale'),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: textController,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'scale',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FlatButton(
                  color: Colors.white,
                  child: Text('Apply scale'),
                  onPressed: () {
                    double _scale = double.parse(textController.text);
                    print('changing size to $_scale');
                    model.setIconShape(
                      AppIconShape.of(context).copyWith(
                        scale: _scale,
                      ),
                    );
                    textController.clear();
                  },
                ),
              ),
            ],
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
      padding: margin ?? EdgeInsets.all(8),
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

  init() async {
    int before, after;
    before = DateTime.now().millisecondsSinceEpoch;
    _wallpaperData = await LauncherHelper.getWallpaper;
    after = DateTime.now().millisecondsSinceEpoch;
    var difference = after - before;
    print('Recieved wallpaper in $difference ms');
    wallpaper = Image.memory(_wallpaperData);
    _hasWallpaper = true;
    notifyListeners();
  }

  Future<void> refresh() async {
    int before, after;
    before = DateTime.now().millisecondsSinceEpoch;
    var sub = await LauncherHelper.getWallpaper;
    if (sub.length == _wallpaperData.length) {
      bool same = true;
      for (var i = 0; i < sub.length; i++) {
        same = (sub[i] == _wallpaperData[i]);
        if (!same) break;
      }

      if (same) {
        after = DateTime.now().millisecondsSinceEpoch;
        var difference = after - before;
        print('Updated applications in $difference ms');
        return;
      }
    }
    _wallpaperData = sub;
    wallpaper = Image.memory(_wallpaperData);
    after = DateTime.now().millisecondsSinceEpoch;
    var difference = after - before;
    print('Updated applications in $difference ms');
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

  AppIconShapeData get iconShape => _iconShape;

  void setIconShape(AppIconShapeData iconShape) {
    _iconShape = iconShape;
    notifyListeners();
  }

  ApplicationPageModel() {
    init();
  }

  init() async {
    if (hasApplications) return;
    int before, after;
    before = DateTime.now().millisecondsSinceEpoch;
    _applicationCollection = await LauncherHelper.getApplications();
    after = DateTime.now().millisecondsSinceEpoch;
    var difference = after - before;
    print('Recieved applications in $difference ms');
    _hasApplications = true;
    notifyListeners();
  }

  Future<void> refresh() async {
    int before, after;
    before = DateTime.now().millisecondsSinceEpoch;
    await _applicationCollection.update();
    after = DateTime.now().millisecondsSinceEpoch;
    var difference = after - before;
    print('Updated applications in $difference ms');
    notifyListeners();
  }
}
