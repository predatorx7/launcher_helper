// Copyright 2019 Mushaheed Syed. All rights reserved.

// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'application_collection.dart';
import 'palette_generator.dart';

/// # LauncherHelper
///
/// A class to help reduce work when creating a launcher.
///
/// ## Available methods/getters:
///
/// - Use [getApplications] to get list of apps installed.
/// - [getApplicationInfo] to get [Application] for provided `packageName`.
/// - [doesApplicationExist] to check if application with provided `packageName` exists.
/// - [getApplicationIcon] returns app icon for provided `packageName`.
/// - [isApplicationEnabled] returns `true` if application is enabled else returns `false`.
/// - [launchApp] can launch apps by providing their package name.
/// - [getWallpaper] returns device wallpaper as [Uint8List].
/// - [calculateBrightness] calculates brightness of an image from every pixel.
/// - [generatePalette] generates color palettes from `Uint8List` image data using [PaletteGenerator].
class LauncherHelper {
  static const MethodChannel _channel = const MethodChannel('launcher_helper');

  /// Returns an instance of [ApplicationCollection] with installed packages as [Application]s from this device.
  ///
  /// If [requestAdaptableIcons] is true, then this will get adaptable version of icons on supported
  /// platforms if available. [requestAdaptableIcons] defaults to true.
  /// Set [requestAdaptableIcons] to false to only obtain `RegularAppIcon`.
  ///
  /// This is an expensive operation. Use [getNewOrUpdated] for updating any changes in [ApplicationCollection]
  static Future<ApplicationCollection> getApplications(
      [bool requestAdaptableIcons = true]) async {
    Map<String, bool> _arguments = {
      'requestAdaptableIcons': requestAdaptableIcons ?? true
    };
    List data = await _channel.invokeMethod('getAllApps', _arguments);
    return await ApplicationCollection.fromList(data);
  }

  /// Returns [ApplicationCollection] of [Application]s installed on this device.
  ///
  /// This is an expensive operation. Use [getNewOrUpdated] for updating any changes in [ApplicationCollection]
  ///
  /// This is now deprecated. Use [getApplications] instead of this method.
  @Deprecated('Use [getApplications] instead.')
  static Future<ApplicationCollection> get applicationCollection async {
    return await getApplications();
  }

  /// Returns [Application] matching with provided [packageName] installed on this device. Throws "No_Such_App_Found" exception if app doesn't exists.
  static Future<Application> getApplicationInfo(String packageName,
      [bool requestAdaptableIcons = true]) async {
    assert(packageName != null);
    Map<String, dynamic> _arguments = {
      'packageName': packageName,
      'requestAdaptableIcons': requestAdaptableIcons ?? true
    };
    Map data = await _channel.invokeMethod('getApplicationInfo', _arguments);
    return await Application.create(data);
  }

  /// Updates & returns [ApplicationCollection] with new or updated packages.
  static Future<ApplicationCollection> getNewOrUpdated(
      ApplicationCollection applications,
      [bool requestAdaptableIcons = true]) async {
    List<Map<String, dynamic>> packageList = [];
    for (Application app in applications) {
      packageList.add({
        'packageName': app.packageName,
        'versionName': app.versionName,
        'versionCode': app.versionCode,
      });
    }
    Map<String, dynamic> _arguments = {
      "packageList": packageList,
      'requestAdaptableIcons': requestAdaptableIcons ?? true
    };
    List newOrUpdatedPackages =
        await _channel.invokeMethod('getNewOrUpdated', _arguments);
    applications.update(newOrUpdatedPackages);
    await applications.update(newOrUpdatedPackages);
    return applications;
  }

  /// Returns true if application exists else false if it doesn't exist. Throws "No_Such_App_Found" exception if app doesn't exists.
  static Future<bool> doesApplicationExist(String packageName) async {
    bool data = await _channel
        .invokeMethod('doesAppExist', {"packageName": packageName});
    return data;
  }

  /// Returns true if application is enabled else false if it isn't enabled. Throws "No_Such_App_Found" exception if app doesn't exists.
  static Future<bool> isApplicationEnabled(String packageName) async {
    bool data = await _channel
        .invokeMethod('isAppEnabled', {"packageName": packageName});
    return data;
  }

  /// Returns application icon data in a map. Throws "No_Such_App_Found" exception if app or app-icon doesn't exists for the package.
  /// Result is a Map as
  /// ```
  /// {'iconData':<Uint8List> ?? null, 'iconForegroundData':<Uint8List> ?? null,'iconBackgroundData':<Uint8List> ?? null}
  /// ```
  static Future<Map<String, dynamic>> getApplicationIcon(String packageName,
      [bool requestAdaptableIcons = true]) async {
    assert(packageName != null);
    Map<String, dynamic> _arguments = {
      'packageName': packageName,
      'requestAdaptableIcons': requestAdaptableIcons ?? true
    };
    Map<String, dynamic> data =
        await _channel.invokeMethod('getIconOfPackage', _arguments);
    return data;
  }

  /// Launches an app using its package name.
  static Future<bool> launchApp(String packageName) async {
    try {
      await _channel.invokeMethod("launchApp", {"packageName": packageName});
      return true;
    } catch (e) {
      print('[LauncherHelper:launchApp] Failed because: $e');
      return false;
    }
  }

  /// This gets the current wallpaper on the user's device. This method
  /// needs the READ_EXTERNAL_STORAGE permission on Android Oreo & above.
  static Future<Uint8List> get getWallpaper async {
    print(
        "[LauncherHelper] External Storage Access permission might be needed for Android Oreo & above.");
    Uint8List data = await _channel.invokeMethod('getWallpaper');
    return data;
  }

  /// This gets the brightness of any image (image as `Uint8List`). The function returns
  /// a brightness level between 0 and 255, where 0 = totally black and 255 = totally bright.
  ///
  /// `skipPixel` parameter refers to number of pixels to skip while calculating Wallpaper's brightness.
  /// `skipPixel` defaults to 1 (every pixel is counted) and can't be less than 1.
  ///
  /// __Note:__
  /// - This method needs the READ_EXTERNAL_STORAGE permission on Android Oreo & above.
  /// - This uses platform implementation for calculating brightness.
  static Future<int> calculateBrightness(Uint8List imageData,
      {int skipPixel = 1}) async {
    assert(skipPixel > 0, 'skipPixel should have a value greater than 0');
    assert(imageData != null, 'imageData should not be null');
    int data = await _channel.invokeMethod(
        'getBrightnessFrom', {'skipPixel': skipPixel, "imageData": imageData});
    return data;
  }

  /// It returns a [PaletteGenerator] based on image (preferably wallpaper) to for use in UI colors.
  ///
  /// Same as [PaletteGeneratorUtils.fromUint8List].
  ///
  /// Results might be unexpected if image is completely white or completely black.
  static Future<PaletteGenerator> generatePalette(Uint8List imageData) async {
    PaletteGenerator _palette;
    _palette = await PaletteGeneratorUtils.fromUint8List(imageData);
    return _palette;
  }
}
