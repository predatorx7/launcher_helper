import 'dart:async';

import 'applications/applications_helper.dart';
import 'wallpaper/wallpaper_helper.dart';

class LauncherHelper with ApplicationsHelper, WallpaperHelper {
  LauncherHelper._();
  static final LauncherHelper _singleton = LauncherHelper._();

  /// Returns a singleton instance of [LauncherHelper]
  factory LauncherHelper() => _singleton;

  static Future<String> get platformVersion async {
    final String version = await ApplicationsHelper.applicationsChannel
        .invokeMethod('getPlatformVersion');
    return version;
  }
}
