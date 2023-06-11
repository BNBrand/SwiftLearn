import 'package:shared_preferences/shared_preferences.dart';

class SharePrefClass{

  static SharedPreferences? _pref;
  static const _themeNote = 'value';
  static const _controllerNote = 'noteController';
  static const _quizOption = 'quizOption';


  static Future init() async =>
      _pref = await SharedPreferences.getInstance();

  static Future saveThemeNote(bool themeNote) async =>
      await _pref!.setBool(_themeNote, themeNote);

  static bool? getThemeNote()  => _pref!.getBool(_themeNote);

  static Future saveControllerNote(String controller) async =>
      await _pref!.setString(_themeNote, controller);

  static String? getControllerNote()  => _pref!.getString(_themeNote);

 static Future saveQuizOption(int option) async =>
      await _pref!.setInt(_quizOption, option);

  static int? getQuizOption()  => _pref!.getInt(_quizOption);

}