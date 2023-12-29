import 'package:flutter/material.dart';
import 'package:rppg_common/rppg_common.dart';


class CustomView extends StatefulWidget {
  const CustomView({super.key});

  @override
  State<CustomView> createState() => _CustomViewState();
}

class _CustomViewState extends State<CustomView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Camera View'),
      ),
      body: const Stack(
        children: [

          CameraView(),
        ],
      ),
    );
  }
}
