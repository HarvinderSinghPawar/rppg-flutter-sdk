import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'rppg_common_platform_interface.dart';

/// An implementation of [RppgCommonPlatform] that uses method channels.
class MethodChannelRppgCommon extends RppgCommonPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('rppg_common');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> askPermissions() async {
    final result = await methodChannel.invokeMethod<String>('askPermissions');
    return result;
  }

  @override
  Future<String?> beginSession() async {
    final result = await methodChannel.invokeMethod<String>('beginSession');
    return result;
  }

  @override
  Future<String?> startAnalysis() async {
    final result = await methodChannel.invokeMethod<String>('startAnalysis');
    return result;
  }

}
