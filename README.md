# launcher_helper

[![pub package](https://img.shields.io/pub/v/launcher_helper.svg)](
https://pub.dartlang.org/packages/launcher_helper)

This package helps to reduce work when creating a launcher. In the current build, it can get list of installed applications, launching them and getting phone's wallpaper. Only Android is supported.

## Usage

- Add `launcher_helper` as a dependency in pubspec.yaml.
- Import package as: `import 'package:launcher_helper/launcher_helper.dart';`
- Use `LauncherHelper` class to use package methods

## Note

- To be usable, __launcher_helper 0.1.1__ is dependant upon palette_generator in your project. Add `palette_generator: 0.2.0` as a dependency in your pubspec.yaml. This can be safely ignored in __launcher_helper 0.2.0__ and above
