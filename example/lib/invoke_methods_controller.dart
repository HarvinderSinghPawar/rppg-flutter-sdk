import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rppg_common/rppg_common.dart';
import 'dart:developer';
import 'AnalysisDataModel.dart';

class InvokeMethodController extends GetxController {
  final rppgCommonPlugin = RppgCommon();
  var invokeResult = "".obs;
  var resultPermissions = false.obs;
  var rppgFacadeState = "".obs;
  var buttonTitle = "Start Process".obs;
  dynamic streamDynamicData;

  /// Analysis Value
  var avgBpm = 'BPM:'.obs;
  var avgO2SaturationLevel = 'O2 Saturation Level:'.obs;
  var avgRespirationRate = 'Respiration Rate:'.obs;
  var bloodPressure = "Blood Pressure\nsystolic: \ndiastolic:".obs;
  var bloodPressureStatus = 'Blood Pressure Status:'.obs;
  var stressStatus = 'Stress Status:'.obs;
  var isMoveWarning = false.obs;

  resetAnalysisValues() {
    avgBpm.value =
    'BPM:';
    avgO2SaturationLevel.value =
    'O2 Saturation Level:';
    avgRespirationRate.value =
    'Respiration Rate:';
    bloodPressure.value =
    "Blood Pressure\nsystolic: \ndiastolic:";
    bloodPressureStatus.value =
    'Blood Pressure Status:';
    stressStatus.value =
    'Stress Status:';
    isMoveWarning.value = false;
  }

  startWholeSession() async {
    invokeMethod("getState");
    await invokeMethod("askPermissions");
    updateButtonTitle();
    await invokeMethod("beginSession");
    updateButtonTitle();
  }

  invokeMethod(String methodName) async {
    switch (methodName) {
      case "getPlatformVersion":
        {
          try {
            invokeResult.value =
                await rppgCommonPlugin.getPlatformVersion() ?? "Unknown";
          } on PlatformException {
            invokeResult.value = 'Failed getPlatformVersion.';
          }
        }
        break;

      case "getState":
        {
          try {
            rppgFacadeState.value = await rppgCommonPlugin.getState();
          } on PlatformException {
            invokeResult.value = 'Failed getState.';
          }
        }
        break;

      case "askPermissions":
        {
          try {
            resultPermissions.value = await rppgCommonPlugin.askPermissions();
          } on PlatformException {
            invokeResult.value = 'Failed to get platform version.';
          }
        }
        break;

      case "configure":
        {
          try {
            rppgCommonPlugin.configure();
          } on PlatformException {
            invokeResult.value = 'Failed configure.';
          }
        }
        break;

      case "startVideo":
        {
          try {
            rppgCommonPlugin.startVideo();
          } on PlatformException {
            invokeResult.value = 'Failed startVideo.';
          }
        }
        break;

      case "stopVideo":
        {
          try {
            rppgCommonPlugin.stopVideo();
          } on PlatformException {
            invokeResult.value = 'Failed stopVideo.';
          }
        }
        break;

      case "startAnalysis":
        {
          try {
            rppgCommonPlugin.startAnalysis();
          } on PlatformException {
            invokeResult.value = 'Failed startAnalysis.';
          }
        }
        break;

      case "streamStartAnalysis":
        {
          try {
            resetAnalysisValues();
            rppgCommonPlugin.streamStartAnalysis().listen((eventData) {
              avgBpm.value =
                  'BPM: ${analysisDataFromJson(eventData).avgBpm}';
              avgO2SaturationLevel.value =
                  'O2 Saturation Level: ${analysisDataFromJson(eventData).avgO2SaturationLevel}';
              avgRespirationRate.value =
                  'Respiration Rate: ${analysisDataFromJson(eventData).avgRespirationRate}';
              bloodPressure.value =
                  "Blood Pressure\nsystolic: ${analysisDataFromJson(eventData).bloodPressure[0]}\ndiastolic: ${analysisDataFromJson(eventData).bloodPressure[1]}";
              bloodPressureStatus.value =
                  'Blood Pressure Status: ${analysisDataFromJson(eventData).bloodPressureStatus}';
              stressStatus.value =
                  'Stress Status: ${analysisDataFromJson(eventData).stressStatus}';
              isMoveWarning.value = analysisDataFromJson(eventData).isMoveWarning;

              // print("Avg. BPM : ${analysisDataFromJson(eventData).avgBpm} \n"
              //     'Avg. O2 Saturation Level : ${analysisDataFromJson(eventData).avgO2SaturationLevel} \n'
              //     "Blood Pressure : ${analysisDataFromJson(eventData).bloodPressure[0]}, ${analysisDataFromJson(eventData).bloodPressure[1]} \n"
              //     'Blood Pressure Status : ${analysisDataFromJson(eventData).bloodPressureStatus} \n'
              //     'Stress Status : ${analysisDataFromJson(eventData).stressStatus} \n'
              // );

              print("isMoveWarning $isMoveWarning");

              if (isMoveWarning.isTrue){
                Get.snackbar(
                  "Don't move your face",
                  "Please keep your face in front of camera",
                  colorText: Colors.white,
                  backgroundColor: Colors.lightBlue,
                  icon: const Icon(Icons.add_alert),
                );
              }
            });
          } on PlatformException {
            invokeResult.value = 'Failed streamStartAnalysis.';
          }
        }
        break;

      case "stopAnalysis":
        {
          try {
            rppgCommonPlugin.stopAnalysis();
          } on PlatformException {
            invokeResult.value = 'Failed stopAnalysis.';
          }
        }
        break;

      case "cleanMesh":
        {
          try {
            rppgCommonPlugin.cleanMesh();
          } on PlatformException {
            invokeResult.value = 'Failed cleanMesh.';
          }
        }
        break;

      case "meshColor":
        {
          try {
            rppgCommonPlugin.meshColor();
          } on PlatformException {
            invokeResult.value = 'Failed meshColor.';
          }
        }
        break;

      case "beginSession":
        {
          try {
            rppgCommonPlugin.beginSession();
          } on PlatformException {
            invokeResult.value = 'Failed beginSession.';
          }
        }
        break;

      default:
        {
          log("Invalid choice");
        }
        break;
    }
  }

