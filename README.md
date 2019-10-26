# launcher_helper

[![pub package](https://img.shields.io/pub/v/launcher_helper.svg)](
https://pub.dartlang.org/packages/launcher_helper)

This plugin is made to help you when building a launcher for Android. `launcher_helper` is Androidx compatible. It offers the following features: Getting list of installed applications, launching them and getting phone's wallpaper, picking prominent colors from wallpaper or image for use in UI, etc.

Only Android is supported.

Note that on devices running Android Oreo or higher, methods which gets/uses Phone's wallpaper will work only if your app has the READ_EXTERNAL_STORAGE permission.

## Usage

- Add `launcher_helper` as a dependency in pubspec.yaml.
- Import package as: `import 'package:launcher_helper/launcher_helper.dart';`
- Use `LauncherHelper` class to use package methods
- Check this [Example's README.md](https://github.com/predatorx7/launcher_helper/tree/master/example) for more information regarding this plugin's usage.

## Note

- If you are using __launcher_helper 0.1.1__ then you have to include `palette_generator` in your project.
