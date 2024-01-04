import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rppg_common/rppg_common.dart';
import 'invoke_methods_controller.dart';

void main() {
  runApp(const GetMaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final InvokeMethodController invokeMethodController;

  @override
  void initState() {
    super.initState();
    // initialStep();

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return;
      case TargetPlatform.iOS:
        initialStep();
      default:
        return;
    }
  }

  Future<void> initialStep() async {
    try {
      invokeMethodController = Get.find<InvokeMethodController>();
      Get.delete<InvokeMethodController>();
      invokeMethodController = Get.put(InvokeMethodController());
    } catch (e) {
      invokeMethodController = Get.put(InvokeMethodController());
    }

    await invokeMethodController.startWholeSession();
  }

  double? fontSizeVar = 14.00;
  Color? fontColorVar = Colors.white;

  List<String> dataList = [];

  @override
  Widget build(BuildContext context) {
    // return
    //   Scaffold(
    //   extendBodyBehindAppBar: false,
    //   // appBar: AppBar(
    //   //   leading: IconButton(
    //   //     icon: const Icon(Icons.arrow_back, color: Colors.black),
    //   //     onPressed: () => log("Back button Pressed..."),
    //   //   ),
    //   //   title: const SizedBox(),
    //   //   backgroundColor: Colors.transparent,
    //   // ),
    //   body: Obx(
    //     () => Stack(
    //       // alignment: AlignmentDirectional.bottomCenter,
    //       children: [
    //         /// Black Empty Container
    //         Container(color: Colors.black,),
    //
    //         /// Camera View
    //         const CameraView(),
    //
    //         /// Button
    //         if (invokeMethodController.rppgFacadeState.value == "analysisRunning") Positioned(
    //           child: Align(
    //             alignment: Alignment.bottomCenter,
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.end,
    //               children: [
    //                 /// Bottom Part
    //                 if (invokeMethodController.rppgFacadeState.value == "analysisRunning") Container(
    //                   padding: const EdgeInsets.all(13.0),
    //                   color: Colors.white12,
    //                   alignment: Alignment.center,
    //                   width: MediaQuery.of(context).size.width,
    //                   height: 175,
    //                   child: Row(
    //                     children: <Widget>[
    //                       Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           mainAxisAlignment: MainAxisAlignment.start,
    //                           children: [
    //                             Text(
    //                               invokeMethodController.avgBpm.value,
    //                               style: TextStyle(color: fontColorVar, fontWeight: FontWeight.bold, fontSize: fontSizeVar),
    //                             ),
    //                             const SizedBox(
    //                               height: 8,
    //                             ),
    //                             Text(
    //                               invokeMethodController.avgO2SaturationLevel.value,
    //                               style: TextStyle(color: fontColorVar, fontWeight: FontWeight.bold, fontSize: fontSizeVar),
    //                             ),
    //                             const SizedBox(
    //                               height: 8,
    //                             ),
    //                             Text(
    //                               invokeMethodController.avgRespirationRate.value,
    //                               style: TextStyle(color: fontColorVar, fontWeight: FontWeight.bold, fontSize: fontSizeVar),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                       const SizedBox(width: 15,),
    //                       Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           mainAxisAlignment: MainAxisAlignment.start,
    //                           children: [
    //                             Text(
    //                               invokeMethodController.bloodPressure.value,
    //                               style: TextStyle(color: fontColorVar, fontWeight: FontWeight.bold, fontSize: fontSizeVar),
    //                             ),
    //                             const SizedBox(
    //                               height: 8,
    //                             ),
    //                             Text(
    //                               invokeMethodController.bloodPressureStatus.value,
    //                               style: TextStyle(color: fontColorVar, fontWeight: FontWeight.bold, fontSize: fontSizeVar),
    //                             ),
    //                             const SizedBox(
    //                               height: 8,
    //                             ),
    //                             Text(
    //                               invokeMethodController.stressStatus.value,
    //                               style: TextStyle(color: fontColorVar, fontWeight: FontWeight.bold, fontSize: fontSizeVar),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //
    //                 const SizedBox(height: 10,),
    //
    //                 SizedBox(
    //                   width: 200,
    //                   height: 60,
    //                   child: Column(
    //                     children: [
    //                       TextButton(
    //                         style: ButtonStyle(
    //                             backgroundColor: MaterialStateProperty.all(Colors.indigo),
    //                             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //                                 RoundedRectangleBorder(
    //                                     borderRadius: BorderRadius.circular(18.0),
    //                                 )
    //                             )
    //                         ),
    //                         onPressed: () {
    //                           invokeMethodController.invokeMethod("stopAnalysis");
    //                           invokeMethodController.invokeMethod("cleanMesh");
    //                           invokeMethodController.updateButtonTitle();
    //                         },
    //                         child: const Text(
    //                           "Stop Scanning",
    //                           style: TextStyle(color: Colors.white),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ) else Positioned(
    //           child: Align(
    //             alignment: Alignment.bottomCenter,
    //             child: SizedBox(
    //               width: 200,
    //               height: 80,
    //               child: Column(
    //                 children: [
    //                   TextButton(
    //                     style: ButtonStyle(
    //                         backgroundColor: MaterialStateProperty.all(Colors.indigo),
    //                         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //                             RoundedRectangleBorder(
    //                                 borderRadius: BorderRadius.circular(18.0),
    //                             ),
    //                         ),
    //                     ),
    //                     child: Text(
    //                       invokeMethodController.buttonTitle.value,
    //                       style: const TextStyle(color: Colors.white),
    //                     ),
    //                     onPressed: () {
    //                       invokeMethodController.startSession();
    //                     },
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const Scaffold(
          body: Center(child: Text("Android is working...")),
        );
      case TargetPlatform.iOS:
        return Scaffold(
          extendBodyBehindAppBar: false,
          // appBar: AppBar(
          //   leading: IconButton(
          //     icon: const Icon(Icons.arrow_back, color: Colors.black),
          //     onPressed: () => log("Back button Pressed..."),
          //   ),
          //   title: const SizedBox(),
          //   backgroundColor: Colors.transparent,
          // ),
          body: Obx(
                () => Stack(
              // alignment: AlignmentDirectional.bottomCenter,
              children: [
                /// Black Empty Container
                Container(color: Colors.black,),

                /// Camera View
                const CameraView(),

                /// Button
                if (invokeMethodController.rppgFacadeState.value == "analysisRunning") Positioned(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        /// Bottom Part
                        if (invokeMethodController.rppgFacadeState.value == "analysisRunning") Container(
                          padding: const EdgeInsets.all(13.0),
                          color: Colors.white12,
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          height: 175,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      invokeMethodController.avgBpm.value,
                                      style: TextStyle(color: fontColorVar, fontWeight: FontWeight.bold, fontSize: fontSizeVar),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      invokeMethodController.avgO2SaturationLevel.value,
                                      style: TextStyle(color: fontColorVar, fontWeight: FontWeight.bold, fontSize: fontSizeVar),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      invokeMethodController.avgRespirationRate.value,
                                      style: TextStyle(color: fontColorVar, fontWeight: FontWeight.bold, fontSize: fontSizeVar),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      invokeMethodController.bloodPressure.value,
                                      style: TextStyle(color: fontColorVar, fontWeight: FontWeight.bold, fontSize: fontSizeVar),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      invokeMethodController.bloodPressureStatus.value,
                                      style: TextStyle(color: fontColorVar, fontWeight: FontWeight.bold, fontSize: fontSizeVar),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      invokeMethodController.stressStatus.value,
                                      style: TextStyle(color: fontColorVar, fontWeight: FontWeight.bold, fontSize: fontSizeVar),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10,),

                        SizedBox(
                          width: 200,
                          height: 60,
                          child: Column(
                            children: [
                              TextButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Colors.indigo),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18.0),
                                        )
                                    )
                                ),
                                onPressed: () {
                                  invokeMethodController.invokeMethod("stopAnalysis");
                                  invokeMethodController.invokeMethod("cleanMesh");
                                  invokeMethodController.updateButtonTitle();
                                },
                                child: const Text(
                                  "Stop Scanning",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ) else Positioned(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: 200,
                      height: 80,
                      child: Column(
                        children: [
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.indigo),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                              ),
                            ),
                            child: Text(
                              invokeMethodController.buttonTitle.value,
                              style: const TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              invokeMethodController.startSession();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return const Scaffold(
          body: Center(child: Text("Default Platfrom is Working...")),
        );
    }
  }

  @override
  void dispose() {
    invokeMethodController.invokeMethod("stopAnalysis");
    invokeMethodController.invokeMethod("cleanMesh");
    invokeMethodController.updateButtonTitle();

    Get.delete<InvokeMethodController>();
    // TODO: implement dispose
    super.dispose();
  }
}
