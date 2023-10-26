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

Map<String, String> headers() {
  return {
    'authority': 'p2.music.126.net',
    'method': 'GET',
    'path': '/9mBj0oY95FqKkVWzMeoxog==/109951168924619987.jpg',
    'scheme': 'https',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    'Accept-Encoding': 'gzip, deflate, br',
    'Accept-Language': 'zh-CN,zh;q=0.9',
    'Cache-Control': 'max-age=0',
    'If-Modified-Since': 'Mon, 18 Sep 2023 19:21:18 Asia/Shanghai',
    'If-None-Match': '9a578950cc29c69692c464a3e70e1243',
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