  startSession() async {
    await invokeMethod("getState");
    switch (rppgFacadeState.value) {
      case "initial":
        {
          log('---------RPPGFacade in ${rppgFacadeState.value} state----------');
          invokeMethod("askPermissions");
          if (resultPermissions.value == true) {
            invokeMethod("configure");
            log('---------RPPGFacade in ${rppgFacadeState.value} state----------');
          }
          updateButtonTitle();
        }
        break;
      case "prepared":
        {
          log('---------RPPGFacade in ${rppgFacadeState.value} state----------');
          invokeMethod("startVideo");
          updateButtonTitle();
        }
        break;
      case "videoStarted":
        {
          log('---------RPPGFacade in ${rppgFacadeState.value} state----------');
          invokeMethod("streamStartAnalysis");
          invokeMethod("meshColor");
          updateButtonTitle();
        }
        break;
      case "analysisRunning":
        {
          log('---------RPPGFacade in ${rppgFacadeState.value} state----------');
          invokeMethod("stopAnalysis");
          invokeMethod("cleanMesh");
          updateButtonTitle();
        }
        break;
      default:
        {
          log("default");
          updateButtonTitle();
        }
        break;
    }
  }

  updateButtonTitle() async {
    rppgFacadeState.value = await rppgCommonPlugin.getState();
    switch (rppgFacadeState.value) {
      case "initial":
        {
          buttonTitle.value = "Ask for Permissions";
        }
        break;
      case "prepared":
        {
          buttonTitle.value = "Start Video Session";
        }
        break;
      case "videoStarted":
        {
          buttonTitle.value = "Start Scanning";
        }
        break;
      case "analysisRunning":
        {
          buttonTitle.value = "Stop Scanning";
        }
        break;
      case "fail":
        {
          buttonTitle.value = "Fail";
          log("fail in updateButtonTitle");
        }
        break;
      default:
        {
          buttonTitle.value = "Please Wait...";
        }
        break;
    }
  }
}
