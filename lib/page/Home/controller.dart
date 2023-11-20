import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:music/utils.dart';
import 'package:window_manager/window_manager.dart';

import '../../model/music_list.dart';
import '../../model/song_model.dart';
import '../../player_controller.dart';

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
  double oldVolume = 100.0;
  final musicList = <SongModel>[];
  final searchList = <int>[].obs;
  RxDouble windowsWidth = 0.0.obs;
  RxBool noNetwork = false.obs;
  SongModel nowPlaySong = SongModel();
  late MusicPlayer player;

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  Future<void> _initData() async {
    musicList.addAll(
        await MusicList.getLocelMusicList(isMyMusic ? 'netease' : 'milk'));
    player = MusicPlayer();
    player.init();
    playId.value = musicList.first.id!;
    nowPlaySong = musicList.first;

    playListen();
    setWindows();
    update(["home"]);
  }

  Future<void> setWindows() async {
    if (Platform.isWindows) {
      final windowsSize = await windowManager.getSize();
      windowsWidth.value = windowsSize.width;
    }
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
    player.playListen();
  }

  int getSongIndex(int id) {
    int index = musicList.indexWhere((element) {
      return element.id == id;
    });
    return index;
  }

  void changePlayMode(int playMode) {
    playlistMode.value = playMode;
  }

  void insertNext(int id) {
    waitPlayId = id;
    Get.back();
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
    await player.seek(position);
  }

  Future<void> next() async {
    debugPrint('播放下一首');
    playNext(true);
  }

  Future<void> previous() async {
    debugPrint('播放上一首');
    playNext(false);
  }

  Future<void> playNext(bool next, [int? id]) async {
    player.playNext(next, id);
  }

  Future<void> jump(int index) async {
    await player.jump(index);
    update(['home']);
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
