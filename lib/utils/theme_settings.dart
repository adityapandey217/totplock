import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettings extends ChangeNotifier {
  ThemeData _themeData = ThemeData.light();

  ThemeData get themeData => _themeData;
  ThemeMode get currentTheme => _themeData == ThemeData.light()
      ? ThemeMode.light
      : ThemeMode.dark;


  ThemeSettings(bool isDark){
    isDark ? _themeData = ThemeData.dark() : _themeData = ThemeData.light();
  }
  void toggleTheme() async{
    final SharedPreferences prefs =await  SharedPreferences.getInstance();
    if (_themeData == ThemeData.light()) {
      _themeData = ThemeData.dark();
      await prefs.setBool('darkMode', true);
    } else {
      _themeData = ThemeData.light();
      await prefs.setBool('darkMode', false);
    }
    notifyListeners();
  }
}

