package com.feloosy.app

import io.flutter.plugin.common.EventChannel

object SmsSink {
    private var sink: EventChannel.EventSink? = null
    // Buffers messages that arrive before Flutter registers the EventChannel listener.
    private val pending = mutableListOf<Map<String, String>>()

    fun register(sink: EventChannel.EventSink?) {
        this.sink = sink
        if (sink != null) {
            pending.forEach { sink.success(it) }
            pending.clear()
        }
    }

    fun push(data: Map<String, String>) {
        val s = sink
        if (s != null) {
            s.success(data)
        } else {
            pending.add(data)
        }
    }
}
