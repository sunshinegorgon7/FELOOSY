package com.feloosy.app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.res.Configuration
import android.net.Uri
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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.feloosy/sms_inbox")
            .setMethodCallHandler { call, result ->
                if (call.method != "scan") { result.notImplemented(); return@setMethodCallHandler }
                val from = call.argument<Long>("from") ?: 0L
                val to   = call.argument<Long>("to")   ?: System.currentTimeMillis()
                try {
                    result.success(readSmsInbox(from, to))
                } catch (e: SecurityException) {
                    result.error("PERMISSION_DENIED", "SMS permission denied", null)
                } catch (e: Exception) {
                    result.error("READ_ERROR", e.message, null)
                }
            }
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

    private fun readSmsInbox(from: Long, to: Long): List<Map<String, Any>> {
        val uri = Uri.parse("content://sms/inbox")
        val cursor = contentResolver.query(
            uri,
            arrayOf("body", "address", "date"),
            "date BETWEEN ? AND ?",
            arrayOf(from.toString(), to.toString()),
            "date DESC",
        ) ?: return emptyList()

        val messages = mutableListOf<Map<String, Any>>()
        cursor.use {
            val bodyIdx = it.getColumnIndex("body")
            val addrIdx = it.getColumnIndex("address")
            val dateIdx = it.getColumnIndex("date")
            while (it.moveToNext()) {
                val body = if (bodyIdx >= 0) it.getString(bodyIdx) else null
                if (body.isNullOrBlank()) continue
                messages.add(
                    mapOf(
                        "body"   to body,
                        "sender" to (if (addrIdx >= 0) it.getString(addrIdx) ?: "" else ""),
                        "date"   to (if (dateIdx >= 0) it.getLong(dateIdx) else from),
                    ),
                )
            }
        }
        return messages
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
