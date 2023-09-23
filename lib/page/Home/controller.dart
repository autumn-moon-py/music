import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:music/utils/utils.dart';

import '../../model/music_list.dart';
import '../../model/song_model.dart';

class HomeController extends GetxController {
  HomeController();
  RxInt playIndex = 0.obs;
  int waitPlayIndex = 0;
  RxInt chooseIndex = 0.obs;
  RxBool playing = false.obs;
  RxInt position = 0.obs;
  RxBool completed = false.obs;
  RxInt duration = 0.obs;
  RxInt playlistMode = 0.obs;
  RxDouble volume = 100.0.obs;
  final musicList = <SongModel>[].obs;
  final Player player = Player();

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  Future<void> _initData() async {
    musicList.addAll(await MusicList.getLocelMusicList());
    final playable = MusicList.getMediaList(musicList);
    await player.open(playable);
    changePlayIndex(1);
    update(["home"]);
    playListen();
  }

  Future<void> changePlayIndex(int index) async {
    if (musicList[index].play) {
      debugPrint('正在播放$index');
      await seek(Duration.zero);
      return;
    }
    if (playIndex.value != 0) musicList[playIndex.value].play = false;
    if (playIndex.value != 0) debugPrint('暂停${playIndex.value}');
    await pause();
    playIndex.value = index;
    musicList[index].play = true;
    debugPrint('播放${playIndex.value}');
    await jump(index);
    await play();
  }

  void changeChooseIndex(int index) {
    chooseIndex.value = index;
    debugPrint('选中$index');
  }

  void playListen() {
    player.stream.error.listen((error) {
      final model = musicList[playIndex.value];
      debugPrint('歌曲:${model.name} 播放错误:$error 大概率是会员专享');
      if (playIndex.value != 0) musicList[playIndex.value].play = false;
      if (playIndex.value != 0) debugPrint('暂停${playIndex.value}');
      if (waitPlayIndex == 0) {
        playIndex.value += 1;
      } else {
        playIndex.value = waitPlayIndex;
        waitPlayIndex = 0;
      }
      musicList[playIndex.value].play = true;
      debugPrint('播放${playIndex.value}');
    });
    player.stream.log.listen((log) {
      debugPrint('播放日志$log');
    });
    player.stream.playing.listen((playing) {
      this.playing.value = playing;
      debugPrint('播放状态$playing');
    });
    player.stream.position.listen((position) {
      this.position.value = position.inMilliseconds;
    });
    player.stream.completed.listen((completed) {
      this.completed.value = completed;
      if (completed) {
        debugPrint('播放完成${playIndex.value}');
        next();
      }
    });
    player.stream.duration.listen((duration) {
      this.duration.value = duration.inMilliseconds;
    });
    player.stream.volume.listen((volume) {
      this.volume.value = volume;
      debugPrint('音量$volume');
    });
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

  Future<void> setPlayMode(PlaylistMode mode) async {
    await player.setPlaylistMode(mode);
  }

  Future<void> setVolume(double volume) async {
    await player.setVolume(volume);
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  Future<void> shuffle(bool enable) async {
    await player.setShuffle(enable);
  }

  Future<void> next() async {
    debugPrint('播放下一首');
    musicList[playIndex.value].play = false;
    debugPrint('暂停${playIndex.value}');
    await pause();
    if (waitPlayIndex == 0) {
      playIndex.value += 1;
    } else {
      playIndex.value = waitPlayIndex;
      waitPlayIndex = 0;
    }
    musicList[playIndex.value].play = true;
    debugPrint('播放${playIndex.value}');
    await jump(playIndex.value);
    await play();
  }

  Future<void> previous() async {
    debugPrint('播放上一首');
    musicList[playIndex.value].play = false;
    debugPrint('暂停${playIndex.value}');
    await pause();
    playIndex.value -= 1;
    musicList[playIndex.value].play = true;
    debugPrint('播放${playIndex.value}');
    await jump(playIndex.value);
    await play();
  }

  Future<void> jump(int index) async {
    await player.jump(index);
  }

  void changePlayMode(int playMode) {
    playlistMode.value = playMode;
  }

  void insertNext(int index) {
    waitPlayIndex = index;
    Get.back();
  }

  void download(int index) {
    final songId = musicList[index].id;
    final songUrl = MusicAPI.neteaseSongUrl(songId!);
    Clipboard.setData(ClipboardData(text: songUrl));
    EasyLoading.showToast('复制成功');
    Get.back();
  }

  void share(int index) {
    final songId = musicList[index].id;
    final songUrl = MusicAPI.neteaseSongWebUrl(songId!);
    Clipboard.setData(ClipboardData(text: songUrl));
    EasyLoading.showToast('复制成功');
    Get.back();
  }
}
