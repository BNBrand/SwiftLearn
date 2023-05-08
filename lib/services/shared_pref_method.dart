import 'package:shared_preferences/shared_preferences.dart';

class SharePrefClass{

  static SharedPreferences? _pref;
  static const _themeNote = 'value';

  static Future init() async =>
      _pref = await SharedPreferences.getInstance();

  static Future saveThemeNote(bool themeNote) async =>
      await _pref!.setBool(_themeNote, themeNote);

  static bool? getThemeNote()  => _pref!.getBool(_themeNote);

}