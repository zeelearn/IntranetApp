import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'CameraView.dart';
import 'VideoView.dart';

List<CameraDescription>? cameras;

class CameraScreen extends StatefulWidget {
  final taskName;
  const CameraScreen({this.taskName, Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  Future<void>? cameraValue;
  bool isRecoring = false;
  bool isInilise = false;
  bool flash = false;
  bool iscamerafront = true;
  double transform = 0;

  String recordingTime = '0:0'; // to store value
  bool isRecording = false;

  void recordTime() {
    var startTime = DateTime.now();
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      var diff = DateTime.now().difference(startTime);

      recordingTime =
          '${diff.inHours < 60 ? diff.inHours : 0}:${diff.inMinutes < 60 ? diff.inMinutes : 0}:${diff.inSeconds < 60 ? diff.inSeconds : 0}';

      print(recordingTime);

      if (!isRecoring) {
        t.cancel(); //cancel function calling
      }

      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();

    initCamera();
  }

  initCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    cameraValue = _cameraController.initialize();
    setState(() {
      isInilise = true;
    });
  }

  File changefilenameonlysync(File file, String newfilename) {
    var path = file.path;
    var lastseperator = path.lastIndexOf(Platform.pathSeparator);
    var newpath =
        '${path.substring(0, lastseperator + 1)}${newfilename.replaceAll(' ', '').replaceAll('/', '_')}.mp4';
    return file.renameSync(newpath);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !isInilise
          ? const Text('loading..')
          : Stack(
              children: [
                FutureBuilder(
                    future: cameraValue,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: CameraPreview(_cameraController));
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
                Positioned(
                  top: 10,
                  left: 10,
                  child: isRecoring
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: _cameraController.value.isRecordingVideo
                                  ? Colors.redAccent
                                  : Colors.grey,
                              width: 3.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(recordingTime,
                                    style: const TextStyle(
                                        fontSize: 28.0, color: Colors.red))),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Positioned(
                  bottom: 0.0,
                  child: Container(
                    color: Colors.black,
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                                icon: Icon(
                                  flash ? Icons.flash_on : Icons.flash_off,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () {
                                  setState(() {
                                    flash = !flash;
                                  });
                                  flash
                                      ? _cameraController
                                          .setFlashMode(FlashMode.torch)
                                      : _cameraController
                                          .setFlashMode(FlashMode.off);
                                }),
                            GestureDetector(
                              onLongPress: () async {
                                await _cameraController
                                    .prepareForVideoRecording();
                                await _cameraController
                                    .startVideoRecording()
                                    .then((value) {
                                  recordTime();
                                });
                                setState(() {
                                  isRecoring = true;
                                });
                              },
                              onLongPressUp: () async {
                                try {
                                  XFile xFilevideopath = await _cameraController
                                      .stopVideoRecording();

                                  File videopath = changefilenameonlysync(
                                      File(xFilevideopath.path),
                                      widget.taskName);

                                  debugPrint(
                                      'New video name is - ${videopath.path}');

                                  // timerReset();
                                  setState(() {
                                    isRecoring = false;
                                  });
                                  if (!mounted) return;

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) => VideoViewPage(
                                                path: videopath.path,
                                              ))).then((value) {
                                    Navigator.pop(context, videopath.path);
                                  });
                                } catch (e) {
                                  setState(() {
                                    isRecoring = false;
                                  });
                                  debugPrint(
                                      'Error while stopping camera is - $e');
                                }

                                /* Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => VideoViewPage(
                                              path: videopath.path,
                                            ))); */
                              },
                              onTap: () {
                                if (!isRecoring) takePhoto(context);
                              },
                              child: isRecoring
                                  ? const Icon(
                                      Icons.radio_button_on,
                                      color: Colors.red,
                                      size: 80,
                                    )
                                  : const Icon(
                                      Icons.panorama_fish_eye,
                                      color: Colors.white,
                                      size: 70,
                                    ),
                            ),
                            IconButton(
                                icon: Transform.rotate(
                                  angle: transform,
                                  child: const Icon(
                                    Icons.flip_camera_ios,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    iscamerafront = !iscamerafront;
                                    transform = transform + pi;
                                  });
                                  int cameraPos = iscamerafront ? 0 : 1;
                                  _cameraController = CameraController(
                                      cameras![cameraPos],
                                      ResolutionPreset.high);
                                  cameraValue = _cameraController.initialize();
                                }),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        const Text(
                          "Hold for Video, tap for photo",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void takePhoto(BuildContext context) async {
    XFile file = await _cameraController.takePicture();
    var result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CameraViewPage(
        path: file.path,
      );
    }));
    Navigator.pop(context, result);

    /*Navigator.push(
        context,
        MaterialPageRoute(
            builder: (builder) => CameraViewPage(
                  path: file.path,
                )));*/
  }
}
