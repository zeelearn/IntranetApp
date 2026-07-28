import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class LocalPdfViewerPage extends StatelessWidget {
  final String filePath;
  final String title;

  const LocalPdfViewerPage({
    super.key,
    required this.filePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: PdfViewer.file(filePath),
    );
  }
}
