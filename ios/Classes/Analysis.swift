import Flutter
import AVFoundation
import UIKit
import RPPGCommon
import RPPGCore


public class Analysis: NSObject {
    
//    private var loginEventTrigger: EventChannelHandler?
    
    /// Analysis
    /// 
    static let shared = Analysis()
    
        
    var cameraViewContainer: UIView!
    
    var socketAccessToken: String? = nil
    var analysisDataArray: [RPPGSocketMessageData] = []
    
    var rppgFacade: RPPGCommonFacadeProtocol!
    var videoSettings = RPPGVideoSessionSettings.default
    var socketManager: RPPGSocketManagerProtocol?
    
    var cameraSettings: CameraSettings!
    var cameraPosition: RPPGVideoSessionSettings.CameraPosition = .front
    
    var askPermissionsResponse: Bool = false
    
    var lastAnalysis = AnalysisData()
    
    var tempBloodPressure: RPPGSocketMessageBloodPressure?
    var tempIsMoveWarning: Bool?

    override init() {
        self.cameraViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))

        super.init() // can actually be omitted in this example because will happen automatically.
        // Initialize and configure yourUIView
        self.setupFacade()
        self.setupCameraView()
    }

    private func setupFacade() {
        rppgFacade = RPPGCommonFacade()
        rppgFacade.delegate = self
        rppgFacade.diagnosticsDelegate = self
        rppgFacade.rawDelegate = self
        
        RPPGCommonFacade.enableDebugLogs(true)
        
        print("setupFacade called")
        print("RPPGCommon version: \(rppgFacade.version)")
    }
    
    private func setupCameraView(){
        let cameraView = self.rppgFacade.cameraView
        cameraView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        cameraView.translatesAutoresizingMaskIntoConstraints = true
        cameraView.frame = cameraViewContainer.bounds
        cameraViewContainer.addSubview(cameraView)
        cameraViewContainer.sendSubviewToBack(cameraView)
    }
    
    func setupCameraSettings(socketUrlString: String, fps: CMTimeScale, quality: AVCaptureSession.Preset, duration: CGFloat) {
        self.cameraSettings = .init(socketUrlString: socketUrlString, fps: fps, quality: quality, duration: duration)
    }
    
//    var videoSettings: RPPGVideoSessionSettings {
//        return RPPGVideoSessionSettings(fps: cameraSettings.fps,
//                                        cameraPosition: cameraPosition)
//    }
    
    public func getState () -> String {
        switch self.rppgFacade.state {
        case .initial:
            return "initial"
        case .prepared:
            return "prepared"
        case .videoStarted:
            return "videoStarted"
        case .analysisRunning:
            return "analysisRunning"
        @unknown default:
            return "default"
        }
    }
    
    public func askPermissions() -> Bool {
        self.rppgFacade.askPermissions(completion: { [weak self] granted in
            if granted {
                self?.askPermissionsResponse = true
            } else {
                self?.askPermissionsResponse = false
            }
        })
        return self.askPermissionsResponse
    }
    
    public func configure() {
        self.rppgFacade.configure(settings: .default)
    }
    
    public func startVideo() {
        self.rppgFacade.startVideo()
    }
    
    public func stopVideo() {
        self.rppgFacade.stopVideo()
    }
    
    public func startAnalysis() {
        let socketUrl = "wss://rppg-prod.xyz/vp/bgr_signal_socket?authToken=7df3a823-6bb1-4564-8f46-d803591e403a&fps=&age=27&sex=male&height=165&weight=75"
        let url = URL(string: socketUrl)!
        self.rppgFacade.startAnalysis(socketURL: url)
    }
    
    public func stopAnalysis() {
        self.rppgFacade.stopAnalysis()
    }
    
    public func cleanMesh() {
        self.rppgFacade.cameraView.cleanMesh()
    }
    
    public func meshColor() {
        self.rppgFacade.cameraView.meshColor = Constants.faceMeshFinalColor
//        if color =="intial" {
//            self.rppgFacade.cameraView.meshColor = Constants.faceMeshInitialColor
//        } else if "faceMeshFinalColor" {
//            self.rppgFacade.cameraView.meshColor = Constants.faceMeshFinalColor
//        }
        
    }
    
    public func beginSession() {
        #if targetEnvironment(simulator)
        return
        #endif
//        videoSettings = RPPGVideoSessionSettings(
//            fps: 30,
//            cameraPosition: self.videoSettings.cameraPosition == .front ? .back : .front)
        self.rppgFacade.configure(settings: self.videoSettings)
        self.rppgFacade.startVideo()
    }
    
