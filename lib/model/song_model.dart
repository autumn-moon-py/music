import 'dart:convert';

class SongModel {
  int? id;
  String? name;
  String? artist;
  String? picUrl;
  String? songUrl;
  int? playTime;
  bool play = false;

  SongModel(
      {this.id = 0,
      this.name = '',
      this.artist = '',
      this.picUrl = '',
      this.songUrl = '',
      this.playTime = 0});

  SongModel.fromJson(Map json) {
    id = json['id'];
    name = json['name'];
    artist = json['artist'];
    picUrl = json['picUrl'];
    songUrl = json['songUrl'];
    playTime = json['playTime'];
  }

  Map toJson() {
    final Map data = <String, dynamic>{};
    data['id'] = id ?? 0;
    data['name'] = name ?? '';
    data['artist'] = artist ?? '';
    data['picUrl'] = picUrl ?? '';
    data['songUrl'] = songUrl ?? '';
    data['playTime'] = playTime ?? 0;
    return data;
  }

  fromJsonString(String jsonString) {
    Map jsonData = jsonDecode(jsonString);
    return SongModel.fromJson(jsonData);
  }
}
