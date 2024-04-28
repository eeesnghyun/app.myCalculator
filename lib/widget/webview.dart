import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MainWebView extends StatefulWidget {
  const MainWebView({
    Key? key,
  }) : super(key: key);

  @override
  State<MainWebView> createState() => _MainWebViewState();
}

class _MainWebViewState extends State<MainWebView> {
  final String _webviewChannel =
      Platform.isAndroid ? 'androidChannel' : 'iosChannel';
  late WebViewController _controller = WebViewController();
  bool _isLoading = true;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {},
            onPageStarted: (String url) {},
            onPageFinished: (String url) async {
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse('${dotenv.env['BASE_URL']}'));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
