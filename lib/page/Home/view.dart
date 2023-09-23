import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/page/Home/widget.dart';
import 'package:music/style/app_style.dart';
import 'package:music/utils/utils.dart';

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const _HomeViewGetX();
  }
}

class _HomeViewGetX extends GetView<HomeController> {
  const _HomeViewGetX({Key? key}) : super(key: key);

  Widget musicListWidget() {
    return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 5),
        itemCount: controller.musicList.length,
        itemBuilder: (ctx, index) {
          final nowIndex = index + 1;
          return SongItem(
              index: nowIndex,
              onTap: controller.changeChooseIndex,
              onDoubleTap: controller.changePlayIndex);
        });
  }

  Widget middleWidget() {
    final previous = GestureDetector(
        onTap: () {
          controller.previous();
        },
        child: const Icon(Icons.skip_previous, color: Colors.white, size: 30));

    final next = GestureDetector(
        onTap: () {
          controller.next();
        },
        child: const Icon(Icons.skip_next, color: Colors.white, size: 30));

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
                    size: 30)))));

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
              width: 405,
              height: 0,
              child: Slider(
                  value: position.toDouble(),
                  min: 0,
                  max: duration.toDouble(),
                  onChanged: (value) {
                    controller.seek(Duration(milliseconds: value.toInt()));
                  },
                  onChangeEnd: (value) {
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
        sb(width: 8),
        slider,
        sb(width: 8),
        durationWidget
      ]);
    });

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [previous, sb(width: 10), play, sb(width: 10), next]),
      sb(height: 5),
      slider
    ]);
  }

  Widget _buildView() {
    return Stack(children: [
      const HomeBackground(),
      Column(
          children: [Expanded(child: musicListWidget()), const BottomPlayer()]),
      Container(
          alignment: Alignment.bottomCenter,
          margin: const EdgeInsets.only(bottom: 15),
          child: middleWidget())
    ]);
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
