package org.basil.launcher_helper

import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import androidx.annotation.RequiresApi

/** AppIconHelper helps to get adaptive icons for packages  */
class AdaptiveIconHelper {
    private fun drawableToBitmap(drawable: Drawable): Bitmap? {
        var bitmap: Bitmap? = null
        if (drawable is BitmapDrawable) {
            if (drawable.bitmap != null) {
                return drawable.bitmap
            }
        }
        bitmap = if (drawable.intrinsicWidth <= 0 || drawable.intrinsicHeight <= 0) {
            Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888) // Single color bitmap will be created of 1x1 pixel
        } else {
            Bitmap.createBitmap(drawable.intrinsicWidth, drawable.intrinsicHeight, Bitmap.Config.ARGB_8888)
        }
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }
    @RequiresApi(Build.VERSION_CODES.O)
    fun getAdaptiveIcon(packageManager: PackageManager, packageName: String?): Array<Bitmap?>? {
        val adaptiveIconLayer: Array<Bitmap?> = arrayOfNulls<Bitmap>(2)
        try {
            val drawable: Drawable = packageManager.getApplicationIcon(packageName)
            if (drawable is BitmapDrawable) {
                adaptiveIconLayer[0] = (drawable as BitmapDrawable).getBitmap()
                return adaptiveIconLayer
            } else if (drawable is AdaptiveIconDrawable) {
                val backgroundDr: Drawable = (drawable as AdaptiveIconDrawable).getBackground()
                val foregroundDr: Drawable = (drawable as AdaptiveIconDrawable).getForeground()
                val bgBitmap: Bitmap? = drawableToBitmap(backgroundDr)
                val fgBitmap: Bitmap? = drawableToBitmap(foregroundDr)
                adaptiveIconLayer[1] = bgBitmap
                adaptiveIconLayer[0] = fgBitmap
                return adaptiveIconLayer
            }
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
        }
        return null
    }
    @RequiresApi(Build.VERSION_CODES.O)
    fun getAdaptiveIconForeground(packageManager: PackageManager, packageName: String?): Bitmap? {
        val adaptiveIconLayer: Array<Bitmap?> = arrayOfNulls<Bitmap>(2)
        try {
            val drawable: Drawable = packageManager.getApplicationIcon(packageName)
            if (drawable is BitmapDrawable) {
                return (drawable as BitmapDrawable).getBitmap()
            } else if (drawable is AdaptiveIconDrawable) {
                val foregroundDr: Drawable = (drawable as AdaptiveIconDrawable).getForeground()
                val fgBitmap: Bitmap? = drawableToBitmap(foregroundDr)
                return fgBitmap
            }
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
        }
        return null
    }
    @RequiresApi(Build.VERSION_CODES.O)
    fun getAdaptiveIconBackground(packageManager: PackageManager, packageName: String?): Bitmap? {
        val adaptiveIconLayer: Array<Bitmap?> = arrayOfNulls<Bitmap>(2)
        try {
            val drawable: Drawable = packageManager.getApplicationIcon(packageName)
            if (drawable is BitmapDrawable) {
                return (drawable as BitmapDrawable).getBitmap()
            } else if (drawable is AdaptiveIconDrawable) {
                val backgroundDr: Drawable = (drawable as AdaptiveIconDrawable).getBackground()
                val bgBitmap: Bitmap? = drawableToBitmap(backgroundDr)
                return bgBitmap
            }
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
        }
        return null
    }
}