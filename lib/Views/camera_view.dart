import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = 'rppg_native_camera';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};


    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const Scaffold(
          body: Text("Android camera is not implemented yet."),
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      default:
        return Scaffold(
          body: Center(
            child: ElevatedButton.icon(
              onPressed: (){
                setState(() {
                  log("Refresh");
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
            ),
          ),
        );
    }

  }
}
