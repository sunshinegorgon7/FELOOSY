package com.feloosy.app

import android.content.Context
import io.flutter.plugin.common.EventChannel
import org.json.JSONArray
import org.json.JSONObject

object SmsSink {
    private const val PREFS_NAME = "SmsSinkPrefs"
    private const val PREFS_KEY  = "pending_sms"

    private var sink: EventChannel.EventSink? = null
    val isActive: Boolean get() = sink != null

    fun register(sink: EventChannel.EventSink?, context: Context) {
        this.sink = sink
        if (sink == null) return

        // Drain the persisted queue (messages that arrived while no Flutter
        // engine was listening). Clearing after draining guarantees each queued
        // message is delivered to Dart exactly once per app launch.
        val stored = loadPersisted(context)
        if (stored.isNotEmpty()) {
            stored.forEach { sink.success(it) }
            clearPersisted(context)
        }
    }

    fun push(data: Map<String, String>, context: Context) {
        val s = sink
        if (s != null) {
            s.success(data)
        } else {
            // No live listener — persist so the message survives process death
            // and is replayed on next open. The persisted store is the single
            // source of truth; there is no separate in-memory copy, so a message
            // can never be delivered twice from one push.
            appendPersisted(data, context)
        }
    }

    fun markProcessed(data: Map<String, String>, context: Context) {
        removeFromPersisted(data, context)
    }

    private fun removeFromPersisted(data: Map<String, String>, context: Context) {
        val prefs = context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val raw = prefs.getString(PREFS_KEY, null) ?: return
        val array = JSONArray(raw)
        val body = data["body"] ?: ""
        val sender = data["sender"] ?: ""
        val filtered = JSONArray()
        for (i in 0 until array.length()) {
            val obj = array.getJSONObject(i)
            if (obj.optString("body") == body && obj.optString("sender") == sender) continue
            filtered.put(obj)
        }
        if (filtered.length() == 0) {
            prefs.edit().remove(PREFS_KEY).apply()
        } else {
            prefs.edit().putString(PREFS_KEY, filtered.toString()).apply()
        }
    }

    private fun appendPersisted(data: Map<String, String>, context: Context) {
        val prefs = context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val existing = prefs.getString(PREFS_KEY, null)
        val array = if (existing != null) JSONArray(existing) else JSONArray()
        val obj = JSONObject()
        data.forEach { (k, v) -> obj.put(k, v) }
        array.put(obj)
        prefs.edit().putString(PREFS_KEY, array.toString()).apply()
    }

    private fun loadPersisted(context: Context): List<Map<String, String>> {
        val prefs = context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val raw = prefs.getString(PREFS_KEY, null) ?: return emptyList()
        val array = JSONArray(raw)
        val result = mutableListOf<Map<String, String>>()
        for (i in 0 until array.length()) {
            val obj = array.getJSONObject(i)
            val map = mutableMapOf<String, String>()
            obj.keys().forEach { key -> map[key] = obj.getString(key) }
            result.add(map)
        }
        return result
    }

    private fun clearPersisted(context: Context) {
        context.applicationContext
            .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit().remove(PREFS_KEY).apply()
    }
}
