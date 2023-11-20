/*
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraScreenChangeNotifier extends ChangeNotifier {
  var camera;

  Future<List<CameraDescription>> getAllAvailableCameras() async {
    camera = await availableCameras();

    notifyListeners();

    return camera;
  }
}

var cameraScreenProvider =
    ChangeNotifierProvider((ref) => CameraScreenChangeNotifier());
*/
