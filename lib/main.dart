import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:music/page/home/controller.dart';
import 'package:music/page/home/view.dart';
import 'package:music/page/lyric/controller.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
        center: true,
        titleBarStyle: TitleBarStyle.hidden,
        minimumSize: Size(1000, 750));
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.maximize();
      await windowManager.setTitle('秋月的音乐');
    });
  }
  runApp(const MyApp());
}

class MyBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<LyricController>(() => LyricController());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        initialBinding: MyBinding(),
        builder: EasyLoading.init(),
        debugShowCheckedModeBanner: false,
        home: const HomePage());
  }
}
