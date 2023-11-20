import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:music/app_style.dart';

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

Map<String, String> headers() {
  return {
    'Sec-Ch-Ua':
        '"Google Chrome";v="117", "Not;A=Brand";v="8", "Chromium";v="117"',
    'Sec-Ch-Ua-Mobile': '?0',
    'Sec-Ch-Ua-Platform': '"Windows"',
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'none',
    'Sec-Fetch-User': '?1',
    'Upgrade-Insecure-Requests': '1',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36'
  };
}

class MusicAPI {
  static String neteaseSongUrl([int id = 986150480]) {
    return 'https://music.163.com/song/media/outer/url?id=$id.mp3';
  }

  ///https://music.163.com/api/playlist/detail?id=986150480
  ///https://music.163.com/api/playlist/detail?id=1987836021
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

  static String vercelSongUrl(String name) {
    return 'https://video.subrecovery.top/proxy/music.subrecovery.top/$name.mp3';
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
