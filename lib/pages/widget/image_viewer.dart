import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class ImageViewer extends StatelessWidget {
  final String imageUrl;

  const ImageViewer({Key? key, required this.imageUrl}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    print('image is '+imageUrl);
    return Scaffold(
      body: GestureDetector(
        child: PinchZoom(
          maxScale: 4,
              zoomEnabled: true,
              child: Center(
                child: imageUrl.toLowerCase().contains('data/') ? Image.file(File(imageUrl),
                  // fit image in its width and height
                  fit: BoxFit.fill,
                  // set the alignment of image
                  alignment: Alignment.center,
                ) : FadeInImage(
                  width: MediaQuery.of(context).size.width,
                  placeholder: AssetImage('assets/icons/ic_no_img_uploaded.png'),
                  image: NetworkImage(imageUrl),
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/icons/ic_alerts.png',
                        fit: BoxFit.fitWidth);
                  },
                  fit: BoxFit.cover,
                ),
              ),
              /*resetDuration: const Duration(milliseconds: 100),*/
              onZoomStart: (){print('Start zooming');},
              onZoomEnd: (){print('Stop zooming');},
            ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}