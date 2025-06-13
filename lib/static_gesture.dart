import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import 'theme/provider_theme.dart';

// Enum per identificare le diverse pagine dell'app
enum Pagina{
  prima,
  seconda,
  hero,
  account
}

// Classe statica per gestire gesture, temi, traduzioni e utility globali
class StaticGesture{
  StaticGesture();
  
  // Mostra una SnackBar centralizzata con styling basato sul tema
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

  // Restituisce il colore del testo in base al tema corrente
  static Color getTextColor(BuildContext context, Color lightColor, Color darkColor) {
    return Provider.of<ThemeProvider>(context, listen: false).isDarkMode? lightColor : darkColor; // ? listen: false
  }
  
  // Ritorna il ThemeMode (light/dark) basato sul valore di isDarkMode
  static ThemeMode getThemeMode(BuildContext context){
    return Provider.of<ThemeProvider>(context).isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  // Restituisce il colore di sfondo dei container in base al tema
  static Color getContainerColor(BuildContext context){
    return Provider.of<ThemeProvider>(context).isDarkMode? Colors.black54 : Colors.white70;
  }

  // Ritorna il percorso corretto per le immagini di sfondo chiaro/scuro
  static String getPath(BuildContext context,  String pathChiaro, String pathScuro){
    return Provider.of<ThemeProvider>(context, listen: false).isDarkMode? pathScuro : pathChiaro;
  }

  // Icona del tema corrente (sole per light, luna per dark)
  static IconData getIconTheme(BuildContext context){
    return Provider.of<ThemeProvider>(context).isDarkMode? Icons.dark_mode : Icons.light_mode;
  }

  // Colore dei pulsanti in base al tema
  static Color getButtonColor(BuildContext context){
    return Provider.of<ThemeProvider>(context).isDarkMode? const Color.fromARGB(186, 63, 59, 59) : Colors.white70;
  }

  // Toggle del tema chiaro/scuro (lo camambia)
  static void changeTheme(BuildContext context){
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
  }

  // Colore del bordo dei componenti (container, pulsanti)
  static Color getBorderColor(BuildContext context){
    return Provider.of<ThemeProvider>(context).isDarkMode? Colors.black : Colors.grey;
  }

  // Colore per le icone in base al tema
  static Color getIconColor(BuildContext context, Color brightColor, Color darkColor){
    return Provider.of<ThemeProvider>(context).isDarkMode? darkColor : brightColor;
  }

  // Riproduce un suono da asset (file mp3)
  static Future<void> playSound(String assetPath) async {
    final player = AudioPlayer();
    await player.play(AssetSource(assetPath));
  }

  // Inverte il valore bool di menuFlag
  static changeMenuState(){ 
    StaticGesture.menuFlag.value = !StaticGesture.menuFlag.value;
  }

  // Inverte il valore bool di traduzioneOn
  static changeLanguage(){ 
    StaticGesture.traduzioneOn.value = !StaticGesture.traduzioneOn.value; 
  }

  // Restituisce la stringa corrispondente alla lingua attiva
  static String getTraduzione(String italiano, String inglese){
    if(traduzioneOn.value){ return italiano; }
    return inglese;
  }

  // ValueNotifier per lo stato del menu impostazioni (aperto/chiuso)
  static final ValueNotifier<bool> menuFlag = ValueNotifier<bool>(false);
  
  // ValueNotifier per lo stato della traduzione (italiano/<->inglese)
  static final ValueNotifier<bool> traduzioneOn = ValueNotifier<bool>(false);
}