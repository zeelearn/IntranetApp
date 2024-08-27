import 'package:Intranet/pages/helper/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/src/types/web_resource_error.dart'
    as webview_flutter_platform_interface;
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class MyWebsiteView extends StatefulWidget {
  String url;
  String title;
  MyWebsiteView({super.key, required this.title, required this.url});

  @override
  MyWebsiteViewState createState() => MyWebsiteViewState();
}

class MyWebsiteViewState extends State<MyWebsiteView> {
  // WebViewController? _controller;
  // final Completer<WebViewController> controller =
  //     Completer<WebViewController>();
  late final WebViewController _controller;

  bool isUrlLoadingCompleted = true;
  double progress = 0;

  final GlobalKey webViewKey = GlobalKey();

  // InAppWebViewController? webViewController;
  // InAppWebViewSettings settings = InAppWebViewSettings(
  //     isInspectable: kDebugMode,
  //     mediaPlaybackRequiresUserGesture: false,
  //     allowFileAccess: true,
  //     allowsInlineMediaPlayback: true,
  //     iframeAllow: "camera; microphone",
  //     iframeAllowFullscreen: true);

  // PullToRefreshController? pullToRefreshController;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    print('web url ${widget.title}');
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            //Utility.showLoader();
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            //Navigator.of(context, rootNavigator: true).pop('dialog');
          },
          onWebResourceError:
              (webview_flutter_platform_interface.WebResourceError error) {
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('Error occurred on page: ${error.response?.statusCode}');
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
          onHttpAuthRequest: (HttpAuthRequest request) {
            debugPrint('url change to $request');
            //openDialog(request);
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.url));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;

    // pullToRefreshController = kIsWeb ||
    //         ![TargetPlatform.iOS, TargetPlatform.android]
    //             .contains(defaultTargetPlatform)
    //     ? null
    //     : PullToRefreshController(
    //         settings: PullToRefreshSettings(
    //           color: Colors.blue,
    //         ),
    //         onRefresh: () async {
    //           if (defaultTargetPlatform == TargetPlatform.android) {
    //             webViewController?.reload();
    //           } else if (defaultTargetPlatform == TargetPlatform.iOS ||
    //               defaultTargetPlatform == TargetPlatform.macOS) {
    //             webViewController?.loadUrl(
    //                 urlRequest:
    //                     URLRequest(url: await webViewController?.getUrl()));
    //           }
    //         },
    //       );
    // Enable hybrid composition.
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Lottie.asset('assets/json/kidzee_loader.json'),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  InAppWebViewController? webViewController;
  /*  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true); */

  PullToRefreshController? pullToRefreshController;
  String url = "";

  @override
  Widget build(BuildContext context) {
    print(widget.url);
    return Scaffold(
      appBar: widget.title.isEmpty ||
              widget.title == 'Parent Support Desk' ||
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
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
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
      body: InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
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
        shouldOverrideUrlLoading: (controller, navigationAction) async {
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
        onDownloadStartRequest: (controller, downloadStartRequest) async {
          debugPrint('Download is getting called - $downloadStartRequest');
          final taskId = await FlutterDownloader.enqueue(
            url: downloadStartRequest.url.toString(),
            savedDir: (await getExternalStorageDirectory())!.path,
            showNotification:
                true, // show download progress in status bar (for Android)
            openFileFromNotification:
                true, // click on notification to open downloaded file (for Android)
          );
          /* await canLaunchUrl(downloadStartRequest.url)
              ? await launchUrl(downloadStartRequest.url)
              : throw 'Could not launch ${downloadStartRequest.url}'; */
        },
      ) /* WebViewWidget(controller: _controller) */,
    );
  }

