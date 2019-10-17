/// MIT License
/// Copyright (c) 2019 Syed Mushaheed
/// Permission is hereby granted, free of charge, to any person obtaining a copy of this
/// software and associated documentation files (the "Software"), to deal in the
/// Software without restriction, including without limitation the rights to use, copy,
/// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
/// and to permit persons to whom the Software is furnished to do so, subject to the
/// following conditions:
///
/// The above copyright notice and this permission notice shall be included in all copies
/// or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
/// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
/// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
/// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
/// ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
/// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
/// OTHER DEALINGS IN THE SOFTWARE.
/// ---------------------------------------------------------------------------------------
/// Modifications Copyright 2019 Mushaheed Syed
/// Copyright 2017 Ashraff Hathibelagal
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///     http://www.apache.org/licenses/LICENSE-2.0
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

import 'dart:async';
import 'dart:typed_data';

import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:palette_generator/palette_generator.dart';

class LauncherHelper {
  static const MethodChannel _channel = const MethodChannel('launcher_helper');

  /// Returns a list of apps installed on the user's device
  static Future<List> get getAllApps async {
    var data = await _channel.invokeMethod('getAllApps');
    return data;
  }

  /// Launches an app using its package name
  static Future launchApp(String packageName) async {
    await _channel.invokeMethod("launchApp", {"packageName": packageName});
  }

  /// Gets you the current wallpaper on the user's device. This method
  /// needs the READ_EXTERNAL_STORAGE permission on Android Oreo & above.
  ///
  /// (JPG converted Uint8List from Bitmap)
  static Future<Uint8List> get getWallpaper async {
    debugPrint(
        "[LauncherHelper] External Storage Access permission might be needed for Android Oreo & above.");
    Uint8List data = await _channel.invokeMethod('getWallpaper');
    return data;
  }

  /// Gets you the brightness of current Wallpaper to determine theme (light or dark). The function returns
  /// a brightness level between 0 and 255, where 0 = totally black and 255 = totally bright.
  ///
  /// This method needs the READ_EXTERNAL_STORAGE permission on Android Oreo & above.
  static Future<int> getWallpaperBrightness({int skipPixel = 1}) async {
    assert(skipPixel > 0, 'skipPixel should have a value greater than 0');
    debugPrint(
        "[LauncherHelper] External Storage Access permission might be needed for Android Oreo & above.");
    int data = await _channel
        .invokeMethod('getWallpaperBrightness', {'skipPixel': skipPixel});
    return data;
  }

  /// Generates a palette based current Wallpaper to for use in UI colors.
  ///
  /// __Note:__
  /// - This method needs the READ_EXTERNAL_STORAGE permission on Android Oreo & above.
  static Future get palette async {
    PaletteGenerator _palette;
    Uint8List imageData = await getWallpaper;
    _palette = await _getPalette(imageData);
    return _palette;
  }

  static Future<PaletteGenerator> _getPalette(Uint8List imageData) async {
    print('Image data(UIntList): $imageData');
    ui.Codec imageCodec = await ui.instantiateImageCodec(imageData);
    ui.FrameInfo imageFrame = await imageCodec.getNextFrame();
    ui.Image image = imageFrame.image;
    PaletteGenerator palette = await PaletteGenerator.fromImage(image);
    return palette;
  }
}
