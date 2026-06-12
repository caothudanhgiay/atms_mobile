import Foundation

class MethodChannel{
    static let instance = MethodChannel()
    private var sendChannel:FlutterMethodChannel?
    private let sendChannelName = "callbacks"
    public var receiveChannel:FlutterMethodChannel?
    private let receiveChannelName = "vn.meoluoi.openweb/flutter_channel"
    
    init(){}
    
    func initChannel(messenger:FlutterBinaryMessenger){
        sendChannel = FlutterMethodChannel(name: sendChannelName,
                                           binaryMessenger: messenger)
        
        receiveChannel = FlutterMethodChannel(name: receiveChannelName,
                                              binaryMessenger:messenger)
    }
    
    func sendResult(){
        self.sendChannel?.invokeMethod("callListener", arguments: ["name":"hehe","age":1])
    }
    
    func sendEventNetAloSessionExpire(){
        self.sendChannel?.invokeMethod("netAloSessionExpire", arguments: [])
    }
}
