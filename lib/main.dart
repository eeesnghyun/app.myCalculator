import 'package:app_my_calculator/widget/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 구성 파일 로드
  await dotenv.load(fileName: ".env");

  // 카카오 sdk 초기화
  KakaoSdk.init(nativeAppKey: '${dotenv.env['KAKAO_API_KEY']}');

  runApp(const MyApp());

  // 스플래쉬 화면 제거
  await Future.delayed(const Duration(milliseconds: 2));
  FlutterNativeSplash.remove();
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
