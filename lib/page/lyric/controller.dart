import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/model/lyric_model.dart';
import 'package:music/model/song_model.dart';
import 'package:music/page/home/controller.dart';
import 'package:music/utils/utils.dart';

class LyricController extends GetxController {
  LyricController();

  List<LyricLine> lyricModelList = [];
  late SongModel nowPlaySong;
  Duration position = const Duration();
  Duration duration = const Duration();
  RxInt lineIndex = 0.obs;
  RxBool playing = false.obs;
  final lyricController = ScrollController();
  RxBool showBotton = true.obs;

  _initData() async {
    final homeController = Get.find<HomeController>();
    if (lyricModelList.isEmpty) {
      nowPlaySong = homeController.nowPlaySong;
      changeLyric();
    }
    update(["lyric"]);
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  Future<void> changeLyric() async {
    final lyricJson = await getHttp(MusicAPI.neteaseLyricUrl(nowPlaySong.id!));
    final lyricString = lyricJson['lrc']['lyric'];
    lyricModelList = parseLyrics(lyricString);
  }

  void changeLyricLine(int index) {
    if (lineIndex.value != index) {
      lineIndex.value = index;
      if (lyricController.hasClients) {
        double nowOffset = lyricController.offset;
        nowOffset = index * (Platform.isWindows ? 53 : 28);
        lyricController.animateTo(nowOffset,
            duration: const Duration(milliseconds: 100),
            curve: Curves.bounceIn);
      } else {}
    }
  }

  void changePosition(Duration position) {
    this.position = position;
    int i = 0;
    for (var model in lyricModelList) {
      late int playIndex;
      late int next;
      if (i != lyricModelList.length - 1) {
        next = lyricModelList[i + 1].startTime.inMilliseconds;
      } else {
        next = duration.inMilliseconds;
      }
      if (position.inMilliseconds >= model.startTime.inMilliseconds &&
          position.inMilliseconds < next) {
        playIndex = i;
        changeLyricLine(playIndex);
        break;
      }
      if (i < lyricModelList.length) i++;
    }
    update(["lyric"]);
  }

  void changeDuration(Duration duration) {
    this.duration = duration;
    update(["lyric"]);
  }
}
