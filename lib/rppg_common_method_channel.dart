import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'rppg_common_platform_interface.dart';

// import 'dart:convert';

/// An implementation of [RppgCommonPlatform] that uses method channels.
class MethodChannelRppgCommon extends RppgCommonPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('rppg_common');

  static const EventChannel streamEventChannel = EventChannel('rppgCommon/analysisDataStream');

  late StreamSubscription subscription;

  // Stream<dynamic> get onWebSocketEvent => streamEventChannel.receiveBroadcastStream();

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String> getState() async {
    final result = await methodChannel.invokeMethod<String>('getState') ?? "default";
    return result;
  }

  @override
  Future<bool> askPermissions() async {
    final result = await methodChannel.invokeMethod<bool>('askPermissions') ?? false;
    return result;
  }

  @override
  Future<String?> configure() async {
    final result = await methodChannel.invokeMethod<String>('configure');
    return result;
  }

  @override
  Future<String?> startVideo() async {
    final result = await methodChannel.invokeMethod<String>('startVideo');
    return result;
  }

  @override
  Future<String?> stopVideo() async {
    final result = await methodChannel.invokeMethod<String>('stopVideo');
    return result;
  }

  @override
  Future<dynamic> startAnalysis() async {
    final result = await methodChannel.invokeMethod<String>('startAnalysis');
    return result;
  }

  @override
  Stream<dynamic> streamStartAnalysis() {
    methodChannel.invokeMethod('startAnalysis');
    return streamEventChannel.receiveBroadcastStream();
    // var data;
    // subscription = streamEventChannel.receiveBroadcastStream().listen((message) {
    //   // Handle incoming message
    //   print('Received message in flutter from evnet channel: $message');
    //
    //   return message;
    // });

    // subscription = onWebSocketEvent.listen(
    //     _onEventReceived,
    //     onDone: (){
    //       log("Done event in flutter");
    //     },
    //     onError: (error){
    //       log("Found error in event channel $error");
    //     }
    //     );
  }

  void closeEventChannel() {
    subscription.cancel();
  }

  Stream<dynamic> _onEventReceived(dynamic event) {
    //Receive Event
    print("Event received in flutter $event");
    //
    // String str = json.encode(event);
    // Map eventMap = json.decode(str);
    return event;
  }

  @override
  Future<String?> stopAnalysis() async {
    final result = await methodChannel.invokeMethod<String>('stopAnalysis');
    return result;
  }

  @override
  Future<String?> cleanMesh() async {
    final result = await methodChannel.invokeMethod<String>('cleanMesh');
    return result;
  }

  @override
  Future<String?> meshColor() async {
    final result = await methodChannel.invokeMethod<String>('meshColor');
    return result;
  }

  @override
  Future<String?> beginSession() async {
    final result = await methodChannel.invokeMethod<String>('beginSession');
    return result;
  }
}
