import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MainWebView extends StatefulWidget {
  const MainWebView({
    Key? key,
  }) : super(key: key);

  @override
  State<MainWebView> createState() => _MainWebViewState();
}

class _MainWebViewState extends State<MainWebView> {
  late WebViewController _controller = WebViewController();
  late FToast fToast;

  void _openToast(
    String message,
    ToastGravity gravity,
  ) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: const Color(0XFF0479f6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications_active, color: Colors.white),
          const SizedBox(width: 12.0),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: gravity,
      toastDuration: const Duration(seconds: 2),
    );
  }

  @override
  void initState() {
    fToast = FToast();
    fToast.init(context);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('shareChannel',
          onMessageReceived: (JavaScriptMessage javaScriptMessage) async {
        var data = jsonDecode(javaScriptMessage.message);
        String paymentMethod = data['paymentMethod'];
        String amount = data['amount'];
        String period = data['period'];
        String interest = data['interest'];
        String redirectUrl =
            '${dotenv.env['BASE_URL']}/share?paymentMethod=$paymentMethod&amount=$amount&period=$period&interest=$interest';

        try {
          bool isKakaoTalkSharingAvailable =
              await ShareClient.instance.isKakaoTalkSharingAvailable();
          if (isKakaoTalkSharingAvailable) {
            FeedTemplate defaultFeed = FeedTemplate(
              content: Content(
                title: "my-calculator",
                description: "계산 결과를 확인해 보세요!",
                imageUrl: Uri.parse('${dotenv.env['BASE_URL']}/favicon.png'),
                link: Link(
                    webUrl: Uri.parse(redirectUrl),
                    mobileWebUrl: Uri.parse(redirectUrl)),
              ),
              buttons: [
                Button(
                  title: '계산 결과 확인하기',
                  link: Link(
                    webUrl: Uri.parse(redirectUrl),
                    mobileWebUrl: Uri.parse(redirectUrl),
                  ),
                ),
              ],
            );

            Uri uri =
                await ShareClient.instance.shareDefault(template: defaultFeed);
            await ShareClient.instance.launchKakaoTalk(uri);
          } else {
            _openToast("카카오톡을 설치해 주세요.", ToastGravity.BOTTOM);
          }
        } catch (error) {
          _openToast("공유하기에 실패했습니다.", ToastGravity.TOP);
        }
      })
      ..addJavaScriptChannel('alertChannel',
          onMessageReceived: (JavaScriptMessage javaScriptMessage) {
        var data = jsonDecode(javaScriptMessage.message);

        _openToast(data["message"], ToastGravity.TOP);
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('${dotenv.env['BASE_URL']}'));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
