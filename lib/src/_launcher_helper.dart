/// Copyright 2019 Mushaheed Syed. All rights reserved.
///
/// Use of this source code is governed by a MIT license that can be
/// found in the LICENSE file.
/// ---------------------------------------------------------------------------------------
/// Copyright 2017 Ashraff Hathibelagal
/// 
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
import 'palette_generator.dart';

class LauncherHelper {
  static const MethodChannel _channel = const MethodChannel('launcher_helper');

  /// Returns a list of apps installed on the user's device
  static Future<List> get getApps async {
    var data = await _channel.invokeMethod('getAllApps');
    return data;
  }

  /// Launches an app using its package name
  static Future<bool> launchApp(String packageName) async {
    try {
      await _channel.invokeMethod("launchApp", {"packageName": packageName});
      return true;
    } catch (e) {
      debugPrint('[LauncherHelper:launchApp] Failed because: $e');
      return false;
    }
  }

  /// Gets you the current wallpaper on the user's device. This method
  /// needs the READ_EXTERNAL_STORAGE permission on Android Oreo & above.
  static Future<Uint8List> get getWallpaper async {
    debugPrint(
        "[LauncherHelper] External Storage Access permission might be needed for Android Oreo & above.");
    Uint8List data = await _channel.invokeMethod('getWallpaper');
    return data;
  }

  /// Gets you the brightness of current Wallpaper to determine theme (light or dark). The function returns
  /// a brightness level between 0 and 255, where 0 = totally black and 255 = totally bright.
  ///
  /// `skipPixel` parameter refers to number of pixels to skip while calculating Wallpaper's brightness.
  /// `skipPixel` defaults to 1 (every pixel is counted) and can't be less than 1.
  ///
  /// __Note:__
  /// - This method needs the READ_EXTERNAL_STORAGE permission on Android Oreo & above.
  static Future<int> getWallpaperBrightness({int skipPixel = 1}) async {
    assert(skipPixel > 0, 'skipPixel should have a value greater than 0');
    debugPrint(
        "[LauncherHelper] External Storage Access permission might be needed for Android Oreo & above.");
    int data = await _channel
        .invokeMethod('getWallpaperBrightness', {'skipPixel': skipPixel});
    return data;
  }

  /// Gets you the brightness of any image (as `Uint8List`). The function returns
  /// a brightness level between 0 and 255, where 0 = totally black and 255 = totally bright.
  ///
  /// `skipPixel` parameter refers to number of pixels to skip while calculating Wallpaper's brightness.
  /// `skipPixel` defaults to 1 (every pixel is counted) and can't be less than 1.
  ///
  /// __Note:__
  /// - This method needs the READ_EXTERNAL_STORAGE permission on Android Oreo & above.
  static getBrightnessFrom(Uint8List imageData, {int skipPixel = 1}) async {
    assert(skipPixel > 0, 'skipPixel should have a value greater than 0');
    assert(imageData != null, 'imageData should not be null');
    debugPrint(
        "[LauncherHelper] External Storage Access permission might be needed for Android Oreo & above.");
    int data = await _channel.invokeMethod(
        'getBrightnessFrom', {'skipPixel': skipPixel, "imageData": imageData});
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