//    public func startAnalysis() {
//
//        switch rppgFacade.state {
//        case .initial:
//            print("---------------case .initial----------------")
//            rppgFacade.askPermissions { [weak self] (granted) in
//                print("Permissions \(granted ? "granted" : "denied")");
//                if (granted) {
//                    DispatchQueue.main.async {
//                        // UIView usage
//                        self?.rppgFacade.configure(settings: .default)
//                    }
//                }
//            }
//        case .prepared:
//            print("---------------case .prepared----------------")
//            rppgFacade.startVideo()
//
//        case .videoStarted:
//            print("---------------case .videoStarted----------------")
////            let deviceInfo = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
////                .replacingOccurrences(of: " ", with: "_")
////            let authToken = "58821f09-40d6-4cb9-b4ed-88d2ede9e358"
////            let socketUrl = "wss://rppg-debug.xyz/vp/bgr_signal_socket?authToken=\(authToken)&deviceInfo=\(deviceInfo)"
//            let socketUrl = "wss://rppg-prod.xyz/vp/bgr_signal_socket?authToken=7df3a823-6bb1-4564-8f46-d803591e403a&fps=&age=27&sex=male&height=165&weight=75"
//            let url = URL(string: socketUrl)!
//            rppgFacade.startAnalysis(socketURL: url)
//        case .analysisRunning:
//            print("---------------case .analysisRunning----------------")
//            rppgFacade.stopAnalysis()
//            rppgFacade.cameraView.cleanMesh()
//        @unknown default:
//            print("---------------@unknown default----------------")
//            print("fail default")
//        }
//    }
    
    
}


// MARK: - RPPGCommonFacadeDelegate
extension Analysis: RPPGCommonFacadeDelegate {
    
    public func facade(_ facade: RPPGCommon.RPPGCommonFacade, didReceiveEventFromSocket event: RPPGCommon.RPPGSocketEvent) {
        switch event {
    
        case .connected:
            print("---------------connected----------------")
//            startAnalysis()
        case .disconnected:
            print("---------------disconnected----------------")
//            socketAccessToken = nil
        case .cancelled:
            print("---------------cancelled----------------")
//            print("event status cancel: \(event)")
        case .message(let message):
            print("---------------message----------------")
            handleSocketData(message)
        @unknown default:
            fatalError("Unknown socket event received: \(event)")
        }
    }
    
    public func facade(_ facade: RPPGCommon.RPPGCommonFacade, analysisInterrupted reason: RPPGCommon.RPPGAnalysisInterruptionReason, error: Error?) {
        self.cleanupAfterInterruption()
    }
    
    func cleanupAfterInterruption() {
        rppgFacade.cameraView.cleanMesh()
    }
    
    
}


// MARK: - RPPGCommonFacadeDiagnosticsDelegate
extension Analysis: RPPGCommonFacadeDiagnosticsDelegate {
    
    public func facade(_ facade: RPPGCommon.RPPGCommonFacade, didReceiveImageQualityData data: RPPGCommon.RPPGImageQualityData) {
        print("image quality data received: \(data)")
    }
    
    
}

//MARK: - RPPGCommonFacadeRawDelegate
extension Analysis: RPPGCommonFacadeRawDelegate {
    public func facadeDidReceiveSocketConnected(_ facade: RPPGCommon.RPPGCommonFacade) {
        
    }
    
    public func facadeDidReceiveSocketDisconnected(_ facade: RPPGCommon.RPPGCommonFacade) {
        
    }
    
    public func facadeDidReceiveSocketCancelled(_ facade: RPPGCommon.RPPGCommonFacade) {
        
    }
    
    public func facade(_ facade: RPPGCommon.RPPGCommonFacade, didReceiveMessageFromSocket message: String) {
        print("RPPGCommonFacadeRawDelegate message ---> " + message)
    }
    
    public func facade(_ facade: RPPGCommon.RPPGCommonFacade, interruptionWithReason reason: String) {
        print("reason is" + reason)
    }
    
    
}


// MARK: - Networking
extension Analysis {
    public func handleSocketData(_ message: RPPGSocketMessage) {
        print("message.messageType: \(message.messageType)")
       
        switch message.messageType {
        case let .data(messageData):
            handleMessageDataResponse(messageData)
        case let .meanData(data):
            _ = handleMeanDataResponse(data)
            
        case let .status(data):
            handleStatusDataResponse(data)
        case let .rateWarning(data):
            handleRateWarningDataResponse(data)
        case .moveWarning:
            handleMoveWarning()
        case let .progress(data):
            handleProgressDataResponse(data)
        case let .signal(data):
            handleSignalDataResponse(data)
        case let .accessToken(data):
            handleAccessTokenDataResponse(data)
        case let .bloodPressure(data):
            handleBloodPressureDataResponse(data)
        case let .signalQuality(data):
            handleSignalQualityDataResponse(data)
        case let .hrvMetrics(data):
            handleHRVMetricsResponse(data)
            break
        default:
            break
        }
    }
    
