import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    var currentResult:FlutterResult?
    lazy var applicationSupportURL: URL = {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        return urls[0]
    }()
    
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Cho phép WKWebView hiện keyboard khi gọi focus() programmatically (không cần user gesture)
        // Dùng bản Objective-C để tránh crash swift_unknownObjectRetain trên iOS 17/18
        WKWebViewKeyboardHelperObjC.enableKeyboardDisplayWithoutUserAction()
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        MethodChannel.instance.initChannel(messenger: controller.binaryMessenger)
        
        MethodChannel.instance.receiveChannel?.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self.currentResult = result
            switch (call.method){
            case "showTestScreen":
                print("showTestScreen")
            case "getSavePath":
                self.getSavePath(call:call,result: result)
            case "openFile":
                self.openFile(call:call,result: result)
            case "openWebView":
                self.openWebView(call:call,result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        if #available(iOS 10.0, *) {
          UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func getSavePath(call: FlutterMethodCall,result: @escaping FlutterResult){
        var isDir: ObjCBool = true
        if !FileManager.default.fileExists(atPath: applicationSupportURL.path, isDirectory: &isDir) {
            do {
                try FileManager.default.createDirectory(atPath: applicationSupportURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        
        result(applicationSupportURL.path)
    }
    
    func openWebView(call: FlutterMethodCall,result: @escaping FlutterResult){
        guard let args = call.arguments else {
            return
        }
        
        let path = args as! String
        print("path \(path)")
        
        let rootViewController : FlutterViewController = window?.rootViewController as! FlutterViewController
        let viewController = WebViewController()
        viewController.modalPresentationStyle = .fullScreen
        viewController.filePath = path
        rootViewController.present(viewController, animated: false, completion: nil)
        
//        self.window?.rootViewController = viewController
    }
    
    
    func openFile(call: FlutterMethodCall,result: @escaping FlutterResult){
        guard let args = call.arguments else {
            return
        }
        
        let path = args as! String
        print("path \(path)")
        UIApplication.shared.canOpenURL(URL(fileURLWithPath: path))
    }
    
}
