import 'rppg_common_platform_interface.dart';


class RppgCommon {
  Future<String?> getPlatformVersion() {
    return RppgCommonPlatform.instance.getPlatformVersion();
  }

  Future<String?> askPermissions() {
    return RppgCommonPlatform.instance.askPermissions();
  }

  Future<String?> beginSession() {
    return RppgCommonPlatform.instance.beginSession();
  }

  Future<String?> startAnalysis() {
    return RppgCommonPlatform.instance.startAnalysis();
  }
}
