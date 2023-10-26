import 'package:shared_preferences/shared_preferences.dart';

class SettingModel {
  bool startPlay = false;
  late SharedPreferences local;

  Future<void> save() async {
    local = await SharedPreferences.getInstance();
    await local.setBool('startPlay', startPlay);
  }

  Future<void> load() async {
    local = await SharedPreferences.getInstance();
    startPlay = local.getBool('startPlay') ?? startPlay;
  }
}
