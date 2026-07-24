import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'local_pdf_viewer.dart';

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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        if (await controller?.canGoBack() ?? false) {
          controller?.goBack();
        } else {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CVF Report'),
        ),
        body: Column(
          children: [
            if (progress < 1.0) LinearProgressIndicator(value: progress),
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
                onDownloadStartRequest:
                    (controller, downloadStartRequest) async {
                  debugPrint(
                      'Download started: ${downloadStartRequest.toJson()}');
                  final url = downloadStartRequest.url;
                  if (url.scheme == 'blob') {
                    final String jsCode = """
                      (async function() {
                        try {
                          const response = await fetch('${url.toString()}');
                          const blob = await response.blob();
                          const reader = new FileReader();
                          reader.onloadend = function() {
                            const base64data = reader.result;
                            window.flutter_inappwebview.callHandler(
                              'blobDownloaded',
                              base64data,
                              '${downloadStartRequest.suggestedFilename ?? 'download.pdf'}',
                              '${downloadStartRequest.mimeType ?? 'application/octet-stream'}'
                            );
                          };
                          reader.readAsDataURL(blob);
                        } catch (e) {
                          console.error('Blob download failed:', e);
                        }
                      })();
                    """;
                    await controller.evaluateJavascript(source: jsCode);
                  } else {
                    await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                onWebViewCreated: (c) {
                  controller = c;
                  c.addJavaScriptHandler(
                    handlerName: 'blobDownloaded',
                    callback: (args) async {
                      if (args.isEmpty) return;
                      final String base64Data = args[0] as String;
                      final String suggestedFilename = args[1] as String;
                      final String mimeType = args[2] as String;

                      try {
                        final String base64String = base64Data.split(',').last;
                        final Uint8List bytes = base64Decode(base64String);

                        final Directory directory = Platform.isIOS
                            ? await getApplicationDocumentsDirectory()
                            : (await getExternalStorageDirectory() ??
                                await getApplicationDocumentsDirectory());

                        final String filePath =
                            '${directory.path}/$suggestedFilename';
                        final File file = File(filePath);
                        await file.writeAsBytes(bytes);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('File downloaded: $suggestedFilename'),
                              action: SnackBarAction(
                                label: 'View',
                                onPressed: () {
                                  if (mimeType == 'application/pdf' ||
                                      suggestedFilename.endsWith('.pdf')) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LocalPdfViewerPage(
                                          filePath: filePath,
                                          title: suggestedFilename,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );

                          if (mimeType == 'application/pdf' ||
                              suggestedFilename.endsWith('.pdf')) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocalPdfViewerPage(
                                  filePath: filePath,
                                  title: suggestedFilename,
                                ),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save download: $e'),
                            ),
                          );
                        }
                      }
                    },
                  );
                },
                shouldOverrideUrlLoading: (controller, navigationAction) {
                  var uri = navigationAction.request.url!;

                  if (![
                    "http",
                    "https",
                    "file",
                    "chrome",
                    "data",
                    "javascript",
                    "about",
                    "blob"
                  ].contains(uri.scheme)) {
                    launchUrl(
                      Uri.parse(uri.toString()),
                      mode: LaunchMode.platformDefault,
                    );
                    return Future.value(NavigationActionPolicy.CANCEL);
                  }

                  return Future.value(NavigationActionPolicy.ALLOW);
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
      ),
    );
  }
}
