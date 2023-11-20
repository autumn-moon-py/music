import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:music/model/lyric_model.dart';
import 'package:music/page/home/widget.dart';
import 'package:music/style/app_style.dart';
import 'package:music/utils/utils.dart';
import 'package:music/widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'controller.dart';

class LyricPage extends StatefulWidget {
  const LyricPage({Key? key}) : super(key: key);

  @override
  State<LyricPage> createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const _LyricViewGetX();
  }
}

class _LyricViewGetX extends GetView<LyricController> {
  const _LyricViewGetX({Key? key}) : super(key: key);

  Widget _lyricList() {
    return Padding(
        padding: EdgeInsets.only(top: Platform.isWindows ? 150 : 80),
        child:
            // ListView.builder
            PageView.builder(
                itemCount: controller.lyricModelList.length,
                controller: controller.lyricController,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                // padding: EdgeInsets.only(
                //     top: Platform.isWindows ? 100 : 100,
                //     bottom: Platform.isWindows ? 400 : 100),
                itemBuilder: (context, index) {
                  final line = controller.lyricModelList[index];
                  late Duration? next;
                  bool last = false;
                  if (index != controller.lyricModelList.length - 1) {
                    next = controller.lyricModelList[index + 1].startTime;
                  } else {
                    next = controller.duration;
                    last = true;
                  }
                  return _lyricItem(line, last, next, index, context);
                }));
  }

  Widget _lyricItem(LyricLine line, bool last, Duration next, int index,
      BuildContext context) {
    TextStyle style =
        Platform.isWindows ? MyTheme.bigTextStyle : MyTheme.middleTextStyle;
    bool playHere = false;
    if (!last) {
      playHere =
          controller.position.inMilliseconds >= line.startTime.inMilliseconds &&
              controller.position.inMilliseconds < next.inMilliseconds;
    } else {
      playHere =
          controller.position.inMilliseconds > line.startTime.inMilliseconds;
    }
    if (playHere) {
      style = style.copyWith(
          fontSize: Platform.isWindows ? 30 : 20, fontWeight: FontWeight.bold);
    } else {
      style = style.copyWith(color: Colors.grey);
    }
    if (index > controller.lineIndex.value + 2 ||
        index < controller.lineIndex.value - 2) {
      style = style.copyWith(color: Colors.grey.withAlpha(150));
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          constraints: BoxConstraints(
              maxWidth: Platform.isWindows ? double.infinity : 360),
          child: Text(line.text,
              style: style,
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip))
    ]);
  }

  Widget _backButton() {
    return Container(
        margin: const EdgeInsets.fromLTRB(25, 30, 0, 0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _button(
                  icon: Icons.keyboard_arrow_down,
                  onTap: () {
                    Get.back();
                  })
            ]));
  }

  Widget _button(
      {required IconData icon, required Function onTap, double? iconSize}) {
    return GestureDetector(
        onTap: () {
          onTap();
        },
        child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
                color: Colors.grey.withAlpha(30),
                border: Border.all(color: Colors.grey.withAlpha(60), width: 1),
                borderRadius: BorderRadius.circular(5)),
            child: Icon(icon, color: Colors.white, size: iconSize ?? 25)));
  }

  Widget _windowTap() {
    return Container(
        alignment: Alignment.topRight,
        margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: const WindowsTab());
  }

  Widget _songTitle() {
    final nameWidget = Text(controller.nowPlaySong.name!,
        style: Platform.isWindows
            ? MyTheme.bigTextStyle
            : MyTheme.middleTextStyle);
    final name = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 15),
        child: controller.nowPlaySong.name!.length < 25
            ? nameWidget
            : MarqueeWidget(child: nameWidget));
    final artist = Text(controller.nowPlaySong.artist!,
        style: Platform.isWindows
            ? MyTheme.middleTextStyle.copyWith(color: Colors.grey)
            : MyTheme.minTextStyle.copyWith(color: Colors.grey));
    final back = GestureDetector(
      onTap: () {
        Get.back();
      },
      child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
    );
    return Container(
        alignment: Platform.isWindows ? Alignment.topCenter : Alignment.topLeft,
        margin: EdgeInsets.only(
            left: Platform.isWindows ? 0 : 10,
            top: Platform.isWindows ? 80 : 30),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              back,
              sb(width: 5),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [name, sb(height: 5), artist]),
            ]));
  }

  Widget _background() {
    return Scaffold(
        body: RawKeyboardListener(
            focusNode: FocusNode(),
            autofocus: true,
            onKey: (event) {
              if (event.logicalKey == LogicalKeyboardKey.escape) {
                Get.back();
              }
            },
            child: MouseRegion(
                onEnter: (event) {
                  controller.showBotton.value = true;
                },
                onExit: (event) async {
                  await Future.delayed(const Duration(seconds: 10));
                  controller.showBotton.value = false;
                },
                onHover: (event) async {
                  if (!controller.showBotton.value) {
                    controller.showBotton.value = true;
                  }
                  await Future.delayed(const Duration(seconds: 10));
                  controller.showBotton.value = false;
                },
                child: Stack(children: [
                  const HomeBackground(),
                  _lyricList(),
                  _songTitle(),
                  Platform.isWindows
                      ? Obx(() {
                          if (controller.showBotton.value) {
                            return Stack(
                                children: [_backButton(), _windowTap()]);
                          }
                          return sb();
                        })
                      : sb()
                ]))));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LyricController>(
        init: LyricController(),
        id: "lyric",
        builder: (_) {
          return VisibilityDetector(
              key: const Key('my-widget-key'),
              onVisibilityChanged: (visibilityInfo) {
                if (visibilityInfo.visibleFraction == 1) {
                  controller.lyricController
                      .jumpToPage(controller.lineIndex.value);
                }
              },
              child: _background());
        });
  }
}
