package com.atms.loadweb

import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    var currentResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        PlatformChannel.instance.init(flutterEngine.dartExecutor.binaryMessenger)
        PlatformChannel.instance.receiveChannel.setMethodCallHandler { call, result ->
            currentResult = result
            when (call.method) {
                "openWebView" -> openWebView(call, result)
            }
        }
    }

    private fun openWebView(call: MethodCall, result: MethodChannel.Result) {
        val filePath = call.arguments as? String ?: ""
        val i = Intent(this, WebViewActivity::class.java)
        i.putExtra("filePath", filePath)
        startActivity(i)
        //finish()
    }
}
