// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:ekidzee/pages/bpms/utils/thumnailModel.dart' as thumbnailModel;
// import 'package:ekidzee/pages/bpms/utils/thumnailModel.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/material.dart' as imagestore;
// import 'package:path_provider/path_provider.dart';
// // import 'package:video_thumbnail/video_thumbnail.dart';

// class GEtThumbNail {
//   static Future<thumbnailModel.ThumbnailResult> genThumbnail(
//       String videoUrl) async {
//     final dir = await getApplicationDocumentsDirectory();
//     ThumbnailRequest thumbnailRequest = ThumbnailRequest(
//         video: videoUrl,
//         thumbnailPath: dir.path,
//         maxHeight: 90,
//         maxWidth: 90,
//         timeMs: 0,
//         quality: 10);
//     Uint8List? bytes;
//     final Completer<ThumbnailResult> completer = Completer();

//     final thumbnailPath = await VideoThumbnail.thumbnailFile(
//         video: thumbnailRequest.video,
//         /*  headers: {
//           "USERHEADER1": "user defined header1",
//           "USERHEADER2": "user defined header2",
//         }, */
//         thumbnailPath: thumbnailRequest.thumbnailPath,
//         // imageFormat: thumbnailRequest.imageFormatRequest,
//         maxHeight: thumbnailRequest.maxHeight,
//         maxWidth: thumbnailRequest.maxWidth,
//         timeMs: thumbnailRequest.timeMs,
//         quality: thumbnailRequest.quality);

//     print("thumbnail file is located: $thumbnailPath");

//     final file = File(thumbnailPath ?? '');
//     bytes = file.readAsBytesSync();
//     int imageDataSize = bytes.length;
//     print("image size: $imageDataSize");

//     final imagestore.Image image = imagestore.Image.memory(bytes);
//     image.image
//         .resolve(const ImageConfiguration())
//         .addListener(ImageStreamListener((ImageInfo info, bool _) {
//       completer.complete(ThumbnailResult(
//         image: image,
//         dataSize: imageDataSize,
//         height: info.image.height,
//         width: info.image.width,
//       ));
//     }));
//     return completer.future;
//   }
// }
