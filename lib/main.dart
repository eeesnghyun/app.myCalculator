import 'package:app_my_calculator/widget/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 구성 파일 로드
  await dotenv.load(fileName: ".env");

  // 카카오 sdk 초기화
  KakaoSdk.init(nativeAppKey: '${dotenv.env['KAKAO_API_KEY']}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MainWebView(),
    );
  }
}
