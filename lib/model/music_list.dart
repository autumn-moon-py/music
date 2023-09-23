import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:music/model/song_model.dart';

import '../utils/utils.dart';

class MusicList {
  static Future<List<SongModel>> getLocelMusicList() async {
    Map jsonData = await readJson('assets/list.json');
    List jsonMusicList = jsonData['result']['tracks'];
    List<SongModel> songModelList = getSongModelList(jsonMusicList);
    return songModelList;
  }

  static Future<List<SongModel>> getNetworkMusicList(int id) async {
    Map jsonData = await getHttp(MusicAPI.neteaseListUrl(id));
    if (jsonData['code'] != 200) {
      debugPrint('请求在线歌单失败');
      return [];
    }
    List jsonMusicList = jsonData['result']['tracks'];
    List<SongModel> songModelList = getSongModelList(jsonMusicList);
    return songModelList;
  }

  static List<SongModel> getSongModelList(List jsonMusicList) {
    List<SongModel> songModelList = [];
    for (var item in jsonMusicList) {
      final id = item['id'];
      final name = item['name'];
      final artist = item['artists'][0]['name'];
      String picUrl = item['album']['picUrl'];
      if (!picUrl.contains('https')) {
        picUrl = picUrl.replaceFirst('http', 'https');
      }
      final songUrl = MusicAPI.neteaseSongUrl(id);
      SongModel songModel = SongModel(
          id: id, name: name, artist: artist, picUrl: picUrl, songUrl: songUrl);
      songModelList.add(songModel);
    }
    songModelList.insert(0, songModelList[0]);
    // debugPrint('歌曲数量：${songModelList.length}');
    return songModelList;
  }

  static Playlist getMediaList(List<SongModel> musicList) {
    List<Media> mediaList = [];
    for (var item in musicList) {
      mediaList.add(Media(item.songUrl!));
    }
    return Playlist(mediaList);
  }
}
