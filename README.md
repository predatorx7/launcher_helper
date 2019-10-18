# launcher_helper

[![pub package](https://img.shields.io/pub/v/launcher_helper.svg)](
https://pub.dartlang.org/packages/launcher_helper)

This package helps to reduce work when creating a launcher. In the current build, it can get list of installed applications, launching them and getting phone's wallpaper. Only Android is supported.

## Usage

- Add `launcher_helper` as a dependency in pubspec.yaml.
- Import package as: `import 'package:launcher_helper/launcher_helper.dart';`
- Use `LauncherHelper` class to use package methods
- Check Example's README.md for more information.

## Note

- From __0.2.0__, `launcher_helper` is no longer dependant upon `palette_generator`. But, if you are using __launcher_helper 0.1.1__ then you have to include `palette_generator` in your project
