import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launcher_assist/launcher_assist.dart';

void main() {
  const MethodChannel channel = MethodChannel('launcher_assist');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
//    expect(await LauncherAssist.platformVersion, '42');
  });
}
