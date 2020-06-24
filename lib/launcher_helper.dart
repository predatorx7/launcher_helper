// Copyright 2019 Mushaheed Syed. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// This library provides class [LauncherHelper] for various operations like getting list of installed applications,
/// launching applications using package name, getting phone's wallpaper, etc.
///
/// Only Android is supported.
///
/// The library also provides [PaletteGeneratorUtils] to extract prominent colors from an image for use as user interface
/// colors.
///
// Note: For performance & usage improvements, the Stream APIs will be added
// in [LauncherHelper] class in a later build. (v2 or v1 based on this library's popularity & feedback)
library launcher_helper;

export 'src/palette_generator_utils.dart';
export 'src/applications/application_collection.dart';
export 'src/applications/icon_shape.dart';
export 'src/applications/icon.dart';

// NEW
// export 'src/_launcher_helper.dart';

// OLD
export 'src/_launcher_helper_old.dart';
