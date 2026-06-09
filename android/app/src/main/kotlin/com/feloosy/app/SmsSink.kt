package com.feloosy.app

import android.content.Context
import io.flutter.plugin.common.EventChannel
import org.json.JSONArray
import org.json.JSONObject

object SmsSink {
    private const val PREFS_NAME = "SmsSinkPrefs"
    private const val PREFS_KEY  = "pending_sms"

    private var sink: EventChannel.EventSink? = null
    // In-memory buffer for SMS that arrive after push() but before register() in the same process.
    private val pending = mutableListOf<Map<String, String>>()

    fun register(sink: EventChannel.EventSink?, context: Context) {
        this.sink = sink
        if (sink == null) return

        // Drain persisted queue from previous process death first.
        val stored = loadPersisted(context)
        if (stored.isNotEmpty()) {
            stored.forEach { sink.success(it) }
            clearPersisted(context)
        }

        // Then drain the in-memory buffer for same-process arrivals.
        pending.forEach { sink.success(it) }
        pending.clear()
    }

    fun push(data: Map<String, String>, context: Context) {
        val s = sink
        if (s != null) {
            s.success(data)
        } else {
            // Persist immediately so the message survives process death.
            appendPersisted(data, context)
            pending.add(data)
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
