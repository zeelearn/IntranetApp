import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfrx/pdfrx.dart';

class PdfDocummentViewer extends StatefulWidget {
  final String requestId;
  final String requestName;

  const PdfDocummentViewer({
    super.key,
    required this.requestId,
    required this.requestName
  });

  @override
  State<PdfDocummentViewer> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfDocummentViewer> {
  bool isLoading = true;
  String? error;
  Uint8List? pdfBytes;

  @override
  void initState() {
    super.initState();
    fetchPdf();
  }

  Future<void> fetchPdf() async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://kubapi.zeelearn.com/V1/commonapi/api/bp/getpdfdocument',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "request_id": widget.requestId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          pdfBytes = response.bodyBytes;

          // If API returns base64:
          // pdfBytes = base64Decode(response.body);

          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(widget.requestName),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Text(error!),
                )
              : PdfViewer.data(
                  pdfBytes!,
                  sourceName: 'PDF',
                ),
    );
  }
}