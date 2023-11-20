// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart' as imagestore;

class ThumbnailRequest {
  final String video;
  final String thumbnailPath;
  // final imageFormat.ImageFormat imageFormatRequest;
  final int maxHeight;
  final int maxWidth;
  final int timeMs;
  final int quality;

  const ThumbnailRequest(
      {required this.video,
      required this.thumbnailPath,
      required this.maxHeight,
      required this.maxWidth,
      required this.timeMs,
      required this.quality});
}

class ThumbnailResult {
  final imagestore.Image image;
  final int dataSize;
  final int height;
  final int width;
  const ThumbnailResult(
      {required this.image,
      required this.dataSize,
      required this.height,
      required this.width});
}
