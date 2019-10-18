// Copyright 2019 Mushaheed Syed. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// This library provides class [LauncherHelper] for various operations like getting list of installed applications,
/// launching applications using package name, getting phone's wallpaper, etc. Only Android is supported.
/// You can also use [PaletteGenerator] without [LauncherHelper] to extract prominent colors from an image for use as user interface
/// colors.
library launcher_helper;

export 'src/_launcher_helper.dart';
export 'src/palette_generator.dart';
export 'src/apps_info.dart';
