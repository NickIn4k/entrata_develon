import 'package:flutter/material.dart';
import 'theme/provider_theme.dart';
import 'package:provider/provider.dart';

enum Pagina{
  prima,
  seconda
}

class StaticGesture{
  StaticGesture();
  
  static void showAppSnackBar(BuildContext context, String message){
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
  
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: isDarkMode ?Colors.black : Colors.white,
        duration: Duration(seconds: 3),
      ),
    );
  }

  static Color getTextColor(BuildContext context, Color lightColor, Color darkColor) {
    return Provider.of<ThemeProvider>(context, listen: false).isDarkMode? lightColor : darkColor; // ? listen: false
  }

  static ThemeMode getThemeMode(BuildContext context){
    return Provider.of<ThemeProvider>(context).isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  static Color getContainerColor(BuildContext context){
    return Provider.of<ThemeProvider>(context).isDarkMode? Colors.black54 : Colors.white70;
  }

  static String getPath(BuildContext context,  String pathChiaro, String pathScuro){
    return Provider.of<ThemeProvider>(context, listen: false).isDarkMode? pathScuro : pathChiaro;
  }

  static IconData getIconTheme(BuildContext context){
    return Provider.of<ThemeProvider>(context).isDarkMode? Icons.dark_mode : Icons.light_mode;
  }

  static Color getButtonColor(BuildContext context){
    return Provider.of<ThemeProvider>(context).isDarkMode? const Color.fromARGB(186, 63, 59, 59) : Colors.white70;
  }

  static void changeTheme(BuildContext context){
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
  }

  static Color getBorderColor(BuildContext context){
    return Provider.of<ThemeProvider>(context).isDarkMode? Colors.black : Colors.grey;
  }

  static Color getIconColor(BuildContext context, Color brightColor, Color darkColor){
    return Provider.of<ThemeProvider>(context).isDarkMode? darkColor : brightColor;
  }

  static bool showMenu = false;
}