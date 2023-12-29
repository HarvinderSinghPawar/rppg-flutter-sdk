import Flutter
import AVFoundation
import UIKit
import RPPGCommon
import RPPGCore

public class RppgCommonPlugin: NSObject, FlutterPlugin {

    let shared = Analysis.shared
    
    // MARK: Singleton Instance:
    //Defines a shared instance of the RppgCommonPlugin class using the singleton pattern
    static let rppgPluginShared : RppgCommonPlugin = {
        let instace = RppgCommonPlugin()
        
        return instace
    }()
    
    // Declare our eventSink, it will be initialized later
    private var eventSink: FlutterEventSink?
    
    override init() {
        super.init()
    }
        
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Method Channel
        let channel = FlutterMethodChannel(name: "rppg_common", binaryMessenger: registrar.messenger())
//        let instance = RppgCommonPlugin()
        registrar.addMethodCallDelegate(rppgPluginShared, channel: channel)
        
        // Event Channel
        let eventChannel = FlutterEventChannel(name: "rppgCommon/analysisDataStream", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(rppgPluginShared)
                
        // Platform View
        let factory = FLNativeViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "rppg_native_camera")
    
    }

    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "getState":
            result(shared.getState())
        case "askPermissions":
            result(shared.askPermissions())
        case "configure":
            shared.configure()
            result("configure")
        case "startVideo":
            shared.startVideo()
            result("startVideo")
        case "stopVideo":
            shared.stopVideo()
            result("stopVideo")
        case "startAnalysis":
            shared.startAnalysis()
            result("startAnalysis")
        case "stopAnalysis":
            shared.stopAnalysis()
            result("stopAnalysis")
        case "cleanMesh":
            shared.cleanMesh()
            result("cleanMesh")
        case "meshColor":
            shared.meshColor()
            result("meshColor")
        case "beginSession":
            shared.beginSession()
            result("beginSession")
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    
}


extension RppgCommonPlugin: FlutterStreamHandler {
   
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    // Method to send dynamic data
    public func sendEvent(data: Any) {
        print("Pre Sending event...... \(data)")
        print("Pre eventSink...... \(String(describing: self.eventSink))")
       
        // Check if the eventSink is available
        guard let eventSink = self.eventSink else {
            return
        }

        eventSink(data)
    }
    
    // Method to stop the listener
    public func stopListening() {
        // Check if the eventSink is available
        guard let eventSink = eventSink else {
            return
        }
        
        // Send a closing event
        eventSink("Closing Event from iOS")
        
        // Release resources if needed
        // ...
        
        // Set eventSink to nil to indicate that the listener has been stopped
        self.eventSink = nil
    }
    
    // Example method to trigger sending data to Flutter
      public func triggerSendingData() {
        let yourData = "Hello from iOS!"
          sendEvent(data: yourData)
      }
}
