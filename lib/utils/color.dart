import 'package:flutter/material.dart';
class CClass{
  static bool isDark = true;
  static Color starColor = Colors.yellow;
  static Color textColor1 = Colors.white;
  static Color textColor2 = Colors.grey;
  static Color containerColor = Color(0xff353653);
  static Color buttonColor = Color(0xff4a33b0);
  static Color buttonColor2 = Colors.deepPurpleAccent;
  static Color backgroundColor2 = Color(0xff121221);
  static Color backgroundColor = Color(0xff1a1a2f);
  static Color secondaryBackgroundColor = Color(0xff242443);

  static Color bGColorTheme(){
    isDark ? backgroundColor = Color(0xff1a1a2f) :
      backgroundColor = Colors.white70;
    return backgroundColor;
  }
  static Color bGColor2Theme(){
    isDark ? backgroundColor2 = Color(0xff121221) :
    backgroundColor2 = Color(0xff656593);
    return backgroundColor2;
  }
  static Color secondaryBGColorTheme(){
    isDark ? secondaryBackgroundColor = Color(0xff242443) :
    secondaryBackgroundColor = Color(0xff242443);
    return secondaryBackgroundColor;
  }
  static Color bTColorTheme(){
    isDark ? buttonColor = Color(0xff4a33b0) :
    buttonColor = Color(0xff4a33b0);
    return buttonColor;
  }
  static Color bTColor2Theme(){
    isDark ? buttonColor2 = Colors.deepPurpleAccent :
    buttonColor2 = Color(0xff121221);
    return buttonColor2;
  }
  static Color textColorTheme(){
    isDark ? textColor1 = Colors.white :
    textColor1 = Colors.black;
    return textColor1;
  }
  static Color containerColorTheme(){
    isDark ? containerColor = Color(0xff353653) :
    containerColor = Color(0xff515267);
    return containerColor;
  }
}