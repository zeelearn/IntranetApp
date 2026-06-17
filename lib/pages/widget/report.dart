import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CVFReportWebView extends StatefulWidget {
  final String url;

  const CVFReportWebView({
    super.key,
    required this.url,
  });

  @override
  State<CVFReportWebView> createState() => _CVFReportWebViewState();
}

class _CVFReportWebViewState extends State<CVFReportWebView> {
  InAppWebViewController? controller;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CVF Report'),
      ),
      body: Column(
        children: [
          if (progress < 1.0)
            LinearProgressIndicator(value: progress),

          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(widget.url),
              ),

              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
              ),

              onWebViewCreated: (c) {
                controller = c;
              },

              onProgressChanged: (controller, value) {
                setState(() {
                  progress = value / 100;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}