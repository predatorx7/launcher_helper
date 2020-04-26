import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:launcher_helper/launcher_helper.dart';

String testAppRet() {
  ApplicationCollection x = ApplicationCollection.fromList([
    {"label": "hello"},
    {"label": "dog"}
  ]);
  Application y = x[1];
  return y.label;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('launcher_helper');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      // return 170;
      return [];
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('get Applications check', () async {
    // expect(await LauncherHelper.getWallpaperBrightness(skipPixel: 3), 170);
    expect(
        await LauncherHelper.getApplications.then((x) {
          print(x);
          return [];
        }),
        []);
  });

  test("Testing ApplicationCollection class", () {
    testAppRet();
    expect(testAppRet(), "dog");
  });

  String testImage = "https://example.com/image.png";
  testWidgets('image brightness check', (WidgetTester tester) async {
    var img;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(builder: (context) {
          var x = Image.network(testImage);
          img = x.image;
          return x;
        }),
      ),
    );
    Completer<ImageInfo> completer = Completer();
    img
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    ui.Image uiImage = imageInfo.image;
    Uint8List imageData;
    uiImage.toByteData().then((ss) {
      imageData = new Uint8List.view(ss.buffer);
      // ui.instantiateImageCodec(lst).then((val) {
      //  val.getNextFrame().then((vaal) {
      //    imagetoDraw = vaal.image;
      //  });
      // });
    });
    int brightness = await LauncherHelper.calculateBrightness(imageData);
    print("Brightness: $brightness");
    expect(await LauncherHelper.calculateBrightness(imageData), brightness);
  });
}
