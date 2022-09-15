import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webviewx/webviewx.dart';

import '../helper/helpers.dart';



class WebViewXPage extends StatefulWidget {
  const WebViewXPage({
    Key? key,
  }) : super(key: key);

  @override
  _WebViewXPageState createState() => _WebViewXPageState();
}

class _WebViewXPageState extends State<WebViewXPage> {

  late WebViewXController webviewController;

  Size get screenSize => MediaQuery.of(context).size;

  void viewUrl() {
    setState(() async { _setUrl();
    await webviewController.reload();
    });
  }

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _setUrl());

  }

  @override
  void dispose() {
    webviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: _buildWebViewX(),
    );
  }

  Widget _buildWebViewX() {
    return WebViewX(
      key: const ValueKey('webviewx'),
      initialContent: "",
      initialSourceType: SourceType.url,
      height: screenSize.height,
      width: min(screenSize.width * 0.9, 1024),
      onWebViewCreated: (controller) => webviewController = controller,
      onPageStarted: (src) =>
          debugPrint('Page loading: $src\n'),
      onPageFinished: (src) =>
          debugPrint('page finished loading: $src\n'),
      jsContent: const {
        EmbeddedJsContent(
          js: "function testPlatformIndependentMethod() { console.log('Hi from JS') }",
        ),
        EmbeddedJsContent(
          webJs:
          "function testPlatformSpecificMethod(msg) { TestDartCallback('Web callback says: ' + msg) }",
          mobileJs:
          "function testPlatformSpecificMethod(msg) { TestDartCallback.postMessage('Mobile callback says: ' + msg) }",
        ),
      },
      dartCallBacks: {
        DartCallback(
          name: 'TestDartCallback',
          callBack: (msg) => {},
        )
      },
      webSpecificParams: const WebSpecificParams(
        printDebugInfo: true,
      ),
      mobileSpecificParams: const MobileSpecificParams(
        androidEnableHybridComposition: true,
      ),
      navigationDelegate: (navigation) {
        debugPrint(navigation.content.sourceType.toString());
        return NavigationDecision.navigate;
      },
      );
  }

  void _setUrl() {
    webviewController.loadContent(
      'https://kidzee.com',
      SourceType.url,
    );
    _setHtml();
  }

  void _setUrlBypass() {
    webviewController.loadContent(
      'https://news.ycombinator.com/',
      SourceType.urlBypass,
    );
  }

  void _setHtml() {
    webviewController.loadContent(
      "Please wait",
      SourceType.html,
    );
  }

  void _setHtmlFromAssets() {
    webviewController.loadContent(
      'assets/test.html',
      SourceType.html,
      fromAssets: true,
    );
  }

  Future<void> _goForward() async {
    if (await webviewController.canGoForward()) {
      await webviewController.goForward();

    } else {

    }
  }

  Future<void> _goBack() async {
    if (await webviewController.canGoBack()) {
      await webviewController.goBack();

    } else {

    }
  }

  void _reload() {
    webviewController.reload();
  }

  void _toggleIgnore() {
    final ignoring = webviewController.ignoresAllGestures;
    webviewController.setIgnoreAllGestures(!ignoring);

  }


  Widget buildSpace({
    Axis direction = Axis.horizontal,
    double amount = 0.2,
    bool flex = true,
  }) {
    return flex
        ? Flexible(
      child: FractionallySizedBox(
        widthFactor: direction == Axis.horizontal ? amount : null,
        heightFactor: direction == Axis.vertical ? amount : null,
      ),
    )
        : SizedBox(
      width: direction == Axis.horizontal ? amount : null,
      height: direction == Axis.vertical ? amount : null,
    );
  }
}