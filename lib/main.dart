import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_and_tree/providers/file_provider.dart';
import 'package:code_and_tree/screens/home_screen.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 데스크톱 플랫폼에서만 윈도우 크기 설정
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // 현재 화면의 크기를 가져와서 적용
    getWindowInfo().then((window) {
      final screen = window.screen;
      if (screen != null) {
        final screenFrame = screen.visibleFrame;
        final width = screenFrame.width / 2; // 화면 너비의 절반
        final height = screenFrame.height;

        // 화면 왼쪽에 위치하도록 x, y 좌표 계산
        final x = screenFrame.left; // 화면 왼쪽 끝
        final y = screenFrame.top; // 화면 상단

        setWindowFrame(Rect.fromLTWH(x, y, width, height));
      }
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FileProvider(),
      child: MaterialApp(
        title: 'Code and Tree',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          // 버튼 스타일 테마 설정
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