//   @override
//   Widget build(BuildContext context){
//     return Container(child:
//     InAppWebView(
//       key: webViewKey,
//       initialOptions: InAppWebViewGroupOptions(
//         crossPlatform: InAppWebViewOptions(
//             allowFileAccessFromFileURLs: true,
//             cacheEnabled: true,
//             supportZoom: true,
//             useOnDownloadStart: true,
//           javaScriptEnabled: true
//         ),
//       ),
//       initialUrlRequest: URLRequest(url: WebUri('https://google.com')),
//       // initialUrlRequest:
//       // URLRequest(url: WebUri(Uri.base.toString().replaceFirst("/#/", "/") + 'page.html')),
//        initialFile: "assets/index.html",
// //      initialUserScripts: UnmodifiableListView<UserScript>([]),

//   //    initialSettings: settings,
//       initialData: InAppWebViewInitialData(data: "<html>please wait</html>"),
//       //pullToRefreshController: pullToRefreshController,
//       onWebViewCreated: (controller) async {
//         webViewController = controller;
//       },
//       onLoadStart: (controller, url) async {
//         // setState(() {
//         //   this.url = url.toString();
//         //   urlController.text = this.url;
//         // });
//       },
//       onPermissionRequest: (controller, request) async {
//         return PermissionResponse(
//             resources: request.resources,
//             action: PermissionResponseAction.GRANT);
//       },
//       shouldOverrideUrlLoading:
//           (controller, navigationAction) async {
//         var uri = navigationAction.request.url!;

//         if (![
//           "http",
//           "https",
//           "file",
//           "chrome",
//           "data",
//           "javascript",
//           "about"
//         ].contains(uri.scheme)) {
//           if (await canLaunchUrl(uri)) {
//             // Launch the App
//             await launchUrl(
//               uri,
//             );
//             // and cancel the request
//             return NavigationActionPolicy.CANCEL;
//           }
//         }

//         return NavigationActionPolicy.ALLOW;
//       },
//       onLoadStop: (controller, url) async {
//         pullToRefreshController?.endRefreshing();
//         // setState(() {
//         //   this.url = url.toString();
//         //   urlController.text = this.url;
//         // });
//       },
//       onReceivedError: (controller, request, error) {
//         pullToRefreshController?.endRefreshing();
//       },
//       onProgressChanged: (controller, progress) {
//         if (progress == 100) {
//           pullToRefreshController?.endRefreshing();
//         }
//         // setState(() {
//         //   this.progress = progress / 100;
//         //   urlController.text = this.url;
//         // });
//       },
//       onUpdateVisitedHistory: (controller, url, isReload) {
//         // setState(() {
//         //   this.url = url.toString();
//         //   urlController.text = this.url;
//         // });
//       },
//       onConsoleMessage: (controller, consoleMessage) {
//         print(consoleMessage);
//       },
//     ));
//   }

// InAppWebViewController? _webViewController;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         child: Column(children: <Widget>[
//           Expanded(
//               child: InAppWebView(
//                 initialUrlRequest: URLRequest(url:WebUri('https://pentemind.com')),
//                 initialOptions: InAppWebViewGroupOptions(
//                   crossPlatform: InAppWebViewOptions(
//                       allowFileAccessFromFileURLs: true,
//                       cacheEnabled: true,
//                       supportZoom: true,
//                       useOnDownloadStart: true,
//                     javaScriptEnabled: true
//                   ),
//                 ),
//                 onWebViewCreated: (InAppWebViewController controller) {
//                   _webViewController = controller;
//                 },
//                 onDownloadStartRequest: (controller,url) async {
//                   print("onDownloadStart ${url}");
//                   //Utility.downloadImage(url.toString(), url.suggestedFilename.toString());

//                   print("onDownloadStart new Url  ${url.url.scheme} ");
//                   print("onDownloadStart new Url  ${url.url.query} ");
//                    /*final taskId = await FlutterDownloader.enqueue(
//                     url: url.url.data?.uri.toString() as String,
//                     savedDir: (await getTemporaryDirectory()).path,
//                     showNotification: false, // show download progress in status bar (for Android)
//                     openFileFromNotification: true, // click on notification to open downloaded file (for Android)
//                     saveInPublicStorage: false,
//                   );*/

