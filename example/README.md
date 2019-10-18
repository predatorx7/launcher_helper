# launcher_helper_example

Demonstrates how to use the launcher_helper plugin.

## Getting Started

Add `launcher_helper: <version>` to your project's pubspec.yaml file.

You can import this package as: `import 'package:launcher_helper/launcher_helper.dart';`

Use methods from `LauncherHelper` with try/catch in an asynchronous method as Platform messages are
asynchronous and they may fail.

Check example code.

________

- To get all applications & their additional information, use `getApps` method from `LauncherHelper`. It returns a List of Maps of applications with their information.

- Wallpaper is fetched as **Uint8List bytes** through `getWallpaper` method. Use these ImageData bytes in `Image.memory()` as argument to parameter `bytes` to display wallpaper.

- `permission_handler 3.2.2` is used in the example to get external storage access permission.

- Applications can be launched with `launchApp(<Package-name>)` method of `Launcherhelper`; It requires package name of app as String to launch them.

**Note**:

- Don't forget to get external storage access permission before using `getWallpaper`.
