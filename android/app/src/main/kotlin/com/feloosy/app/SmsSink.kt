package com.feloosy.app

import io.flutter.plugin.common.EventChannel

object SmsSink {
    private var sink: EventChannel.EventSink? = null

    fun register(sink: EventChannel.EventSink?) {
        this.sink = sink
    }

    fun push(data: Map<String, String>) {
        sink?.success(data)
    }
}