//                    /*final taskId = await FlutterDownloader.enqueue(
//                     url: 'https://s3.amazonaws.com/content.pentemind/SummerCamp_2023/FunActivities/MindTrottersPath1/MT_P1_Activity6.png',
//                     savedDir: (await getTemporaryDirectory()).path,
//                     showNotification: false, // show download progress in status bar (for Android)
//                     openFileFromNotification: true, // click on notification to open downloaded file (for Android)
//                     saveInPublicStorage: false,
//                   );*/

//                 },
//               ))
//         ]));
//   }

  // @override
  // Widget build12(BuildContext context) {
  //   return PopScope(
  //     canPop: false,
  //     onPopInvoked: (didPop) async {
  //       if (didPop) {
  //         return;
  //       }
  //       WebViewController webViewController = await controller.future;
  //       if (await webViewController.canGoBack()) {
  //         webViewController.goBack();
  //       } else {
  //         Navigator.pop(context);
  //       }
  //     },
  //     child: MaterialApp(
  //       title: widget.title,
  //       debugShowCheckedModeBanner: false,
  //       home: Scaffold(
  //         appBar: widget.title == 'Parent Support Desk' ||
  //                 widget.title == 'ZLLSaathi'
  //             ? null
  //             : AppBar(
  //                 backgroundColor: kPrimaryLightColor,
  //                 leadingWidth: 30,
  //                 title: Text(
  //                   widget.title,
  //                   style: Theme.of(context)
  //                       .textTheme
  //                       .titleSmall!
  //                       .copyWith(color: Colors.white),
  //                 ), // You can add title here
  //                 leading: Padding(
  //                   padding: const EdgeInsets.all(0.0),
  //                   child: IconButton(
  //                     icon:
  //                         const Icon(Icons.arrow_back_ios, color: Colors.white),
  //                     onPressed: () async {
  //                       WebViewController webViewController =
  //                           await controller.future;
  //                       if (await webViewController.canGoBack()) {
  //                         webViewController.goBack();
  //                       } else {
  //                         Navigator.pop(context);
  //                       }
  //                     },
  //                   ),
  //                 ), //You can make this transparent
  //                 elevation: 0.0, //No shadow
  //               ),
  //         body: Container(
  //           child: WebView(
  //             initialUrl: widget.url,
  //             javascriptMode: JavascriptMode.unrestricted,
  //             onWebViewCreated: (WebViewController webViewController) {
  //               print('FLWEB webview created....');
  //               _controller = webViewController;
  //               controller.complete(webViewController);
  //               //_controller.complete(webViewController);
  //             },
  //             onProgress: (int progress) {
  //               print('FLWEB- WebView is loading (onProgress : $progress%)');
  //               if (progress >= 100 && !isUrlLoadingCompleted) {
  //                 isUrlLoadingCompleted = true;
  //                 Navigator.of(context, rootNavigator: true).pop('dialog');
  //
  //                 //Navigator.pop(context);
  //               }
  //             },
  //             javascriptChannels: <JavascriptChannel>{
  //               _toasterJavascriptChannel(context),
  //             },
  //             navigationDelegate: (NavigationRequest request) {
  //               print('FLWEB-allowing navigation to $request');
  //               if (request.url.startsWith('fb://profile')) {
  //                 return NavigationDecision.prevent;
  //               }
  //               return NavigationDecision.navigate;
  //             },
  //             onPageStarted: (String url) {
  //               isUrlLoadingCompleted = false;
  //               showLoaderDialog(context);
  //               print('FLWEB-Page started loading: $url');
  //             },
  //             onPageFinished: (String url) {
  //               print('FLWEB-Page onPageFinished loading: $url');
  //             },
  //             onWebResourceError: (WebResourceError error) {
  //               print(error.toString());
  //               //print('======');
  //             },
  //             gestureNavigationEnabled: true,
  //             geolocationEnabled: true, // set geolocationEnable true or not
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
//  }
}
