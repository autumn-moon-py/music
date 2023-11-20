import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music/model/song_model.dart';
import 'package:music/page/lyric/view.dart';
import 'package:music/style/app_style.dart';
import 'package:music/utils/utils.dart';
import 'package:music/widget.dart';

import 'controller.dart';

class SongItem extends StatefulWidget {
  final int index;
  final SongModel model;
  final List<SongModel> musicList;
  final Function(int) onTap;
  final Function(int) onDoubleTap;

  const SongItem(
      {super.key,
      required this.index,
      required this.model,
      required this.musicList,
      required this.onTap,
      required this.onDoubleTap});

  @override
  State<SongItem> createState() => _SongItemState();
}

class _SongItemState extends State<SongItem> {
  final homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final model = widget.model;

    Widget indexWidget() {
      return Obx(() {
        bool isPlaying = model.id == homeController.playId.value;

        return Container(
            alignment: Alignment.center,
            width: Platform.isWindows ? 40 : 25,
            height: Platform.isWindows ? 17 : 15,
            margin: EdgeInsets.only(
                bottom: isPlaying
                    ? Platform.isWindows
                        ? 15
                        : 10
                    : 0),
            child: isPlaying
                ? Icon(Icons.play_arrow,
                    color: Colors.white, size: Platform.isWindows ? 30 : 25)
                : Text(widget.index.toString(),
                    style: MyTheme.middleTextStyle));
      });
    }

    final picWidget = ClipRRect(
        borderRadius: BorderRadius.circular(5), child: sb()
        //  CachedNetworkImage(
        //     imageUrl: model.picUrl!,
        //     width: Platform.isWindows ? 50 : 25,
        //     placeholder: (context, url) {
        //       return Image.network(
        //           'https://s2.music.126.net/style/web2/img/outchain/loading.gif');
        //     },
        //     errorWidget: (context, error, stackTrace) {
        //       debugPrint('列表图片加载失败');
        //       return const Icon(Icons.info, color: Colors.white);
        //     })
        );

