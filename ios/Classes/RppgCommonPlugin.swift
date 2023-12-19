import Flutter
import AVFoundation
import UIKit

public class RppgCommonPlugin: NSObject, FlutterPlugin {

    let analysis = Analysis()
        
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Method Channel
        let channel = FlutterMethodChannel(name: "rppg_common", binaryMessenger: registrar.messenger())
        let instance = RppgCommonPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Platform View
        let factory = FLNativeViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "rppg_native_camera")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "askPermissions":
            self.analysis.askPermissions()
            result("askPermissions")
        case "beginSession":
            self.analysis.beginSession()
            result("beginSession")
        case "startAnalysis":
            self.analysis.startAnalysis()
            result("startAnalysis")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
