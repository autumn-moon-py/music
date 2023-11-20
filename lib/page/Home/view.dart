import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:music/model/song_model.dart';
import 'package:music/page/home/widget.dart';
import 'package:music/style/app_style.dart';
import 'package:music/utils/utils.dart';
import 'package:music/widget.dart';
import 'package:window_manager/window_manager.dart';

import 'controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    checkNetwork();
  }

  void checkNetwork() async {
    final connectivityResult = Connectivity();
    connectivityResult.onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        EasyLoading.showToast('无网络');
        homeController.noNetwork.value = true;
      } else {
        homeController.noNetwork.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const _HomeViewGetX();
  }
}

class _HomeViewGetX extends GetView<HomeController> {
  const _HomeViewGetX({Key? key}) : super(key: key);

  Widget musicListWidget() {
    final scrollController = ScrollController();
    if (controller.noNetwork.value) {
      return Center(child: Text('无网络', style: MyTheme.middleTextStyle));
    }
    return SizeCacheWidget(
        estimateCount: Platform.isWindows ? 40 : 20,
        child: Scrollbar(
            controller: scrollController,
            child: GridView.builder(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(right: Platform.isWindows ? 10 : 0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Platform.isWindows ? 3 : 1,
                    childAspectRatio: Platform.isWindows ? 6 : 7),
                itemCount: controller.searchList.isEmpty
                    ? controller.musicList.length
                    : controller.searchList.length,
                itemBuilder: (ctx, index) {
                  final searchSongList = <SongModel>[];
                  Widget songItem(SongModel model, List<SongModel> musicList) {
                    return FrameSeparateWidget(
                        index: index,
                        child: SongItem(
                            index: index,
                            model: model,
                            musicList: musicList,
                            onTap: controller.changeChooseIndex,
                            onDoubleTap: controller.changePlayIndex));
                  }

                  if (controller.searchList.isNotEmpty) {
                    for (var id in controller.searchList) {
                      final songModel = controller.musicList
                          .firstWhere((element) => element.id == id);
                      searchSongList.add(songModel);
                    }
                    return songItem(searchSongList[index], searchSongList);
                  }
                  return songItem(
                      controller.musicList[index], controller.musicList);
                })));
  }

  Widget middleWidget() {
    if (controller.noNetwork.value) {
      return sb();
    }
    final previous = GestureDetector(
        onTap: () {
          controller.previous();
        },
        child: Icon(Icons.skip_previous,
            color: Colors.white, size: Platform.isWindows ? 30 : 20));

    final next = GestureDetector(
        onTap: () {
          controller.next();
        },
        child: Icon(Icons.skip_next,
            color: Colors.white, size: Platform.isWindows ? 30 : 20));

    final play = Obx(() => GestureDetector(
        onTap: () {
          if (controller.playing.value) {
            controller.pause();
          } else {
            controller.play();
          }
        },
        child: ClipOval(
            child: Container(
                padding: const EdgeInsets.all(5),
                color: const Color.fromRGBO(40, 40, 48, 1),
                child: Icon(
                    controller.playing.value
                        ? Icons.pause
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: Platform.isWindows ? 30 : 25)))));

    final slider = Obx(() {
      final position = controller.position.value;
      final duration = controller.duration.value;

      final slider = SliderTheme(
          data: SliderThemeData(
              trackHeight: 3,
              trackShape: WDCustomTrackShape(),
              thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: position != 0 ? 2 : 0),
              thumbColor: const Color.fromRGBO(195, 55, 76, 1),
              overlayColor: Colors.transparent,
              activeTrackColor: const Color.fromRGBO(195, 55, 76, 1),
              inactiveTrackColor: const Color.fromRGBO(61, 61, 68, 1)),
          child: Container(
              padding: const EdgeInsets.only(top: 1),
              width: Platform.isWindows ? 405 : 200,
              height: 6,
              child: Slider(
                  value: position.toDouble() < 0 ? 0 : position.toDouble(),
                  min: 0,
                  max: duration.toDouble() == 0 ? 100 : duration.toDouble(),
                  onChanged: (value) {
                    controller.seek(Duration(milliseconds: value.toInt()));
                  })));

      final positionWidget = Text(
          formatDuration(Duration(milliseconds: position)),
          style: MyTheme.minTextStyle.copyWith(color: Colors.grey));

      final durationWidget = Text(
          formatDuration(Duration(milliseconds: duration)),
          style: MyTheme.minTextStyle.copyWith(color: Colors.grey));

      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        positionWidget,
        sb(width: Platform.isWindows ? 8 : 4),
        slider,
        sb(width: Platform.isWindows ? 8 : 4),
        durationWidget
      ]);
    });

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        previous,
        sb(width: Platform.isWindows ? 10 : 5),
        play,
        sb(width: Platform.isWindows ? 10 : 5),
        next
      ]),
      sb(height: Platform.isWindows ? 5 : 0),
      Platform.isWindows ? slider : sb()
    ]);
  }

  Widget _buildView() {
    return RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            controller.setVolume(controller.volume.value + 10);
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            controller.setVolume(controller.volume.value - 10);
          }
        },
        child: Stack(children: [
          const HomeBackground(),
          Column(children: [
            Platform.isWindows
                ? GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanStart: (details) {
                      windowManager.startDragging();
                    },
                    child: Container(
                        color: Colors.transparent,
                        width: double.infinity,
                        child: sb(height: 30)))
                : sb(height: 30),
            Platform.isWindows ? const WindowsTab() : sb(),
            sb(height: Platform.isWindows ? 15 : 0),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              const AnimatedSearchBox(),
              sb(width: Platform.isWindows ? 35 : 25)
            ]),
            sb(height: Platform.isWindows ? 10 : 0),
            Expanded(child: Obx(() => musicListWidget())),
            Obx(() => !controller.noNetwork.value ? const BottomPlayer() : sb())
          ]),
          Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(bottom: Platform.isWindows ? 15 : 3),
              child: middleWidget())
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
        init: HomeController(),
        id: "home",
        builder: (_) {
          return Scaffold(body: _buildView());
        });
  }
}
