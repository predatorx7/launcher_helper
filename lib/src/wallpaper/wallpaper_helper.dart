import 'package:flutter/services.dart';

mixin WallpaperHelper {
  static const MethodChannel _wallpaperChannel =
      const MethodChannel('org.purplegraphite.launcher_helper/wallpaper');

  /// The named channel [LauncherHelper] uses for communicating with platform plugins
  /// responsible for wallpaper data using asynchronous method calls.
  static MethodChannel get wallpaperChannel => _wallpaperChannel;
}
