package com.feloosy.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.provider.Telephony
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return
        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (messages.isNullOrEmpty()) return
        val body = messages.joinToString("") { it.messageBody ?: "" }
        val sender = messages.firstOrNull()?.originatingAddress ?: ""
        val data = mapOf("body" to body, "sender" to sender)

        SmsSink.push(data, context)

        if (!SmsSink.isActive) {
            processInBackground(context.applicationContext, data)
        }
    }

    private fun processInBackground(appContext: Context, data: Map<String, String>) {
        val pendingResult = goAsync()
        val isDev = appContext.packageName.endsWith(".dev")
        val handler = Handler(Looper.getMainLooper())

        handler.post {
            val loader = FlutterInjector.instance().flutterLoader()
            if (!loader.initialized()) {
                loader.startInitialization(appContext)
            }
            loader.ensureInitializationComplete(appContext, null)

            val engine = FlutterEngine(appContext)
            GeneratedPluginRegistrant.registerWith(engine)

            val channel = MethodChannel(
                engine.dartExecutor.binaryMessenger,
                "com.feloosy/sms_background"
            )

            val payload = HashMap<String, Any>(data).apply {
                put("isDev", isDev)
            }

            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "ready" -> {
                        result.success(null)
                        channel.invokeMethod("sms", payload)
                    }
                    "processed" -> {
                        result.success(null)
                        SmsSink.markProcessed(data, appContext)
                        engine.destroy()
                        pendingResult.finish()
                    }
                    else -> result.notImplemented()
                }
            }

            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(
                    loader.findAppBundlePath(),
                    "package:feloosy/services/sms_background_handler.dart",
                    "smsBackgroundHandler"
                )
            )
        }
    }
}