    final nameWidget = Obx(() {
      final windowsWidth = homeController.windowsWidth.value;
      return ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: Platform.isWindows
                  ? windowsWidth <= 1480
                      ? 190
                      : 280
                  : 280),
          child: Container(
              margin:
                  EdgeInsets.symmetric(horizontal: Platform.isWindows ? 15 : 7),
              child: Text(model.name!,
                  style: MyTheme.middleTextStyle,
                  overflow: TextOverflow.ellipsis)));
    });

    final artistWidget = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: Platform.isWindows ? 280 : 200),
        child: Container(
            margin: EdgeInsets.only(left: Platform.isWindows ? 15 : 7),
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
        bool choose = homeController.chooseId.value == model.id;
        return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
                color: choose ? Colors.white.withAlpha(30) : Colors.transparent,
                child: GestureDetector(
                    onDoubleTap: () {
                      widget.onDoubleTap(model.id!);
                      widget.onTap(model.id!);
                    },
                    child: MaterialButton(
                        padding: EdgeInsets.zero,
                        splashColor: Colors.transparent,
                        hoverColor: Colors.white.withAlpha(30),
                        onPressed: () {
                          widget.onTap(model.id!);
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
                onTap: () => homeController.insertNext(model.id!)),
            moreMenuItem(
                index: "2",
                icon: Icons.share,
                title: "分享",
                onTap: () => homeController.share(model.id!))
          ];
        },
        child: const Icon(Icons.more_horiz, color: Colors.white, size: 30));

    return background(
        child: Row(children: [
      sb(width: Platform.isWindows ? 0 : 5),
      indexWidget(),
      picWidget,
      songInfo,
      Expanded(child: sb()),
      more,
      sb(width: Platform.isWindows ? 10 : 5)
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
        color: const Color.fromRGBO(26, 26, 35, 1),
        height: Platform.isWindows ? 80 : 40,
        child: child);
  }

  Widget leftWidget() {
    SongModel model = SongModel();
    final playIndex = homeController.getSongIndex(homeController.playId.value);
    if (homeController.musicList.isNotEmpty) {
      model = homeController.musicList[playIndex];
    }
    final picWidget = ClipRRect(
        borderRadius: BorderRadius.circular(5), child: sb()
        // CachedNetworkImage(
        //     imageUrl: model.picUrl! == ''
        //         ? 'https://s2.music.126.net/style/web2/img/outchain/loading.gif'
        //         : model.picUrl!,
        //     width: 50,
        //     placeholder: (context, url) {
        //       return Image.network(
        //           'https://s2.music.126.net/style/web2/img/outchain/loading.gif');
        //     },
        //     errorWidget: (context, error, stackTrace) {
        //       debugPrint('底部图片加载失败');
        //       return const Icon(Icons.info, color: Colors.white);
        //     })
        );
    final name = Text(model.name ?? '', style: MyTheme.middleTextStyle);
    final specer = Text('-', style: MyTheme.middleTextStyle);
    final artist = Text(model.artist ?? '',
        style: Platform.isWindows
            ? MyTheme.middleTextStyle.copyWith(color: Colors.grey)
            : MyTheme.minTextStyle.copyWith(color: Colors.grey));
    final more = PopupMenuButton(
        color: const Color.fromRGBO(45, 45, 56, 1),
        padding: EdgeInsets.zero,
        offset: const Offset(40, 0),
        tooltip: "更多",
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        itemBuilder: (context) {
          return [
            moreMenuItem(
                index: "1",
                icon: Icons.file_download,
                title: "下载",
                onTap: () => homeController.download(model.id!)),
            moreMenuItem(
                index: "2",
                icon: Icons.share,
                iconSize: 20,
                title: "分享",
                onTap: () => homeController.share(model.id!))
          ];
        },
        child: Icon(Icons.more_horiz,
            color: Colors.white, size: Platform.isWindows ? 27 : 13));

    final nameWidget = Platform.isWindows
        ? Row(children: [name, sb(width: 5), specer, sb(width: 5), artist])
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [name, artist]);
    final songInfo = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          sb(),
          Container(
              margin: EdgeInsets.only(left: Platform.isWindows ? 5 : 0),
              width: Platform.isWindows ? 280 : 120,
              height: Platform.isWindows ? 38 : 30,
              child: model.name!.length + model.artist!.length < 25
                  ? nameWidget
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                          SizedBox(
                              height: 18, child: MarqueeWidget(child: name)),
                          artist
                        ])),
          Platform.isWindows ? more : sb()
        ]);
    return GestureDetector(
        onTap: () async {
          Get.to(const LyricPage());
        },
        child: Row(children: [
          picWidget,
          sb(width: Platform.isWindows ? 10 : 5),
          songInfo
        ]));
  }

  Widget rightWidget() {
    double oldVolume = homeController.volume.value;

    final playMode = Obx(() {
      final nowPlayMode = homeController.playlistMode.value;

      IconData loopIcon(int playMode) {
        if (playMode == 0) {
          return Icons.repeat;
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
            if (nowPlayMode == 0) {
              homeController.changePlayMode(1); //单曲
            }
            if (nowPlayMode == 1) {
              homeController.changePlayMode(2); //乱序
            }
            if (nowPlayMode == 2) {
              homeController.changePlayMode(0); //循环
            }
          },
          child: Icon(loopIcon(nowPlayMode),
              color: Colors.grey, size: Platform.isWindows ? 25 : 20));
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
    return Platform.isWindows
        ? Row(children: [
            playMode,
            sb(width: 10),
            volumeIcon,
            sb(width: 5),
            slider
          ])
        : playMode;
  }

  @override
  Widget build(BuildContext context) {
    return background(
        child: Row(children: [
      sb(width: Platform.isWindows ? 35 : 0),
      Obx(() => leftWidget()),
      Expanded(child: sb()),
      rightWidget(),
      sb(width: Platform.isWindows ? 30 : 5)
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
      SongModel model = SongModel();
      final playIndex =
          homeController.getSongIndex(homeController.playId.value);
      if (homeController.musicList.isNotEmpty) {
        model = homeController.musicList[playIndex];
      }
      final picUrl = model.picUrl;
      final background = Container(color: const Color.fromRGBO(19, 19, 26, 1));
      if (picUrl == '') {
        return background;
      }
      return background;
      // return Blur(
      //     blur: 80,
      //     colorOpacity: 0.5,
      //     blurColor: Colors.black,
      //     child: CachedNetworkImage(
      //         imageUrl: picUrl!,
      //         width: context.width,
      //         height: context.height,
      //         fit: BoxFit.fill,
      //         placeholder: (context, url) {
      //           return background;
      //         },
      //         errorWidget: (context, error, stackTrace) {
      //           debugPrint('背景图片加载失败');
      //           return background;
      //         }));
    });
  }
}

class AnimatedSearchBox extends StatefulWidget {
  const AnimatedSearchBox({super.key});

  @override
  AnimatedSearchBoxState createState() => AnimatedSearchBoxState();
}

class AnimatedSearchBoxState extends State<AnimatedSearchBox> {
  final homeController = Get.find<HomeController>();
  final TextEditingController _textController = TextEditingController();
  bool _isShowClear = false;
  final double _minWidth = 80;
  final double _maxWIdth = 180;
  double _width = 0;
  bool _isExpand = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _width = _minWidth;
    _focusNodeListener();
    setState(() {});
  }

  void _showClear(String value) {
    if (value != '') {
      _isShowClear = true;
    } else {
      _isShowClear = false;
    }
    setState(() {});
  }

  void _changeWidth() {
    if (_isExpand) {
      _width = _maxWIdth;
    } else {
      _width = _minWidth;
    }
    setState(() {});
  }

  void _focusNodeListener() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _isExpand = true;
      } else if (_textController.text.isEmpty) {
        _isExpand = false;
      }
      _changeWidth();
    });
  }

  void _firstFocue() {
    FocusScope.of(context).requestFocus(_focusNode);
    _width = _maxWIdth;
    _isExpand = true;
    setState(() {});
  }

  void _searchSong(String value) {
    List<int> searchList = [];
    homeController.searchList.clear();
    for (var element in homeController.musicList) {
      if (element.name!.contains(value) || element.artist!.contains(value)) {
        searchList.add(element.id!);
      }
    }
    homeController.searchList.addAll(searchList);
    debugPrint('搜索结果到:${searchList.length}条结果');
  }

  void _clearSearch() {
    _textController.clear();
    _isShowClear = false;
    homeController.searchList.clear();
    _isExpand = false;
    _changeWidth();
    _focusNode.unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _firstFocue();
        },
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: _width,
            height: 30,
            decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              sb(width: 10),
              Container(
                  padding: EdgeInsets.only(top: Platform.isWindows ? 4 : 0),
                  child: const Icon(Icons.search,
                      color: Color.fromRGBO(187, 183, 185, 1), size: 18)),
              Expanded(
                  child: Container(
                      padding: EdgeInsets.only(
                          left: 1, bottom: GetPlatform.isDesktop ? 2.5 : 1),
                      child: TextField(
                          focusNode: _focusNode,
                          controller: _textController,
                          style: MyTheme.middleTextStyle,
                          cursorColor: Colors.white,
                          cursorWidth: 1,
                          cursorHeight: 20,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '搜索',
                              hintStyle: MyTheme.middleTextStyle.copyWith(
                                  color:
                                      const Color.fromRGBO(117, 106, 110, 1))),
                          onChanged: (value) {
                            _showClear(value);
                            _searchSong(value);
                          }))),
              sb(width: Platform.isWindows ? 10 : 5),
              _isShowClear
                  ? GestureDetector(
                      onTap: () {
                        _clearSearch();
                      },
                      child:
                          const Icon(Icons.clear, color: Colors.grey, size: 16))
                  : sb(),
              sb(width: Platform.isWindows ? 10 : 5)
            ])));
  }
}
