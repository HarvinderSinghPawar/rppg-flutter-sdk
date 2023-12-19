import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'rppg_common_method_channel.dart';

abstract class RppgCommonPlatform extends PlatformInterface {
  /// Constructs a RppgCommonPlatform.
  RppgCommonPlatform() : super(token: _token);

  static final Object _token = Object();

  static RppgCommonPlatform _instance = MethodChannelRppgCommon();

  /// The default instance of [RppgCommonPlatform] to use.
  ///
  /// Defaults to [MethodChannelRppgCommon].
  static RppgCommonPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [RppgCommonPlatform] when
  /// they register themselves.
  static set instance(RppgCommonPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> askPermissions() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> beginSession() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> startAnalysis() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
