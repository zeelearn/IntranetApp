import 'package:Intranet/pages/helper/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class MyWebsiteView extends StatefulWidget {
  String url;
  String title;
  MyWebsiteView({Key? key,required this.title,required this.url}) : super(key: key);

  @override
  MyWebsiteViewState createState() => MyWebsiteViewState();
}

class MyWebsiteViewState extends State<MyWebsiteView> {

  InAppWebViewController? webViewController;
  final urlController = TextEditingController();
  String url = "";

  bool isUrlLoadingCompleted = true;
  double progress = 0;

  final GlobalKey webViewKey = GlobalKey();
  PullToRefreshController? pullToRefreshController;

  @override
  void initState() {
    super.initState();
  
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Lottie.asset('assets/json/loading.json'),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.url);
    return Scaffold(
              appBar: widget.title.isEmpty || widget.title == 'Parent Support Desk' ||
                  widget.title == 'ZLLSaathi'
              ? null
              : AppBar(
                  backgroundColor: kPrimaryLightColor,
                  leadingWidth: 30,
                  title: Text(
                    widget.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: Colors.white),
                  ), // You can add title here
                  leading: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () async {
                        Navigator.pop(context);
                        // WebViewController webViewController =
                        //     await _controller.future;
                        // if (await webViewController.canGoBack()) {
                        //   webViewController.goBack();
                        // } else {
                        //   Navigator.pop(context);
                        // }
                      },
                    ),
                  ), //You can make this transparent
                  elevation: 0.0, //No shadow
                ),
      backgroundColor: Colors.white,
      body:InAppWebView(
                  key: webViewKey,
                  initialUrlRequest:
                      URLRequest(url: Uri.parse(widget.url)),
                  // initialSettings: settings,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  /* onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                        resources: request.resources,
                        action: PermissionResponseAction.GRANT);
                  }, */
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      if (await canLaunchUrl(uri)) {
                        // Launch the App
                        await launchUrl(
                          uri,
                        );
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController?.endRefreshing();
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  /* onReceivedError: (controller, request, error) {
                    pullToRefreshController?.endRefreshing();
                  }, */
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController?.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    if (kDebugMode) {
                      print(consoleMessage);
                    }
                  },
                ) /* WebViewWidget(controller: _controller) */,
    );
  }
  

}