package com.atms.loadweb

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class PlatformChannel {
    private var sendChannel: MethodChannel? = null
    private val sendChannelName = "callbacks"
    lateinit var receiveChannel: MethodChannel
    private val receiveChannelName = "vn.meoluoi.openweb/flutter_channel"
    var isInit = false

    companion object {
        var instance = PlatformChannel()
    }

    fun init(binaryMessenger: BinaryMessenger) {
        sendChannel = MethodChannel(binaryMessenger, sendChannelName)
        receiveChannel = MethodChannel(binaryMessenger, receiveChannelName)
        isInit = true
    }

    fun sendEventNetAloSessionExpire() {
        sendChannel?.invokeMethod("netAloSessionExpire", null)
    }

}