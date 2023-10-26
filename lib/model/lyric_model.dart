import 'dart:convert';

class LyricLine {
  final Duration startTime;
  final String text;

  LyricLine({required this.startTime, required this.text});

  String toJson() {
    return jsonEncode({'startTime': startTime.inMilliseconds, 'text': text});
  }

  factory LyricLine.fromJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    return LyricLine(
        startTime: Duration(milliseconds: data['startTime']),
        text: data['text']);
  }
}

List<LyricLine> parseLyrics(String lyrics) {
  List<LyricLine> lyricLines = [];
  List lines = lyrics.split('\n');
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line == "") {
      lines.removeAt(i);
    }
  }
  for (String line in lines) {
    int left = line.indexOf('[');
    int right = line.indexOf(']');
    String timeString = line.substring(left + 1, right - 1);
    int minutes = int.parse(timeString.split(':')[0]);
    int seconds = int.parse(timeString.split(':')[1].split('.')[0]);
    int milliseconds = int.parse(timeString.split('.')[1]);
    Duration time = Duration(
        minutes: minutes, seconds: seconds, milliseconds: milliseconds);
    String text = line.substring(right + 1, line.length);
    int haveNull = text.indexOf(' ');
    if (haveNull == 0) {
      text = text.substring(1);
    }
    lyricLines.add(LyricLine(startTime: time, text: text));
  }
  for (int i = 0; i < lyricLines.length; i++) {
    final model = lyricLines[i];
    if (model.text == "") {
      lyricLines.removeAt(i);
    }
  }

  return lyricLines;
}
