import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:music/style/app_style.dart';

Future<Map> readJson(String path) async {
  String jsonString = await rootBundle.loadString(path);
  Map jsonData = jsonDecode(jsonString);
  return jsonData;
}

Future<Map> getHttp(String url) async {
  try {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'code': 404, 'msg': '请求失败'};
    }
  } catch (e) {
    debugPrint(e.toString());
    return {'code': 404, 'msg': '异常：$e'};
  }
}

class MusicAPI {
  static String neteaseSongUrl([int id = 986150480]) {
    return 'https://music.163.com/song/media/outer/url?id=$id.mp3';
  }

  static String neteaseListUrl(int id) {
    return 'https://music.163.com/api/playlist/detail?id=$id';
  }

  static String neteaseSongInfoUrl(int id) {
    return 'https://music.163.com/api/song/detail/?id=$id&ids=[$id]';
  }

  static String neteaseSongWebUrl(int id) {
    return 'https://music.163.com/#/song?id=$id';
  }

  static String neteaseLyricUrl(int id) {
    return 'https://music.163.com/api/song/lyric?id=$id&lv=1&kv=1&tv=1';
  }
}

/// == SizedBox
Widget sb({double width = 0, double height = 0}) {
  return SizedBox(width: width, height: height);
}

PopupMenuItem moreMenuItem({
  required String index,
  required IconData icon,
  required String title,
  double? iconSize,
  Function? onTap,
}) {
  return PopupMenuItem(
      value: index,
      padding: EdgeInsets.zero,
      child: MaterialButton(
          padding: EdgeInsets.zero,
          splashColor: Colors.transparent,
          height: 50,
          hoverColor: const Color.fromRGBO(66, 66, 76, 1),
          onPressed: () {
            onTap?.call();
          },
          child: Row(children: [
            const SizedBox(width: 10),
            Icon(icon, color: Colors.grey, size: iconSize),
            const SizedBox(width: 10),
            Text(title,
                style: MyTheme.middleTextStyle.copyWith(color: Colors.grey))
          ])));
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "$twoDigitMinutes:$twoDigitSeconds";
}

class WDCustomTrackShape extends RoundedRectSliderTrackShape {
  double addHeight;
  WDCustomTrackShape({this.addHeight = 0});

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 1;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
