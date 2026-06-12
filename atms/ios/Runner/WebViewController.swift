//
//  WebViewController.swift
//  Runner
//
//  Created by Meo luoi on 23/09/2022.
//

import Foundation
import UIKit
import WebKit
class WebViewController: UIViewController, WKUIDelegate {
    var filePath:String = ""
    
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let myURL = URL(string:"https://www.apple.com")
//        let myRequest = URLRequest(url: myURL!)
//        webView.load(myRequest)
        
        let myURL = URL(fileURLWithPath: filePath)
        webView.configuration.preferences.javaScriptEnabled = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        if #available(iOS 14.0, *) {
            webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            // Fallback on earlier versions
        }
        webView.loadFileURL(myURL, allowingReadAccessTo: myURL)
    }
    
}
