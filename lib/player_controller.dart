// ignore_for_file: non_constant_identifier_names

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:media_kit/media_kit.dart';

import 'model/music_list.dart';
import 'model/song_model.dart';
import 'page/home/controller.dart';
import 'page/lyric/controller.dart';

const isMyMusic = true;

class MusicPlayer {
  final media_player = Player();
  final just_player = AudioPlayer();
  final controller = Get.put(HomeController());
  final lyricController = Get.put(LyricController());
  List<SongModel> get musicList => controller.musicList;

  Future<void> media_init() async {
    final playable = MusicList.getMediaList(musicList);
    await media_player.open(playable);
  }

  Future<void> just_init() async {
    final playlist = ConcatenatingAudioSource(
        children: musicList
            .map((e) => AudioSource.uri(Uri.parse(e.songUrl ?? '')))
            .toList());
    await just_player.setAudioSource(playlist,
        initialIndex: 0, initialPosition: Duration.zero
        // const Duration(minutes: 3, seconds: 40)
        );
    await play();
  }

  Future<void> init() async {
    GetPlatform.isDesktop ? media_init() : just_init();
  }

  void media_playListen() {
    media_player.stream.error.listen((error) {
      int playIndex = controller.getSongIndex(controller.playId.value);
      if (playIndex != 0) {
        musicList[playIndex].play = false;
        debugPrint('暂停$playIndex');
      }
      EasyLoading.showToast('错误:$error');
      playNext(true);
    });
    media_player.stream.playing.listen((playing) {
      final lyricController = Get.find<LyricController>();
      controller.playing.value = playing;
      lyricController.playing.value = playing;
      debugPrint('播放状态$playing');
    });
    media_player.stream.position.listen((position) {
      controller.position.value = position.inMilliseconds;
      lyricController.changePosition(position);
    });
    media_player.stream.completed.listen((completed) {
      controller.completed.value = completed;
      int playIndex = controller.getSongIndex(controller.playId.value);
      if (completed) {
        debugPrint('播放完成$playIndex');
        playNext(true);
      }
    });
    media_player.stream.duration.listen((duration) {
      controller.duration.value = duration.inMilliseconds;
      lyricController.changeDuration(duration);
    });
    media_player.stream.volume.listen((volume) {
      controller.volume.value = volume;
      debugPrint('音量$volume');
    });
  }

  void just_playListien() {
    just_player.playingStream.listen((playing) {
      controller.playing.value = playing;
      lyricController.playing.value = playing;
      debugPrint('播放状态$playing');
    });
    just_player.positionStream.listen((position) {
      controller.position.value = position.inMilliseconds;
      lyricController.changePosition(position);
      if (controller.duration.value == 0) return;
      bool next =
          (controller.duration.value - controller.position.value) < 1000;
      if (next) {
        controller.completed.value = true;
        int playIndex = controller.getSongIndex(controller.playId.value);
        debugPrint('播放完成$playIndex');
        playNext(true);
      }
    });
    just_player.durationStream.listen((duration) {
      controller.duration.value = duration?.inMilliseconds ?? 0;
      lyricController.changeDuration(duration ?? Duration.zero);
    });
    just_player.volumeStream.listen((volume) {
      // controller.volume.value = volume;
      debugPrint('音量$volume');
    });
  }

  void playListen() {
    GetPlatform.isDesktop ? media_playListen() : just_playListien();
  }

  Future<void> play() async {
    GetPlatform.isDesktop
        ? await media_player.play()
        : await just_player.play();
  }

  Future<void> pause() async {
    GetPlatform.isDesktop
        ? await media_player.pause()
        : await just_player.pause();
  }

  Future<void> stop() async {
    GetPlatform.isDesktop
        ? await media_player.stop()
        : await just_player.stop();
  }

  Future<void> setVolume(double volume) async {
    GetPlatform.isDesktop
        ? await media_player.setVolume(volume)
        : await just_player.setVolume(volume);
  }

  Future<void> seek(Duration position) async {
    GetPlatform.isDesktop
        ? await media_player.seek(position)
        : await just_player.seek(position);
    lyricController.changePosition(position);
  }

  Future<void> jump(int index) async {
    if (GetPlatform.isDesktop) {
      await media_player.jump(index);
    } else {
      await just_player.seek(Duration.zero, index: index);
    }
    controller.update(["home"]);
  }

  Future<void> playNext(bool next, [int? id]) async {
    int playIndex = controller.getSongIndex(controller.playId.value) == -1
        ? 0 //未播放/初始化
        : controller.getSongIndex(controller.playId.value); //正在播放的
    if (playIndex == musicList.length - 1) return; //避免溢出

    //暂停当前
    musicList[playIndex].play = false;
    debugPrint('暂停$playIndex');
    await pause();

    //无插入播放
    if (controller.waitPlayId == 0 && id == null) {
      //单曲
      if (controller.playlistMode.value == 1) playIndex = playIndex;
      //随机
      if (controller.playlistMode.value == 2) {
        while (true) {
          int temp = Random().nextInt(musicList.length - 1);
          if (temp != playIndex) {
            playIndex = temp;
            break;
          }
        }
      }
      //循环
      if (controller.playlistMode.value == 0) {
        next ? playIndex += 1 : playIndex -= 1;
      }
    }

    //有插入播放
    if (controller.waitPlayId != 0 && id == null) {
      controller.playId.value = controller.waitPlayId;
      playIndex = controller.getSongIndex(controller.playId.value);
      controller.waitPlayId = 0;
    }

    //指定播放
    if (id != null) {
      playIndex = controller.getSongIndex(id);
    }

    musicList[playIndex].play = true;
    controller.playId.value = musicList[playIndex].id!;
    controller.nowPlaySong = musicList[playIndex];
    lyricController.changeLyric(controller.nowPlaySong.id!);

    await jump(playIndex);
    await play();
    debugPrint('播放$playIndex');
  }
}
