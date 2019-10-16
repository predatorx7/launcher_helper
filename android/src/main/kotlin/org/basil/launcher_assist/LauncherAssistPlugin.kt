package org.basil.launcher_assist

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.PluginRegistry

import android.app.WallpaperManager
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.Log

import org.json.JSONArray
import org.json.JSONException

import java.io.ByteArrayOutputStream
import java.util.ArrayList
import java.util.HashMap



class LauncherAssistPlugin(registrar: Registrar): MethodCallHandler {

  private var wallpaperData: ByteArray? = null
  private val registrar: PluginRegistry.Registrar

  init {
    this.registrar = registrar
  }

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "launcher_assist")
      channel.setMethodCallHandler(LauncherAssistPlugin())
    }

    fun convertToBytes(image: Bitmap, compressFormat: Bitmap.CompressFormat, quality: Int): ByteArray {
      val byteArrayOS = ByteArrayOutputStream()
      image.compress(compressFormat, quality, byteArrayOS)
      return byteArrayOS.toByteArray()
  }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method =="getAllApps") {
      getAllApps(result)
    } else  if (call.method =="launchApp") {
      launchApp(call.argument("packageName").toString())
    } else  if (call.method == "getWallpaper") {
      getWallpaper(result)
    } else  {
      result.notImplemented()
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
