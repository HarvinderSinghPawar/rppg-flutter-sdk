import Flutter
import AVFoundation
import UIKit
import RPPGCommon
import RPPGCore

public class Analysis {
    
    private var socketAccessToken: String? = nil
    private var analysisDataArray: [RPPGSocketMessageData] = []
    
    var rppgFacade: RPPGCommonFacadeProtocol!
    var videoSettings = RPPGVideoSessionSettings.default
    
    private var cameraSettings: CameraSettings!
    private var cameraPosition: RPPGVideoSessionSettings.CameraPosition = .front
    
    
    func setupCameraSettings(socketUrlString: String, fps: CMTimeScale, quality: AVCaptureSession.Preset, duration: CGFloat) {
        self.cameraSettings = .init(socketUrlString: socketUrlString, fps: fps, quality: quality, duration: duration)
    }
    
//    var videoSettings: RPPGVideoSessionSettings {
//        return RPPGVideoSessionSettings(fps: cameraSettings.fps,
//                                        cameraPosition: cameraPosition)
//    }
        
//    override init() {
//        super.init() // can actually be omitted in this example because will happen automatically.
//        setupFacade()
//        setupVideoView()
//    }
    
    
    func setupFacade() {
        rppgFacade = RPPGCommonFacade()
        rppgFacade.delegate = self
        rppgFacade.diagnosticsDelegate = self
        RPPGCommonFacade.enableDebugLogs(true)
        
        print("setupFacade called")
        print("RPPGCommon version: \(rppgFacade.version)")
    }
    
    func setupVideoView(){
        let videoView = rppgFacade.cameraView
        videoView.translatesAutoresizingMaskIntoConstraints = true
        videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        videoView.frame = cameraViewContainer.bounds
        videoView.tag = Constants.videoViewTag
        videoView.meshColor = Constants.faceMeshInitialColor
//        cameraViewContainer.addSubview(videoView)
    }
    
    func askPermissions() {
        setupFacade()

        rppgFacade.askPermissions { [weak self] granted in
            guard granted else {
                print("You should allow application to access camera")
                return
            }
        }
    }
    
    func beginSession() {
        #if targetEnvironment(simulator)
        return
        #endif
        videoSettings = RPPGVideoSessionSettings(
            fps: 30,
            cameraPosition: self.videoSettings.cameraPosition == .front ? .back : .front)
        rppgFacade.configure(settings: self.videoSettings)
        rppgFacade.startVideo()
    }
    
    
    public func startAnalysis() {
        
        switch rppgFacade.state {
        case .initial:
            rppgFacade.askPermissions { [weak self] (granted) in
                print("Permissions \(granted ? "granted" : "denied")");
                if (granted) {
                    DispatchQueue.main.async {
                        // UIView usage
                        self?.rppgFacade.configure(settings: .default)
                    }
                }
            }
        case .prepared:
            rppgFacade.startVideo()
        case .videoStarted:
            let deviceInfo = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
                .replacingOccurrences(of: " ", with: "_")
            let authToken = "58821f09-40d6-4cb9-b4ed-88d2ede9e358"
            let socketUrl = "wss://rppg-debug.xyz/vp/bgr_signal_socket?authToken=\(authToken)&deviceInfo=\(deviceInfo)"
            let url = URL(string: socketUrl)!
            rppgFacade.startAnalysis(socketURL: url)
        case .analysisRunning:
            rppgFacade.stopAnalysis()
            rppgFacade.cameraView.cleanMesh()
        @unknown default:
            print("fail default")
        }
    }
    
    
    
    
}


// MARK: - RPPGCommonFacadeDelegate
extension Analysis: RPPGCommonFacadeDelegate {
    
    public func facade(_ facade: RPPGCommon.RPPGCommonFacade, didReceiveEventFromSocket event: RPPGCommon.RPPGSocketEvent) {
        switch event {
        case .connected:
            print("Connected... Now")
        case .disconnected:
            print("Disconnected... Now")
        case .cancelled:
            print("Cancelled... Now")
        case .message(let message):
            handleSocketData(message)
        @unknown default:
            fatalError("Unknown socket event received: \(event)")
        }
    }
    
    public func facade(_ facade: RPPGCommon.RPPGCommonFacade, analysisInterrupted reason: RPPGCommon.RPPGAnalysisInterruptionReason, error: Error?) {
        self.cleanupAfterInterruption()
    }
    
    private func cleanupAfterInterruption() {
        rppgFacade.cameraView.cleanMesh()
    }
    
    
}


// MARK: - RPPGCommonFacadeDiagnosticsDelegate
extension Analysis: RPPGCommonFacadeDiagnosticsDelegate {
    
    public func facade(_ facade: RPPGCommon.RPPGCommonFacade, didReceiveImageQualityData data: RPPGCommon.RPPGImageQualityData) {
        print("image quality data received: \(data)")
    }
    
    
}


// MARK: - Networking
private extension Analysis {
    func handleSocketData(_ message: RPPGSocketMessage) {
        print("message.messageType: \(message.messageType)")
       
        switch message.messageType {
        case let .data(messageData):
            handleMessageDataResponse(messageData)
//        case let .meanData(data):
//            handleMeanDataResponse(data)
//        case let .status(data):
//            handleStatusDataResponse(data)
//        case let .rateWarning(data):
//            handleRateWarningDataResponse(data)
//        case .moveWarning:
//            handleMoveWarning()
//        case let .progress(data):
//            handleProgressDataResponse(data)
//        case let .signal(data):
//            handleSignalDataResponse(data)
        case let .accessToken(data):
            handleAccessTokenDataResponse(data)
//        case let .bloodPressure(data):
//            handleBloodPressureDataResponse(data)
//        case let .signalQuality(data):
//            handleSignalQualityDataResponse(data)
//        case let .hrvMetrics(data):
//            handleHRVMetricsResponse(data)
//            break
        default:
            break
        }
    }
    
    func handleMessageDataResponse(_ data: RPPGSocketMessageData) {
        analysisDataArray.append(data)
    }
    
    func handleAccessTokenDataResponse(_ data: RPPGSocketMessageToken) {
        guard let token = data.accessToken else { return }
        socketAccessToken = token
    }
}


// MARK: - App lifecycle notifications

extension Analysis {
    private func subscribeForAppLifecycleNotifications() {
        NotificationCenter.default.addObserver(self,
                                                              selector: #selector(handleAppDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    private func unsubscribeFromAppLifecycleNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }


    @objc func handleAppDidBecomeActive() {
        // will start video session after interruption if needed
        if rppgFacade.state == .prepared {
            rppgFacade.askPermissions(completion: { [weak self] granted in
                if granted {
                    self?.rppgFacade.startVideo()                }
            })
        }
    }
}

// MARK: - Constants
private struct Constants {
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


//MARK: - RPPGCommonFacadeRawDelegate
//    extension Analysis: RPPGCommonFacadeRawDelegate {
//        public func facadeDidReceiveSocketConnected(_ facade: RPPGCommon.RPPGCommonFacade) {
//
//        }
//
//        public func facadeDidReceiveSocketDisconnected(_ facade: RPPGCommon.RPPGCommonFacade) {
//
//        }
//
//        public func facadeDidReceiveSocketCancelled(_ facade: RPPGCommon.RPPGCommonFacade) {
//
//        }
//
//        public func facade(_ facade: RPPGCommon.RPPGCommonFacade, didReceiveMessageFromSocket message: String) {
//
//        }
//
//        public func facade(_ facade: RPPGCommon.RPPGCommonFacade, interruptionWithReason reason: String) {
//
//        }
//
//
//    }
//
