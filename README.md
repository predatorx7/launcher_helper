# launcher_helper

[![pub package](https://img.shields.io/pub/v/launcher_helper.svg)](https://pub.dartlang.org/packages/launcher_helper)

This plugin is made to help you when building a launcher for Android.

It offers the following features:

- Getting list of installed applications with their icon and other details.
- Support for Adaptive Icons.
- Launching application and getting phone's wallpaper.
- Support for updating application information (asynchrnously)

Only Android is supported. `launcher_helper` is Androidx compatible.

## Usage

- Add `launcher_helper` as a dependency in pubspec.yaml.
- Import package as: `import 'package:launcher_helper/launcher_helper.dart';`
- Use `LauncherHelper` class to use package methods
- Check this [Example's README.md](https://github.com/predatorx7/launcher_helper/tree/master/example) for more information regarding this plugin's usage.
- Check [documentation for library](https://pub.dev/documentation/launcher_helper/latest/launcher_helper/LauncherHelper-class.html)

## Note

- Plugin uses gradle version: 3.3.1 & kotlin version: 1.3.10
- To get device wallpaper, app will need the READ_EXTERNAL_STORAGE permission on Android Oreo & above.
