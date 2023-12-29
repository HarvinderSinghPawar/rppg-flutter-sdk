import 'package:flutter_test/flutter_test.dart';
import 'package:rppg_common/rppg_common.dart';
import 'package:rppg_common/rppg_common_platform_interface.dart';
import 'package:rppg_common/rppg_common_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRppgCommonPlatform
    with MockPlatformInterfaceMixin
    implements RppgCommonPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> askPermissions() {
    // TODO: implement askPermissions
    throw UnimplementedError();
  }

  @override
  Future<String?> cleanMesh() {
    // TODO: implement cleanMesh
    throw UnimplementedError();
  }

  @override
  Future<String?> configure() {
    // TODO: implement configure
    throw UnimplementedError();
  }

  @override
  Future<String?> meshColor() {
    // TODO: implement meshColor
    throw UnimplementedError();
  }

  @override
  Future<String?> startVideo() {
    // TODO: implement startVideo
    throw UnimplementedError();
  }

  @override
  Future<String?> startAnalysis() {
    // TODO: implement stopAnalysis
    throw UnimplementedError();
  }

  @override
  Future<String?> stopAnalysis() {
    // TODO: implement stopAnalysis
    throw UnimplementedError();
  }

  @override
  Future<String?> stopVideo() {
    // TODO: implement stopVideo
    throw UnimplementedError();
  }

  @override
  Future<String?> beginSession() {
    // TODO: implement beginSession
    throw UnimplementedError();
  }

  @override
  Future<String> getState() {
    // TODO: implement getState
    throw UnimplementedError();
  }

  @override
  Stream streamStartAnalysis() {
    // TODO: implement streamStartAnalysis
    throw UnimplementedError();
  }

}

void main() {
  final RppgCommonPlatform initialPlatform = RppgCommonPlatform.instance;

  test('$MethodChannelRppgCommon is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRppgCommon>());
  });

  test('getPlatformVersion', () async {
    RppgCommon rppgCommonPlugin = RppgCommon();
    MockRppgCommonPlatform fakePlatform = MockRppgCommonPlatform();
    RppgCommonPlatform.instance = fakePlatform;

    expect(await rppgCommonPlugin.getPlatformVersion(), '42');
  });
}
