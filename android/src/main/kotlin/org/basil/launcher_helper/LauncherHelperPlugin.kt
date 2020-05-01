// MIT License
// Copyright (c) 2019 Syed Mushaheed
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the "Software"), to deal in the
// Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies
// or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
// ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

package org.basil.launcher_helper

import android.app.Activity
import android.app.WallpaperManager
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.graphics.drawable.VectorDrawable
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.graphics.drawable.DrawableCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.ByteArrayOutputStream
import java.util.*

/** LauncherHelper plugin */
class LauncherHelperPlugin(registrar: Registrar, private val activity: Activity) : MethodCallHandler {

    private var wallpaperData: ByteArray? = null
    private val registrar: Registrar

    init {
        this.registrar = registrar
    }

    companion object {
        /** Plugin registration */
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "launcher_helper")
            channel.setMethodCallHandler(LauncherHelperPlugin(registrar, registrar.activity()))
        }

        fun convertToBytes(image: Bitmap, compressFormat: Bitmap.CompressFormat, quality: Int): ByteArray {
            val byteArrayOS = ByteArrayOutputStream()
            image.compress(compressFormat, quality, byteArrayOS)
            return byteArrayOS.toByteArray()
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getAllApps" -> getAllApps(result, call.argument<Boolean>("requestAdaptableIcons") as Boolean)
            "doesAppExist" -> doesAppExist(call.argument<String>("packageName").toString(), result)
            "getApplicationInfo" -> getApplicationInfo(call.argument<String>("packageName").toString(), call.argument<Boolean>("requestAdaptableIcons") as Boolean, result)
            "launchApp" -> launchApp(call.argument<String>("packageName").toString())
            "getWallpaper" -> getWallpaper(result)
            "getBrightnessFrom" -> getBrightnessFrom(result, call.argument<ByteArray?>("imageData"), call.argument<Int>("skipPixel")!!.toInt())
            "getIconOfPackage" -> getIconOfPackage(call.argument<String>("packageName").toString(), call.argument<Boolean>("requestAdaptableIcons") as Boolean, result)
            "isAppEnabled" -> isAppEnabled(call.argument<String>("packageName").toString(), result)
            "getNewOrUpdated" -> getNewOrUpdated(call.argument<List<Map<String, *>>>("packageList") as List<Map<String, *>>, result)
            else -> result.notImplemented()
        }
    }

    private fun getNewOrUpdated(packageList: List<Map<String, *>>, result: Result) {
        TODO("Not yet implemented")
        // packageList has packages in format
        //        {
        //            'packageName': app.packageName,
        //            'versionName': app.versionName,
        //            'versionCode': app.versionCode,
        //        }
        // Reply should be a List with information in format
        //        {
        //            'packageName': app.packageName,
        //            'versionName': app.versionName,
        //            'versionCode': app.versionCode,
        //            'label': app.label,
        //            'icon': app.iconData,
        //        }
        // or the below format if app is not found
        //        {
        //            'packageName': app.packageName,
        //            'shouldRemove': app.shouldRemove,
        //        }
    }

    /** Provides device wallpaper through [MethodChannel]. Needs External read/write permission on some devices to work.
     */
    private fun getWallpaper(result: Result) {
        if (this.wallpaperData != null) {
            result.success(this.wallpaperData)
            return
        }

        val wallpaperManager = WallpaperManager.getInstance(registrar.context())
        val wallpaperDrawable = wallpaperManager.drawable
        if (wallpaperDrawable is BitmapDrawable) {
            this.wallpaperData = convertToBytes(wallpaperDrawable.bitmap,
                    Bitmap.CompressFormat.JPEG, 100)
            result.success(this.wallpaperData)
        }
    }

    /** Returns brightness of an image provided as image: ByteArray?
     */
    private fun getBrightnessFrom(result: Result, image: ByteArray?, skipPixel: Int) {
        // Convert ByteArray to bitmap
        val bitmap: Bitmap = BitmapFactory.decodeByteArray(image, 0, image!!.size)
        val brightness = calculateBrightness(bitmap, skipPixel)
        result.success(brightness)
    }

    /** Calculates the brightness of an image: Bitmap.
     */
    private fun calculateBrightness(image: Bitmap, skipPixels: Int): Int {
        var r = 0
        var g = 0
        var b = 0
        var n = 0
        val height = image.height
        print("Height: $height")
        val width = image.width
        print("Width: $width")
        val pixels = IntArray(width * height)
        image.getPixels(pixels, 0, width, 0, 0, width, height)
        var i = 0
        while (i < pixels.size) {
            val color = pixels[i]
            r += Color.red(color)
            g += Color.green(color)
            b += Color.blue(color)
            n++
            i += skipPixels
        }
//        print("r g b = $r $b $g; total = $n")
        return (r + b + g) / (n * 3)
    }

    /** Check if application is enabled.
     */
    private fun isAppEnabled(packageName: String, result: Result) {
        var isEnabled = false
        try {
            val appInfo = registrar.context().packageManager.getApplicationInfo(packageName, 0)
            if (appInfo != null) {
                isEnabled = appInfo.enabled
            }
        } catch (error: PackageManager.NameNotFoundException) {
            result.error("No_Such_App_Found", error.message + " " + packageName, error)
            return
        }
        result.success(isEnabled)
    }

    /** Method launches app with package-name
     */
    private fun launchApp(packageName: String) {
        val i = registrar.context().getPackageManager().getLaunchIntentForPackage(packageName)
        if (i != null)
            registrar.context().startActivity(i)
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun getBitmapFromVectorDrawable(drawable: VectorDrawable): Bitmap {
        var vDrawable: VectorDrawable = drawable
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            vDrawable = DrawableCompat.wrap(vDrawable).mutate() as VectorDrawable
        }
        val bitmap = Bitmap.createBitmap(vDrawable.intrinsicWidth,
                vDrawable.intrinsicHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        vDrawable.setBounds(0, 0, canvas.width, canvas.height)
        vDrawable.draw(canvas)
        return bitmap
    }

    private fun getBitmapFromDrawable(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable) {
            if (drawable.bitmap != null) {
                return drawable.bitmap
            }
        }
        val bitmap: Bitmap = if (drawable.intrinsicWidth <= 0 || drawable.intrinsicHeight <= 0) {
            Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888) // Single color bitmap will be created of 1x1 pixel
        } else {
            Bitmap.createBitmap(drawable.intrinsicWidth, drawable.intrinsicHeight, Bitmap.Config.ARGB_8888)
        }
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }

    private fun getApplicationInfo(packageName: String, requestAdaptableIcons: Boolean, result: Result) {
        val pkManager = activity.applicationContext.packageManager
        try {
            val map = getApplicationMap(packageName, requestAdaptableIcons, pkManager)
            result.success(map)
        } catch (e: PackageManager.NameNotFoundException) {
            result.error("No_Such_App_Found", "App with $packageName does not exist", null)
        }
    }

    /** Method gives complete information on application. Function gives app information if app exists.
    Returns error with code "No_Such_App_Found" when application with provided package does not exist */
    private fun getApplicationMap(packageName: String, requestAdaptableIcons: Boolean, pkManager: PackageManager): HashMap<String, Any> {
        val map = HashMap<String, Any>()
        val pkInfo: PackageInfo = pkManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
        val iconMap: HashMap<String, ByteArray> = getIcon(pkInfo.applicationInfo.loadIcon(pkManager), requestAdaptableIcons)
        map["label"] = pkInfo.applicationInfo.loadLabel(registrar.context().packageManager).toString()
        map["packageName"] = pkInfo.packageName
        map["versionCode"] = pkInfo.versionCode.toString()
        map["versionName"] = pkInfo.versionName.toString()
        map["icon"] = iconMap
        return map
    }

    /** Method gives complete information on application. Function gives app information if app exists.
    Returns error with code "No_Such_App_Found" when application with provided package does not exist */
    private fun getApplicationMap(packageName: String, requestAdaptableIcons: Boolean): HashMap<String, Any> {
        val map = HashMap<String, Any>()
        val pkManager = activity.applicationContext.packageManager
        return getApplicationMap(packageName, requestAdaptableIcons, pkManager)
    }

    private fun getIconOfPackage(packageName: String, requestAdaptableIcons: Boolean, result: Result) {
        val pkManager = activity.applicationContext.packageManager
        try {
            val drawable: Drawable = pkManager.getApplicationIcon(packageName)
            val icon: HashMap<String, ByteArray> = getIcon(drawable, requestAdaptableIcons)
            result.success(icon)
        } catch (e: PackageManager.NameNotFoundException) {
            result.error("No_Such_App_Found", "App with $packageName does not exist", null)
        }
    }

    private fun getIcon(icon: Drawable, requestAdaptableIcons: Boolean): HashMap<String, ByteArray> {
        if (!requestAdaptableIcons) {
            return getRegularIcon(icon)
        }
        return when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O -> {
                getIconForAndroid26(icon)
            }
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP -> {
                getIconForAndroid21(icon)
            }
            else -> {
                getRegularIcon(icon)
            }
        }
    }

    /** Platform method to obtain icon of package for Android.
     *  Returns HashMap as {'iconData': <ByteArray>}
     */
    private fun getRegularIcon(icon: Drawable): HashMap<String, ByteArray> {
        val map = HashMap<String, ByteArray>()
        val iconData: ByteArray = convertToBytes(getBitmapFromDrawable(icon),
                Bitmap.CompressFormat.PNG, 100)
        map["iconData"] = iconData
        return map
    }

    /** Platform method to obtain adaptive-icon of package for Android build version 26 & above.
     * Returns HashMap as {'iconData': <ByteArray>} or {'iconForegroundData':<ByteArray>,'iconBackgroundData':<ByteArray>}
     */
    @RequiresApi(Build.VERSION_CODES.O)
    private fun getIconForAndroid26(icon: Drawable): HashMap<String, ByteArray> {
        val iconMap = HashMap<String, ByteArray>()
        if (icon is BitmapDrawable) {
            iconMap["iconData"] = convertToBytes(getBitmapFromDrawable(icon), Bitmap.CompressFormat.PNG, 100)
            return iconMap
        } else if (icon is VectorDrawable) {
            iconMap["iconData"] = convertToBytes(getBitmapFromDrawable(icon)
                    , Bitmap.CompressFormat.PNG, 100)
            return iconMap
        }
        val backgroundDr: Drawable = (icon as AdaptiveIconDrawable).background
        val foregroundDr: Drawable = (icon as AdaptiveIconDrawable).foreground
        val iconForegroundData: ByteArray
        val iconBackgroundData: ByteArray
        iconForegroundData = convertToBytes(getBitmapFromDrawable(foregroundDr),
                Bitmap.CompressFormat.PNG, 100)
        iconBackgroundData = convertToBytes(getBitmapFromDrawable(backgroundDr),
                Bitmap.CompressFormat.PNG, 100)
        iconMap["iconForegroundData"] = iconForegroundData
        iconMap["iconBackgroundData"] = iconBackgroundData
        return iconMap
    }

    /** Platform method to obtain adaptive-icon of package for Android build version 26 & above.
     * Returns HashMap as {'iconData': <ByteArray>}
     */
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun getIconForAndroid21(icon: Drawable): HashMap<String, ByteArray> {
        val iconMap = HashMap<String, ByteArray>()
        iconMap["iconData"] = if (icon is VectorDrawable) {
            convertToBytes(getBitmapFromVectorDrawable(icon), Bitmap.CompressFormat.PNG, 100)
        } else {
            convertToBytes(getBitmapFromDrawable(icon), Bitmap.CompressFormat.PNG, 100)
        }
        return iconMap
    }

    /** Checks if application exists/available. Function returns true if app exists
    else returns false when application with provided package does not exist */
    private fun doesAppExist(packageName: String, result: Result) {
        val pkManager = activity.applicationContext.packageManager
        val pkInfo: PackageInfo?
        pkInfo = try {
            pkManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
        } catch (e: PackageManager.NameNotFoundException) {
            null
        }
        if (pkInfo != null) {
            result.success(true)
            return
        } else {
            result.success(false)
        }
    }

    /** Get all installed application from [PackageManager] as a map to [MethodChannel]
     */
    private fun getAllApps(result: Result, requestAdaptableIcons: Boolean) {
        val intent = Intent(Intent.ACTION_MAIN, null)
        intent.addCategory(Intent.CATEGORY_LAUNCHER)
        val manager = registrar.context().packageManager
        val resList = manager.queryIntentActivities(intent, 0)
        val outputMap = ArrayList<Map<String, Any>>()
        for (resInfo in resList) {
            try {
                val app = manager.getApplicationInfo(
                        resInfo.activityInfo.packageName, PackageManager.GET_META_DATA)
                if (manager.getLaunchIntentForPackage(app.packageName) != null) {
                    val current = getApplicationMap(app.packageName, requestAdaptableIcons, manager)
                    outputMap.add(current)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        result.success(outputMap)
    }
}
