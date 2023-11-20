import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/model/lyric_model.dart';
import 'package:music/model/song_model.dart';
import 'package:music/page/home/controller.dart';
import 'package:music/utils.dart';

class LyricController extends GetxController {
  LyricController();

  List<LyricLine> lyricModelList = [];
  SongModel get nowPlaySong => homeController.nowPlaySong;
  Duration position = const Duration();
  Duration duration = const Duration();
  RxInt lineIndex = 0.obs;
  RxBool playing = false.obs;
  final homeController = Get.put(HomeController());
  final lyricController = PageController(viewportFraction: 0.2);
  RxBool showBotton = true.obs;

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  _initData() async {
    changeLyric(nowPlaySong.id!);
    update(["lyric"]);
  }

  Future<void> changeLyric(int id) async {
    final lyricJson = await getHttp(MusicAPI.neteaseLyricUrl(id));
    final lyricString = lyricJson['lrc']['lyric'];
    lyricModelList = parseLyrics(lyricString);
    try {
      final tlyricString = lyricJson['tlyric']['lyric'];
      if (tlyricString != '') {
        final tlyricModelList = parseLyrics(tlyricString);
        for (int m = 0; m < tlyricModelList.length; m++) {
          for (int n = 0; n < lyricModelList.length; n++) {
            if (lyricModelList[n].startTime == tlyricModelList[m].startTime) {
              lyricModelList[n].text += '\n${tlyricModelList[m].text}';
            }
          }
        }
      }
    } catch (_) {}
  }

  void changeLyricLine(int index) {
    if (lineIndex.value != index) {
      lineIndex.value = index;
      if (lyricController.hasClients) {
        lyricController.animateToPage(lineIndex.value,
            duration: const Duration(milliseconds: 100),
            curve: Curves.bounceIn);
      }
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
