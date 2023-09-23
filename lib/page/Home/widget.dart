import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:music/model/song_model.dart';
import 'package:music/style/app_style.dart';
import 'package:music/utils/utils.dart';
import 'package:music/widget.dart';

import 'controller.dart';

class SongItem extends StatefulWidget {
  final int index;
  final Function(int) onTap;
  final Function(int) onDoubleTap;

  const SongItem(
      {super.key,
      required this.index,
      required this.onTap,
      required this.onDoubleTap});

  @override
  State<SongItem> createState() => _SongItemState();
}

class _SongItemState extends State<SongItem> {
  final homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final model = homeController.musicList[
        widget.index < homeController.musicList.length
            ? widget.index
            : widget.index - 1];

    Widget indexWidget() {
      return Obx(() {
        bool isPlaying = widget.index == homeController.playIndex.value;

        return Container(
            alignment: Alignment.center,
            width: 40,
            child: isPlaying
                ? const Icon(Icons.play_arrow, color: Colors.white, size: 30)
                : Text(widget.index.toString(),
                    style:
                        MyTheme.middleTextStyle.copyWith(color: Colors.grey)));
      });
    }

    final picWidget = ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: CachedNetworkImage(
            imageUrl: model.picUrl!,
            width: 50,
            placeholder: (context, url) {
              return Image.network(
                  'https://s2.music.126.net/style/web2/img/outchain/loading.gif');
            },
            errorWidget: (context, error, stackTrace) {
              debugPrint('列表图片加载失败');
              return const Icon(Icons.info, color: Colors.white);
            }));

    final nameWidget = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(model.name!,
                style: MyTheme.middleTextStyle,
                overflow: TextOverflow.ellipsis)));

    final artistWidget = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(model.artist!,
                style: MyTheme.middleTextStyle.copyWith(color: Colors.grey),
                overflow: TextOverflow.ellipsis)));

    final songInfo = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [nameWidget, artistWidget]);

    Widget background({required Widget child}) {
      return Obx(() {
        bool choose = homeController.chooseIndex.value == widget.index;
        return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
                color: choose ? Colors.white.withAlpha(50) : Colors.transparent,
                child: GestureDetector(
                    onDoubleTap: () {
                      widget.onDoubleTap(widget.index);
                      widget.onTap(widget.index);
                    },
                    child: MaterialButton(
                        padding: const EdgeInsets.fromLTRB(0, 20, 10, 20),
                        splashColor: Colors.transparent,
                        hoverColor: Colors.white.withAlpha(50),
                        onPressed: () {
                          widget.onTap(widget.index);
                        },
                        child: child))));
      });
    }

    final more = PopupMenuButton(
        color: const Color.fromRGBO(45, 45, 56, 1),
        padding: EdgeInsets.zero,
        offset: Offset.fromDirection(1, 50),
        tooltip: "更多",
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        itemBuilder: (context) {
          return [
            moreMenuItem(
                index: "1",
                icon: Icons.playlist_add,
                title: "下一首播放",
                onTap: () => homeController.insertNext(widget.index)),
            moreMenuItem(
                index: "2",
                icon: Icons.share,
                title: "分享",
                onTap: () => homeController.share(widget.index))
          ];
        },
        child: const Icon(Icons.more_horiz, color: Colors.white, size: 30));

    return background(
        child: Row(children: [
      indexWidget(),
      picWidget,
      songInfo,
      Expanded(child: sb()),
      more,
      sb(width: 5)
    ]));
  }
}

class BottomPlayer extends StatefulWidget {
  const BottomPlayer({super.key});

