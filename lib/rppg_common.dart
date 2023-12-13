
import 'rppg_common_platform_interface.dart';


class RppgCommon {
  Future<String?> getPlatformVersion() {
    return RppgCommonPlatform.instance.getPlatformVersion();
  }
}
