/// Copyright 2019 Mushaheed Syed. All rights reserved.
///
/// Use of this source code is governed by a MIT license that can be
/// found in the LICENSE file.
///
/// --------------------------------------------------------------------------------
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

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'apps_info.dart';
import 'palette_generator.dart';

/// # LauncherHelper
///
/// A class to help reduce work when creating a launcher.
///
/// ## Available methods/getters:
///
/// - Use [getApplications] to get list of apps installed.
/// - [launchApp] can launch apps by providing their package name.
/// - [getWallpaper] returns device wallpaper as [Uint8List].
/// - [getWallpaperBrightness] returns brightness of wallpaper.
/// - [getLuminance] calculates approximate luminance/brightness of an image.
/// - [getBrightnessFrom] calculates brightness of an image from every pixel.
/// - [wallpaperPalette] generated color palettes of wallpaper using [PaletteGenerator].
class LauncherHelper {
  static const MethodChannel _channel = const MethodChannel('launcher_helper');

  /// Returns a list of apps installed on the user's device
  @deprecated
  static Future<List> get getApps async {
    var data = await _channel.invokeMethod('getAllApps');
    return data;
  }

  /// Returns an [Applications] object with [AppInfo] of apps installed on the user's device.
  static Future<Applications> get getApplications async {
    List data = await _channel.invokeMethod('getAllApps');
    return Applications(data);
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

  /// This gets the current wallpaper on the user's device. This method
  /// needs the READ_EXTERNAL_STORAGE permission on Android Oreo & above.
  static Future<Uint8List> get getWallpaper async {
    debugPrint(
        "[LauncherHelper] External Storage Access permission might be needed for Android Oreo & above.");
    Uint8List data = await _channel.invokeMethod('getWallpaper');
    return data;
  }

  /// This gets the brightness of current Wallpaper to determine theme (light or dark). The function returns
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

  /// This asynchronously calculates luminance for an image.
  ///
  /// The function returns a [double] representing `luminance` from image data of `Uint8List` type.
  /// `luminance` with a brightness value between 0 for darkest and 1 for lightest.
  /// It represents the relative luminance of the color.
  ///
  /// The function uses list of `Color` generated from [PaletteGenerator] for calculations.
  ///
  /// **Note:**
  /// - The values this function returns is computationally very expensive to calculate.
  /// Consider using higher values for [skip] (which should not be more than the number of dominant colors in image) or
  /// calculating luminance of the most dominant color generated from [PaletteGenerator] for an
  /// image (use `computeLuminance()` of `Color`).
  /// - For better accuracy of brightness/luminance, use [getBrightnessFrom] or[getWallpaperBrightness].
  static Future<double> getLuminance(
      {Uint8List imageData, int skip = 1}) async {
    int index = 0, n = 0;
    double luminance;
    PaletteGenerator palette = await PaletteGenerator.fromUint8List(imageData);
    double totalLum = 0;
    while (index < palette.colors.length) {
      totalLum += palette.colors.toList()[index].computeLuminance();
      n += 1;
      index += skip;
    }
    print('[getLuminance] Colors counted for calculations: $n');
    luminance = totalLum / n;
    return luminance;
  }

  /// This gets the brightness of any image (image as `Uint8List`). The function returns
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
    int data = await _channel.invokeMethod(
        'getBrightnessFrom', {'skipPixel': skipPixel, "imageData": imageData});
    return data;
  }

  /// It generates a palette based current Wallpaper to for use in UI colors.
  ///
  /// __Note:__
  /// - This method needs the READ_EXTERNAL_STORAGE permission on Android Oreo & above.
  static Future get wallpaperPalette async {
    PaletteGenerator _palette;
    Uint8List imageData = await getWallpaper;
    _palette = await PaletteGenerator.fromUint8List(imageData);
    return _palette;
  }
}
