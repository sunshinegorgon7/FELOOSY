package com.feloosy.app

import android.content.Context
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Native counterpart of the Dart `DevLog`. Writes SMS-pipeline lifecycle events
 * to the same daily-rotating file under `context.filesDir/logs`, but only for
 * the dev flavor (package id ends with ".dev"). No-op in prod so it never
 * touches disk for real users.
 */
object DevLog {
    private const val DIR = "logs"
    private const val PREFIX = "sms-"

    fun log(context: Context, tag: String, message: String) {
        if (!context.packageName.endsWith(".dev")) return
        try {
            val dir = File(context.filesDir, DIR)
            if (!dir.exists()) dir.mkdirs()
            val day = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            val ts = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US).format(Date())
            File(dir, "$PREFIX$day.log").appendText("$ts | $tag | $message\n")
        } catch (_: Exception) {
            // Diagnostics must never affect app behaviour.
        }
    }
}