    func handleMessageDataResponse(_ data: RPPGSocketMessageData) {
        analysisDataArray.append(data)
    }
    
    public func handleMeanDataResponse(_ data: RPPGSocketMessageMeanData) -> RPPGSocketMessageMeanData {
        
        lastAnalysis.updateValue(newValue: AnalysisData(avgBpm: data.bpm,
                                                        avgO2SaturationLevel: data.oxygenSaturation,
                                                        avgRespirationRate: data.respirationRate,
                                                        isMoveWarning: self.tempIsMoveWarning,
                                                        stressStatus: data.stressStatus,
                                                        bloodPressureStatus: data.bloodPressureStatus,
                                                        bloodPressure: self.tempBloodPressure
                                                       )
        )
        
        self.tempIsMoveWarning = false
                
        DispatchQueue.main.async {
            do {
                // Convert the dictionary to JSON data
                let jsonData = try JSONSerialization.data(withJSONObject: self.lastAnalysis.getDictData(), options: [])
                
                // Convert the JSON data to a String (optional)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("JSON String: \(jsonString)")
                    RppgCommonPlugin.rppgPluginShared.sendEvent(data: jsonString)
                }
                
                // Now you have the JSON data, which you can use as needed
            } catch {
                print("Error converting dictionary to JSON: \(error)")
            }
        }
//        DispatchQueue.main.async {
//            RppgCommonPlugin.rppgPluginShared.sendEvent(data: self.lastAnalysis.getDictData())
//        }
//        RppgCommonPlugin.rppgPluginShared.triggerSendingData()
        return data
        
    }
    
    func handleStatusDataResponse(_ data: RPPGSocketMessageDataStatus) {
        guard let status = data.statusCode else { return }
        print("status is: \(status)")
    }
    
    func handleRateWarningDataResponse(_ data: RPPGSocketMessageSendingRateWarning) {
        guard let sendingDelay = data.delay else { return }
        print("sendingDelay is: \(sendingDelay)")
    }
    
    func handleMoveWarning() {
        self.tempIsMoveWarning = true
        print("movement detected")
    }

    func handleProgressDataResponse(_ data: RPPGSocketMessageProgress) {
        guard let progressPercent = data.progressPercent else { return }
        print("progressPercent is: \(progressPercent)")
    }
    
    func handleSignalDataResponse(_ data: RPPGSocketMessageSignal) {
        guard let signals = data.signalValues else { return }
        print("signals is: \(signals)")
    }
    
    func handleAccessTokenDataResponse(_ data: RPPGSocketMessageToken) {
        guard let token = data.accessToken else { return }
        print("AccessToken is: \(token)")
        socketAccessToken = token
    }
    
    func handleBloodPressureDataResponse(_ data: RPPGSocketMessageBloodPressure) {
        // todo: need to show in the UI or pass to the analysis results?
        print("BLOOD PRESSURE diastolic is: \(data.diastolic)")
        print("BLOOD PRESSURE systolic is: \(data.systolic)")
        
        self.tempBloodPressure = data
        
    }
    
    func handleSignalQualityDataResponse(_ data: RPPGSocketMessageSignalQuality) {

    }
    
    func handleHRVMetricsResponse(_ data: RPPGSocketMessageHeartRateVariability) {
        
    }
}


// MARK: - App lifecycle notifications

//extension RppgCommonPlugin {
//    func subscribeForAppLifecycleNotifications() {
//        NotificationCenter.default.addObserver(self,selector: #selector(handleAppDidBecomeActive),
//                                               name: UIApplication.didBecomeActiveNotification,
//                                               object: nil)
//    }
//
//    func unsubscribeFromAppLifecycleNotifications() {
//        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
//    }
//
//
//    @objc func handleAppDidBecomeActive() {
//        // will start video session after interruption if needed
//        if rppgFacade.state == .prepared {
//            rppgFacade.askPermissions(completion: { [weak self] granted in
//                if granted {
//                    self?.rppgFacade.startVideo()                }
//            })
//        }
//    }
//}

// MARK: - Constants
struct Constants {
    static let faceMeshInitialColor = UIColor.white.withAlphaComponent(0.3)
    static let faceMeshFinalColor = UIColor.yellow.withAlphaComponent(0.3)
    
    #if DEV
    static let maxAnalysisTime: TimeInterval = 5 * 60
    #elseif DBG
    static let maxAnalysisTime: TimeInterval = 5 * 60
    #else
    static let maxAnalysisTime: TimeInterval = 3 * 60
    #endif
    
    static let maxNoiseDetectedDuration: TimeInterval = 20
    static let stayStillAlertTimer: TimeInterval = 5
    static let stayStillAlertDuration: TimeInterval = 5
    static let maxDelay = 200
    static let videoViewTag = 777;
}






