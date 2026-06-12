package com.atms.loadweb

import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.view.View
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.RelativeLayout

class WebViewActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val filePath = intent.extras?.getString("filePath", "") ?: ""
        setContentView(R.layout.activity_webview)
        val webView: WebView = findViewById<View>(R.id.webview) as WebView

        val loadingPage = findViewById<View>(R.id.loadingPage) as RelativeLayout

        loadingPage.animate()
            .alpha(0.0f).duration = 1500

        Log.e("filePath", filePath)

        webView.settings.javaScriptEnabled = true
        webView.settings.allowFileAccess = true
        webView.settings.domStorageEnabled = true
        webView.settings.setSupportMultipleWindows(true)
        webView.settings.allowContentAccess = true
        webView.settings.allowUniversalAccessFromFileURLs = true
        val url = "file://" + filePath
        Log.e("url", url)
        webView.loadUrl(url)
        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                return false
            }

            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                loadingPage.visibility = View.GONE
            }
        }
    }

    override fun onBackPressed() {

    }
}