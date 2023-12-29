import 'rppg_common_platform_interface.dart';
export 'Views/camera_view.dart';

/// Initial state of the facade (right after initialization).
/// case initial

/// State of the facade when video session is configured. Web socket is not configured yet.
/// case prepared

/// State of the facade when input and output devices of video session are initialized
/// and connected to session, input video should be already rendered in RPPGCameraView.
/// case videoStarted

/// State of the facade when both video session and web socket are configured and running, images captured and
/// passed to face detector, BGR signals calculated and submitted to the backend and vitals should be received
/// through web socket (analysis is running).
/// case analysisRunning

class RppgCommon {
  Future<String?> getPlatformVersion() {
    return RppgCommonPlatform.instance.getPlatformVersion();
  }

  Future<String> getState() {
    return RppgCommonPlatform.instance.getState();
  }

  Future<bool> askPermissions() {
    return RppgCommonPlatform.instance.askPermissions();
  }

  Future<String?> configure() {
    return RppgCommonPlatform.instance.configure();
  }

  Future<String?> startVideo() {
    return RppgCommonPlatform.instance.startVideo();
  }

  Future<String?> stopVideo() {
    return RppgCommonPlatform.instance.stopVideo();
  }

  Future<dynamic> startAnalysis() {
    return RppgCommonPlatform.instance.startAnalysis();
  }

  Stream<dynamic> streamStartAnalysis() {
    return RppgCommonPlatform.instance.streamStartAnalysis();
  }

  Future<String?> stopAnalysis() {
    return RppgCommonPlatform.instance.stopAnalysis();
  }

  Future<String?> cleanMesh() {
    return RppgCommonPlatform.instance.cleanMesh();
  }

  Future<String?> meshColor() {
    return RppgCommonPlatform.instance.meshColor();
  }

  Future<String?> beginSession() {
    return RppgCommonPlatform.instance.beginSession();
  }
}
