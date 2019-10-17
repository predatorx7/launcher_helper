# launcher_helper_example

Demonstrates how to use the launcher_helper plugin.

## Getting Started

Add `launcher_helper: <version>` to your project's pubspec.yaml file.

You can import this package as: `import 'package:launcher_helper/launcher_helper.dart';`

Use methods from `LauncherHelper` with try/catch in an asynchronous method as Platform messages are
asynchronous and they may fail.

```dart
  Future<void> initPlatformState() async {
    var apps, imageData;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // Get all apps
      apps = await LauncherHelper.getAllApps;
      // Get wallpaper as binary data
      imageData = await LauncherHelper.getWallpaper;
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
```

________

- To get all applications & their additional information, use `getApps` method from `LauncherHelper`. It returns a List of Maps of applications with their information.

- Wallpaper is fetched as **Uint8List bytes** through `getWallpaper` method. Use these ImageData bytes in `Image.memory()` as argument to parameter `bytes` to display wallpaper.

- Applications can be launched with `launchApp(<Package-name>)` method of `Launcherhelper`; It requires package name of app as String to launch them.
