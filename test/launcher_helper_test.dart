import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launcher_helper/launcher_helper.dart';

void main() {
  const MethodChannel channel = MethodChannel('launcher_helper');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return 170;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getWallpaperBrightness', () async {
    expect(await LauncherHelper.getWallpaperBrightness(skipPixel: 3), 170);
  });
}
