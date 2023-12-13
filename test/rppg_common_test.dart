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
