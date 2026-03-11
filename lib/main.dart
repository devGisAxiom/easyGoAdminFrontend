import 'package:flutter/material.dart';
import 'package:getbike_admin/views/home.dart';
import 'package:getbike_admin/views/insidepages/splash.dart';
import 'package:getbike_admin/views/login.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  //  WidgetsFlutterBinding.ensureInitialized();
  //    await windowManager.ensureInitialized();

  // WindowOptions options = const WindowOptions(
  //   minimumSize: Size(1920, 1080),
  //   center: true,
  //   backgroundColor: Colors.transparent,
  //   skipTaskbar: false,
  //   windowButtonVisibility: false,
  //   titleBarStyle: TitleBarStyle.hidden,
  // );

  runApp(SizedBox(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF2794A0),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF2794A0)),
      ),
      home: EnhancedSplashScreen(),
    );
  }
}