  @override
  State<BottomPlayer> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {
  final homeController = Get.find<HomeController>();

  Widget background({required Widget child}) {
    return Container(
        color: const Color.fromRGBO(26, 26, 35, 1), height: 80, child: child);
  }

  Widget leftWidget() {
    return Obx(() {
      final model = homeController.musicList.isEmpty
          ? SongModel()
          : homeController.musicList[homeController.playIndex.value];
      final picWidget = ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: CachedNetworkImage(
              imageUrl: model.picUrl! == ''
                  ? 'https://s2.music.126.net/style/web2/img/outchain/loading.gif'
                  : model.picUrl!,
              width: 50,
              placeholder: (context, url) {
                return Image.network(
                    'https://s2.music.126.net/style/web2/img/outchain/loading.gif');
              },
              errorWidget: (context, error, stackTrace) {
                debugPrint('底部图片加载失败');
                return const Icon(Icons.info, color: Colors.white);
              }));
      final name = Text(model.name ?? '', style: MyTheme.middleTextStyle);
      final specer = Text('-', style: MyTheme.middleTextStyle);
      final artist = Text(model.artist ?? '',
          style: MyTheme.middleTextStyle.copyWith(color: Colors.grey));
      final more = PopupMenuButton(
          color: const Color.fromRGBO(45, 45, 56, 1),
          padding: EdgeInsets.zero,
          offset: const Offset(40, 0),
          tooltip: "更多",
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          itemBuilder: (context) {
            return [
              moreMenuItem(
                  index: "1",
                  icon: Icons.file_download,
                  title: "下载",
                  onTap: () =>
                      homeController.download(homeController.playIndex.value)),
              moreMenuItem(
                  index: "2",
                  icon: Icons.share,
                  iconSize: 20,
                  title: "分享",
                  onTap: () =>
                      homeController.share(homeController.playIndex.value))
            ];
          },
          child: const Icon(Icons.more_horiz, color: Colors.white, size: 27));

      final nameWidget =
          Row(children: [name, sb(width: 5), specer, sb(width: 5), artist]);
      final songInfo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            sb(),
            SizedBox(
                width: 280,
                height: 30,
                child: model.name!.length < 25
                    ? nameWidget
                    : MarqueeWidget(child: nameWidget)),
            more,
            sb(height: 1)
          ]);
      return Row(children: [picWidget, sb(width: 10), songInfo]);
    });
  }

  Widget rightWidget() {
    double oldVolume = homeController.volume.value;

    final playMode = Obx(() {
      final nowPlayMode = homeController.playlistMode.value;

      IconData loopIcon(int playMode) {
        if (playMode == 0) {
          return Icons.loop;
        }
        if (playMode == 1) {
          return Icons.repeat_one;
        }
        if (playMode == 2) {
          return Icons.shuffle;
        }
        return Icons.repeat;
      }

      return GestureDetector(
          onTap: () {
            late PlaylistMode newPlayMode;
            if (nowPlayMode == 0) {
              newPlayMode = PlaylistMode.loop;
              homeController.shuffle(false);
              homeController.changePlayMode(1);
            }
            if (nowPlayMode == 1) {
              newPlayMode = PlaylistMode.single;
              homeController.shuffle(false);
              homeController.changePlayMode(2);
            }
            if (nowPlayMode == 2) {
              newPlayMode = PlaylistMode.loop;
              homeController.shuffle(true);
              homeController.changePlayMode(0);
            }
            homeController.setPlayMode(newPlayMode);
          },
          child: Icon(loopIcon(nowPlayMode), color: Colors.grey, size: 25));
    });

    final volumeIcon = Obx(() => GestureDetector(
        onTap: () {
          if (homeController.volume.value != 0) {
            oldVolume = homeController.volume.value;
            homeController.setVolume(0);
          } else {
            homeController.setVolume(oldVolume);
          }
        },
        child: Icon(
            homeController.volume.value == 0
                ? Icons.volume_off
                : Icons.volume_down,
            color: Colors.grey,
            size: 25)));

    final slider = Obx(() => SliderTheme(
        data: SliderThemeData(
            trackHeight: 3,
            trackShape: WDCustomTrackShape(),
            thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: homeController.volume.value != 0 ? 2 : 0),
            thumbColor: const Color.fromRGBO(100, 100, 107, 1),
            overlayColor: Colors.transparent,
            activeTrackColor: const Color.fromRGBO(100, 100, 107, 1),
            inactiveTrackColor: const Color.fromRGBO(61, 61, 68, 1)),
        child: SizedBox(
            width: 70,
            child: Slider(
                value: homeController.volume.value,
                min: 0,
                max: 100,
                onChanged: (value) {
                  homeController.setVolume(value);
                },
                onChangeEnd: (value) {
                  homeController.setVolume(value);
                }))));
    return Row(children: [playMode, sb(width: 10), volumeIcon, slider]);
  }

  @override
  Widget build(BuildContext context) {
    return background(
        child: Row(children: [
      sb(width: 35),
      leftWidget(),
      Expanded(child: sb()),
      rightWidget(),
      sb(width: 30)
    ]));
  }
}

class HomeBackground extends StatefulWidget {
  const HomeBackground({super.key});

  @override
  State<HomeBackground> createState() => _HomeBackgroundState();
}

class _HomeBackgroundState extends State<HomeBackground> {
  final homeController = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final model = homeController.musicList.isEmpty
          ? SongModel()
          : homeController.musicList[homeController.playIndex.value];
      final picUrl = model.picUrl;
      final background = Container(color: const Color.fromRGBO(19, 19, 26, 1));
      if (picUrl == '') {
        return background;
      }
      return Blur(
          blur: 80,
          colorOpacity: 0.5,
          blurColor: Colors.black,
          child: CachedNetworkImage(
              imageUrl: picUrl!,
              width: context.width,
              height: context.height,
              fit: BoxFit.fill,
              placeholder: (context, url) {
                return background;
              },
              errorWidget: (context, error, stackTrace) {
                debugPrint('背景图片加载失败');
                return background;
              }));
    });
  }
}
