import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../utils/theme/theme.dart';


class VideoPlayer extends StatefulWidget {
  @override
  final String path;

  const VideoPlayer({
    Key? key,
    required this.path,
    required this.Title,
  }) : super(key: key);

  final String Title;

  @override
  State<StatefulWidget> createState() {
    return _VideoPlayerState();
  }
}

class _VideoPlayerState extends State<VideoPlayer> {
  TargetPlatform? _platform;
  VideoPlayerController? _videoPlayerController1;
  ChewieController? _chewieController;
  int? bufferDelay;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    //AutoOrientation.landscapeAutoMode();
    super.initState();

    initializePlayer();
    //print(widget.filePath);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //AutoOrientation.portraitAutoMode();
    _videoPlayerController1!.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    var dir = await getApplicationCacheDirectory();
    var filePath =
        join(dir.path, '${widget.path.split('/').last.split('.').first}.mp4');

    debugPrint(
        'File Path is - $filePath and does file exists - ${File(filePath).existsSync()}');
    if (File(filePath).existsSync()) {
      debugPrint(
          'File Path for offline is - $filePath and does file exists - ${File(filePath).existsSync()}');
      _videoPlayerController1 = VideoPlayerController.file(File(filePath))
        ..initialize().then((_) {
          isLoading = false;
          setState(() {
            _videoPlayerController1!.play();
          });
        });
    } else {
      _videoPlayerController1 =
          VideoPlayerController.networkUrl(Uri.parse(widget.path))
            ..initialize().then((_) {
              isLoading = false;
              setState(() {
                _videoPlayerController1!.play();
              });
            });
    }
    /*_videoPlayerController1!.addListener(() {
      if (_videoPlayerController1!.value.isInitialized) {
        //_videoPlayerController1.play();
        *//*setState(() {
          isLoading = false;
        });*//*
      }
    });*/
    //_createChewieController();
  }

  void _createChewieController() async {
    var subtitles = [
      Subtitle(
        index: 0,
        start: Duration.zero,
        end: const Duration(seconds: 10),
        text: const TextSpan(
          children: [
            TextSpan(
              text: '',
              style: TextStyle(color: Colors.red, fontSize: 22),
            ),
          ],
        ),
      ),
      Subtitle(
        index: 0,
        start: const Duration(seconds: 10),
        end: const Duration(seconds: 20),
        text: '',
      ),
    ];

    _chewieController = _videoPlayerController1!.value.isInitialized
        ? ChewieController(
            videoPlayerController: _videoPlayerController1!,
            allowedScreenSleep: false,
            isLive: false,
            autoInitialize: true,
            showOptions: false,
            zoomAndPan: true,
            autoPlay: true,
            allowFullScreen: false,
            allowPlaybackSpeedChanging: true,
            showControlsOnInitialize: true,
            /*
      autoPlay: true,
      looping: true,
      isLive: false,
      autoInitialize: true,
      showOptions: false,
      zoomAndPan: true,
      showControlsOnInitialize: true,
      showControls: true,*/
            aspectRatio: 4 / 2,
            routePageBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondAnimation,
                provider) {
              return AnimatedBuilder(
                animation: animation,
                builder: (BuildContext context, Widget? child) {
                  return VideoScaffold(
                    key: widget.key,
                    child: Scaffold(
                      resizeToAvoidBottomInset: true,
                      body: Container(
                        alignment: Alignment.center,
                        color: Colors.black,
                        child: provider,
                      ),
                    ),
                  );
                },
              );
            },
            progressIndicatorDelay: bufferDelay != null
                ? Duration(milliseconds: bufferDelay!)
                : null,
            subtitle: Subtitles(subtitles),
            subtitleBuilder: (context, dynamic subtitle) => Container(
              padding: const EdgeInsets.all(10.0),
              child: subtitle is InlineSpan
                  ? RichText(
                      text: subtitle,
                    )
                  : Text(
                      subtitle.toString(),
                      style: const TextStyle(color: Colors.black),
                    ),
            ),
            hideControlsTimer: const Duration(seconds: 1),
          )
        : null;
  }

  int currPlayIndex = 0;

  Future<void> toggleVideo() async {
    print('toggleVideo ===================');
    await _videoPlayerController1!.pause();
    currPlayIndex = 0;
    await initializePlayer();
  }

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    _createChewieController();
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: MaterialApp(
        title: widget.Title,
        /*theme: AppTheme.grey l ight.copyWith(
          platform: _platform ?? Theme.of(context).platform,
        ),*/
        home: Scaffold(
            body: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              child: Center(
                child: (!isLoading &&
                        _chewieController !=
                            null) /*&&
                    _chewieController!
                        .videoPlayerController.value.isInitialized*/
                    ? Chewie(
                        controller: _chewieController!,
                      )
                    : Center(child: Lottie.asset('assets/json/kidzee_loader.json')) /*const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text('Loading'),
                        ],
                      )*/,
              ),
            ),
            Positioned(
                top: 60,
                left: 15,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    "assets/icons/ic_left_arrow.png",
                    width: 30,
                  ),
                )),
          ],
        )),
      ),
    );
  }
}

class DelaySlider extends StatefulWidget {
  const DelaySlider({Key? key, required this.delay, required this.onSave})
      : super(key: key);

  final int? delay;
  final void Function(int?) onSave;

  @override
  State<DelaySlider> createState() => _DelaySliderState();
}

class _DelaySliderState extends State<DelaySlider> {
  int? delay;
  bool saved = false;

  @override
  void initState() {
    super.initState();
    delay = widget.delay;
  }

  @override
  Widget build(BuildContext context) {
    const int max = 1000;
    return ListTile(
      title: Text(
        "Progress indicator delay ${delay != null ? "${delay.toString()} MS" : ""}",
      ),
      subtitle: Slider(
        value: delay != null ? (delay! / max) : 0,
        onChanged: (value) async {
          delay = (value * max).toInt();
          /*setState(() {
            saved = false;
          });*/
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.save),
        onPressed: saved
            ? null
            : () {
                widget.onSave(delay);
                /*setState(() {
                  saved = true;
                });*/
              },
      ),
    );
  }
}

class VideoScaffold extends StatefulWidget {
  const VideoScaffold({required Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _VideoScaffoldState();
}

class _VideoScaffoldState extends State<VideoScaffold> {
  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
