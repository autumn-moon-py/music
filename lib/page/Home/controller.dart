import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:music/page/lyric/controller.dart';
import 'package:music/utils/utils.dart';
import 'package:window_manager/window_manager.dart';

import '../../model/music_list.dart';
import '../../model/song_model.dart';

class HomeController extends GetxController {
  HomeController();

  RxInt playId = 0.obs;
  int waitPlayId = 0;
  RxInt chooseId = 0.obs;
  RxBool playing = false.obs;
  RxInt position = 0.obs;
  RxBool completed = false.obs;
  RxInt duration = 0.obs;
  RxInt playlistMode = 0.obs;
  RxDouble volume = 100.0.obs;
  final musicList = <SongModel>[];
  final searchList = <int>[].obs;
  RxDouble windowsWidth = 0.0.obs;
  RxBool noNetwork = false.obs;
  late SongModel nowPlaySong;
  final Player player = Player();

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  Future<void> _initData() async {
    // musicList.addAll(await MusicList.getLocelMusicList('netease'));
    musicList.addAll(await MusicList.getLocelMusicList('milk'));
    final playable = MusicList.getMediaList(musicList);
    await player.open(playable);
    changePlayIndex(musicList.first.id!);
    if (Platform.isWindows) {
      final windowsSize = await windowManager.getSize();
      windowsWidth.value = windowsSize.width;
    }
    update(["home"]);
    playListen();
  }

  Future<void> changePlayIndex(int id) async {
    int playIndex =
        getSongIndex(playId.value) == -1 ? 0 : getSongIndex(playId.value);
    int index = getSongIndex(id);
    if (musicList[playIndex].play && playIndex == index) {
      debugPrint('正在播放$playIndex');
      await seek(Duration.zero);
      return;
    }
    playNext(true, id);
  }

  void changeChooseIndex(int id) {
    chooseId.value = id;
    debugPrint('选中$id');
  }

  void playListen() {
    final lyricController = Get.find<LyricController>();
    player.stream.error.listen((error) {
      int playIndex = getSongIndex(playId.value);
      if (playIndex != 0) musicList[playIndex].play = false;
      if (playIndex != 0) debugPrint('暂停$playIndex');
      // EasyLoading.showToast('错误:$error');
      next();
    });
    player.stream.playing.listen((playing) {
      this.playing.value = playing;
      lyricController.playing.value = playing;
      debugPrint('播放状态$playing');
    });
    player.stream.position.listen((position) {
      this.position.value = position.inMilliseconds;
      lyricController.changePosition(position);
    });
    player.stream.completed.listen((completed) {
      this.completed.value = completed;
      int playIndex = getSongIndex(playId.value);
      if (completed) {
        debugPrint('播放完成$playIndex');
        next();
      }
    });
    player.stream.duration.listen((duration) {
      this.duration.value = duration.inMilliseconds;
      lyricController.changeDuration(duration);
    });
    player.stream.volume.listen((volume) {
      this.volume.value = volume;
      debugPrint('音量$volume');
    });
  }

  int getSongIndex(int id) {
    int index = musicList.indexWhere((element) {
      return element.id == id;
    });
    return index;
  }

  Future<void> play() async {
    await player.play();
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> stop() async {
    await player.stop();
  }

  Future<void> setVolume(double volume) async {
    if (volume > 100 || volume < 0) return;
    await player.setVolume(volume);
  }

  Future<void> seek(Duration position) async {
    final lyricController = Get.find<LyricController>();
    await player.seek(position);
    lyricController.changePosition(position);
  }

  Future<void> playNext(bool next, [int? id]) async {
    final lyricController = Get.put(LyricController());
    int playIndex =
        getSongIndex(playId.value) == -1 ? 0 : getSongIndex(playId.value);
    if (playIndex == musicList.length - 1) {
      return;
    }
    musicList[playIndex].play = false;
    debugPrint('暂停$playIndex');
    await pause();
    if (waitPlayId == 0) {
      if (playlistMode.value == 1) {
        playIndex = playIndex;
      } else if (playlistMode.value == 2) {
        while (true) {
          int temp = Random().nextInt(musicList.length - 1);
          if (temp != playIndex) {
            playIndex = temp;
            break;
          }
        }
      } else if (playlistMode.value == 0) {
        if (next) {
          playIndex += 1;
        } else {
          playIndex -= 1;
        }
      }
    } else {
      playId.value = waitPlayId;
      playIndex = getSongIndex(playId.value);
      waitPlayId = 0;
    }
    if (id != null) {
      playIndex = getSongIndex(id);
    }
    musicList[playIndex].play = true;
    playId.value = musicList[playIndex].id!;
    nowPlaySong = musicList[playIndex];
    debugPrint('播放$playIndex');
    lyricController.nowPlaySong = nowPlaySong;
    lyricController.changeLyric();
    await jump(playIndex);
    await play();
  }

  Future<void> next() async {
    debugPrint('播放下一首');
    playNext(true);
  }

  Future<void> previous() async {
    debugPrint('播放上一首');
    playNext(false);
  }

  Future<void> jump(int index) async {
    await player.jump(index);
  }

  void changePlayMode(int playMode) {
    playlistMode.value = playMode;
  }

  void insertNext(int id) {
    waitPlayId = id;
    Get.back();
  }

  void download(int id) {
    final songUrl = MusicAPI.neteaseSongUrl(id);
    Clipboard.setData(ClipboardData(text: songUrl));
    EasyLoading.showToast('复制成功');
    Get.back();
  }

  void share(int id) {
    final songUrl = MusicAPI.neteaseSongWebUrl(id);
    Clipboard.setData(ClipboardData(text: songUrl));
    EasyLoading.showToast('复制成功');
    Get.back();
  }
}
