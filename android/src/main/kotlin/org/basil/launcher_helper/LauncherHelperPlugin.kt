// / MIT License
// / Copyright (c) 2019 Syed Mushaheed
// / Permission is hereby granted, free of charge, to any person obtaining a copy of this
// / software and associated documentation files (the "Software"), to deal in the
// / Software without restriction, including without limitation the rights to use, copy,
// / modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// / and to permit persons to whom the Software is furnished to do so, subject to the
// / following conditions:
// /
// / The above copyright notice and this permission notice shall be included in all copies
// / or substantial portions of the Software.
// /
// / THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// / EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// / OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// / NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
// / ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// / OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// / OTHER DEALINGS IN THE SOFTWARE.

// / Modifications Copyright 2019 Mushaheed Syed
// / Copyright 2017 Ashraff Hathibelagal
// / Licensed under the Apache License, Version 2.0 (the "License");
// / you may not use this file except in compliance with the License.
// / You may obtain a copy of the License at
// /     http://www.apache.org/licenses/LICENSE-2.0
// / Unless required by applicable law or agreed to in writing, software
// / distributed under the License is distributed on an "AS IS" BASIS,
// / WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// / See the License for the specific language governing permissions and
// / limitations under the License.

package org.basil.launcher_helper

import android.app.WallpaperManager
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.ByteArrayOutputStream
import java.util.ArrayList
import java.util.HashMap

class LauncherHelperPlugin(registrar: Registrar) : MethodCallHandler {

    private var wallpaperData: ByteArray? = null
    private val registrar: PluginRegistry.Registrar

    init {
        this.registrar = registrar
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "launcher_helper")
            channel.setMethodCallHandler(LauncherHelperPlugin(registrar))
        }

        fun convertToBytes(image: Bitmap, compressFormat: Bitmap.CompressFormat, quality: Int): ByteArray {
            val byteArrayOS = ByteArrayOutputStream()
            image.compress(compressFormat, quality, byteArrayOS)
            return byteArrayOS.toByteArray()
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        // if (call.method == "getAllApps") {
        //     getAllApps(result)
        // } else if (call.method == "launchApp") {
        //     launchApp(call.argument<String>("packageName").toString())
        // } else if (call.method == "getWallpaper") {
        //     getWallpaper(result)
        // } else if (call.method == "getWallpaperBrightness") {
        //     // call.argument<Int>("skipPixel").toInt()
        //     var skipPixel = call.argument<Int>("skipPixel")!!.toInt()
        //     getWallpaperBrightness(result, skipPixel)
        // } else {
        //     result.notImplemented()
        // }
        when (call.method) {
            "getAllApps" -> getAllApps(result)
            "launchApp" -> launchApp(call.argument<String>("packageName").toString())
            "getWallpaper" -> getWallpaper(result)
            "getWallpaperBrightness" -> getWallpaperBrightness(result, call.argument<Int>("skipPixel")!!.toInt())
            "getBrightnessFrom" -> getBrightnessFrom(result, call.argument<ByteArray?>("imageData"), call.argument<Int>("skipPixel")!!.toInt())
            else -> result.notImplemented()
        }
    }

    private fun getWallpaper(result: MethodChannel.Result) {
        if (wallpaperData != null) {
            result.success(wallpaperData)
            return
        }

        val wallpaperManager = WallpaperManager.getInstance(registrar.context())
        val wallpaperDrawable = wallpaperManager.drawable
        if (wallpaperDrawable is BitmapDrawable) {
            wallpaperData = convertToBytes(wallpaperDrawable.bitmap,
                    Bitmap.CompressFormat.JPEG, 100)
            result.success(wallpaperData)
        }
    }

    private fun getWallpaperBrightness(result: MethodChannel.Result, skipPixel: Int) {
        val wallpaperManager = WallpaperManager.getInstance(registrar.context())
        val wallpaperDrawable = wallpaperManager.drawable
        if (wallpaperDrawable is BitmapDrawable) {
            val brightness = calculateBrightness(wallpaperDrawable.bitmap, skipPixel)
            result.success(brightness)
        }
    }

    private fun getBrightnessFrom(result: MethodChannel.Result, image: ByteArray?, skipPixel: Int) {
        // Convert ByteArray to bitmap
        var bitmap: Bitmap = BitmapFactory.decodeByteArray(image, 0, image!!.size)
        val brightness = calculateBrightness(bitmap, skipPixel)
        result.success(brightness)
    }

    // Returns the brightness for an image
    private fun calculateBrightness(image: Bitmap, skipPixels: Int): Int {
        var r = 0; var g = 0; var b = 0; var n = 0
        val height = image.height; val width = image.width
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
        return (r + b + g) / (n * 3)
    }

    private fun launchApp(packageName: String) {
        val i = registrar.context().getPackageManager().getLaunchIntentForPackage(packageName)
        if (i != null)
            registrar.context().startActivity(i)
    }

    private fun getBitmapFromDrawable(drawable: Drawable): Bitmap {
        val bmp = Bitmap.createBitmap(drawable.intrinsicWidth, drawable.intrinsicHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bmp
    }

    private fun getAllApps(result: MethodChannel.Result) {

        val intent = Intent(Intent.ACTION_MAIN, null)
        intent.addCategory(Intent.CATEGORY_LAUNCHER)

        val manager = registrar.context().getPackageManager()
        val resList = manager.queryIntentActivities(intent, 0)

        val _output = ArrayList<Map<String, Any>>()

        for (resInfo in resList) {
            try {
                val app = manager.getApplicationInfo(
                        resInfo.activityInfo.packageName, PackageManager.GET_META_DATA)
                if (manager.getLaunchIntentForPackage(app.packageName) != null) {

                    val iconData = convertToBytes(getBitmapFromDrawable(app.loadIcon(manager)),
                            Bitmap.CompressFormat.PNG, 100)

                    val current = HashMap<String, Any>()
                    current["label"] = app.loadLabel(manager).toString()
                    current["icon"] = iconData
                    current["package"] = app.packageName
                    _output.add(current)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        result.success(_output)
    }
}

