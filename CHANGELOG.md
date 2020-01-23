# Changelog

## 0.3.0

- Introduced more methods to check if app with package-name is disabled or if it exists.
- Changed [Applications] to [ApplicationCollection].
- Added a method to update versionCode and versionName for an app as it changes on updates.
- Removed inaccurate methods for brightness calculations.

## 0.2.0+1

- Improved package health
- Documentation fixes

## 0.2.0

- Added palette generator, no need to add `palette_generator` as a dependency in projects.
- Can generate Color palette to use in user interface and theming from wallpapers.
- Can generate color palettes from an application icon or image.
- Provided [Applications] to better use information from appinfo.
- Calculate luminance/brightness of wallpaper or an image. Also has methods to
determine brightness of wallpaper (or any other image) using dominant colors.

## 0.1.1

- Fetching Wallpaper now works with External Storage access permission
- Has a method to calculate brightness of image using platform code
- Added method to generate color palette from wallpaper
- Changed License format

## 0.1.0+1

Modified README.md, added a note when fetching wallpapers (to use with external storage access permission)

## 0.1.0

Constructed files from previous project with Androidx support with Kotlin

### What works

- Getting Application List
- Launching Apps
- Getting App icons

### What doesn't work

- Fetching wallpaper
- Setting Wallpaper
- Getting Live wallpaper
- Setting Live wallpaper
