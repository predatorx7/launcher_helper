# Changelog

## Upcoming

- API improvements
- performance improvements
- Icon-pack support
- Visual effects on gesture in Adaptive icons

# 0.4.6

- Documentation updates
- API stability
- Adaptive icon support

## 0.4.5-dev+2005

- Documentation updates update changes in ApplicationCollection & Wallpaper (tested)
- API stability

## 0.4.4-dev+2005

- Method to update changes ApplicationCollection from installed applications (Untested)
- Documentation updates
- API internal improvements
- version semantic now will follow:
  - `version + hotfixe.n` &nbsp;for stable builds.
  - `version - pre-release + yymm` &nbsp;for any pre-release builds.

## 0.4.3-dev+202004300253

- API changes
- AppIcon can change shape properly
- AppIcon shape can be changed with AppIconShape
- existing shapes: teardrop, squircle, circular, square
- version semantic now will follow:
  - `version + yyyymmddhhmm` &nbsp;for stable builds.
  - `version - pre-release + yyyymmddhhmm` &nbsp;for any pre-release builds.

## 0.4.0-dev+2

- API changes
- Now [IconLayer] are available in AppIcon
- [IconLayer] also provides Image bytes as Uint8List

## 0.4.0-dev+1

- Getter for Adaptive icons of a package
- changes in ApplicationCollection
- API improvements

## 0.3.1

- Changes in ApplicationCollection & Application

## 0.3.0+1 to 0.3.0+3

- Documentation update

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
