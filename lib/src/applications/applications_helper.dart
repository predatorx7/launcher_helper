import 'package:flutter/services.dart';

mixin ApplicationsHelper {
  static const MethodChannel _applicationsChannel =
      const MethodChannel('org.purplegraphite.launcher_helper/applications');

  /// The named channel [LauncherHelper] uses for communicating with platform plugins
  /// responsible for application data using asynchronous method calls.
  static MethodChannel get applicationsChannel => _applicationsChannel;
}
