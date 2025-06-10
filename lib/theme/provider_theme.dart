// lib/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Costruttore
  ThemeProvider() {
    _loadTheme();
  }

  // Inverte il tema
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    // Salva il tema
    _saveTheme(_isDarkMode);
    // Notifica i widget che usano questo provider, per aggiornare la UI
    notifyListeners();
  } 

  // Carica il tema salvato da SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Se la trova
    if(prefs.containsKey('isDarkMode')){
      _isDarkMode = prefs.getBool('isDarkMode')!;
    }
    
    // Notifica i widget che usano questo provider, per aggiornare la UI
    notifyListeners();
  }

  // Salva le preferenza
  Future<void> _saveTheme(bool value) async {
    // await SharedPreferences.getInstance() metodo che inizializza ( o recupera ) l'istanza di SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Per salvare la preferenza sul dispositivo ( false == tema chiaro, true == tema scuro)
    prefs.setBool('isDarkMode', value);
  }
}
