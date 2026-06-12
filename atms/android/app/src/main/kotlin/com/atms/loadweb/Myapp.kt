package com.atms.loadweb

import android.content.Context
import android.os.StrictMode
import androidx.multidex.MultiDex
import io.flutter.app.FlutterApplication

class MyApp : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        val builder: StrictMode.VmPolicy.Builder = StrictMode.VmPolicy.Builder()
        StrictMode.setVmPolicy(builder.build())
    }

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
}