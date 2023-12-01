import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:lottie/lottie.dart';


class MyWebsiteView extends StatefulWidget {
  String url;
  String title;
  MyWebsiteView({Key? key,required this.title,required this.url}) : super(key: key);

  @override
  MyWebsiteViewState createState() => MyWebsiteViewState();
}

class MyWebsiteViewState extends State<MyWebsiteView> {

  WebViewController? _controller = null;

  bool isUrlLoadingCompleted = false;
  double progress = 0;

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Download',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          debugPrint('Download method calles........');
          /*Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );*/
        });
  }

  @override
  void initState() {
    super.initState();
    debugPrint(Uri.decodeFull(widget.url));
    // Enable hybrid composition.
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
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
      return MaterialApp(
        title: widget.title,
        home: Scaffold(
          appBar:  AppBar(
            title: Text(widget.title),// You can add title here
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ), //You can make this transparent
            elevation: 0.0, //No shadow
          ),
          body : WebView(
            initialUrl: Uri.decodeFull(widget.url),
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              //debugPrint('FLWEB webview created....');
              _controller = webViewController;
              //_controller.complete(webViewController);
            },
            onProgress: (int progress) {
              //debugPrint('FLWEB- WebView is loading (onProgress : $progress%)');
              if (progress >= 100 && !isUrlLoadingCompleted) {
                setState(() {
                  isUrlLoadingCompleted = true;
                });

                //Navigator.of(context, rootNavigator: true).pop('dialog');

                //Navigator.pop(context);
              }
            },
            javascriptChannels: <JavascriptChannel>{
              _toasterJavascriptChannel(context),
            },
            navigationDelegate: (NavigationRequest request) {
              //debugPrint('FLWEB-allowing navigation to $request');
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              //isUrlLoadingCompleted = false;
              //showLoaderDialog(context);
              //debugPrint('FLWEB-Page started loading: $url');
            },
            onPageFinished: (String url) {
              //debugPrint('FLWEB-Page onPageFinished loading: $url');
            },
            onWebResourceError: (WebResourceError error) {
              //debugPrint(error.toString());
              //debugPrint('======');
            },
            gestureNavigationEnabled: true,
            geolocationEnabled: true, // set geolocationEnable true or not
          ),
        ),
      );
    }
//  }

}