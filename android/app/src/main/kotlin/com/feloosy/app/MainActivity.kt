package com.feloosy.app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.res.Configuration
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.feloosy.app.widget.FeloosyWidgetProvider

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.feloosy/sms")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    SmsSink.register(events)
                }
                override fun onCancel(arguments: Any?) {
                    SmsSink.register(null)
                }
            })
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, "com.feloosy/window")
                    .invokeMethod("focused", null)
            }
        }
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        val manager = AppWidgetManager.getInstance(this)
        val ids = manager.getAppWidgetIds(
            ComponentName(this, FeloosyWidgetProvider::class.java)
        )
        if (ids.isNotEmpty()) {
            val views = FeloosyWidgetProvider.buildViews(this)
            ids.forEach { id -> manager.updateAppWidget(id, views) }
        }
    }
}
