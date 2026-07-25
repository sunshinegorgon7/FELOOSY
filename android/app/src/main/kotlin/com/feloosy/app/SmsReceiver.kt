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
    companion object {
        // Mirrors SmsParserService.isIgnoredSender() in
        // lib/domain/services/sms_parser_service.dart — keep the two in sync.
        //
        // This is a performance pre-filter, not the enforcement point: dropping
        // ads here avoids starting a whole headless Flutter engine for every
        // promotional SMS that arrives while the app is closed. Dart re-checks
        // on both paths, so a divergence here can only cost battery, never let
        // an ad through.
        //
        // Anchored and dash-required so ADCB / ADIB are not caught.
        private val IGNORED_SENDER = Regex("^AD[-‐‑‒–—]", RegexOption.IGNORE_CASE)
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return
        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (messages.isNullOrEmpty()) return
        val body = messages.joinToString("") { it.messageBody ?: "" }
        val sender = messages.firstOrNull()?.originatingAddress ?: ""

        if (IGNORED_SENDER.containsMatchIn(sender.trim())) {
            DevLog.log(context, "NATIVE", "ignored promotional sender \"$sender\"")
            return
        }

        val data = mapOf("body" to body, "sender" to sender)

        val active = SmsSink.isActive
        DevLog.log(context, "NATIVE",
            "receiver fired, sink active=$active, from=\"$sender\", body=\"${preview(body)}\"")

        SmsSink.push(data, context)

        if (!active) {
            processInBackground(context.applicationContext, data)
        }
    }

    private fun preview(body: String): String =
        if (body.length <= 40) body else body.substring(0, 40) + "…"

    private fun processInBackground(appContext: Context, data: Map<String, String>) {
        val pendingResult = goAsync()
        val isDev = appContext.packageName.endsWith(".dev")
        val handler = Handler(Looper.getMainLooper())

        handler.post {
            DevLog.log(appContext, "NATIVE", "background engine starting")
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
                        DevLog.log(appContext, "NATIVE", "background engine finished")
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
