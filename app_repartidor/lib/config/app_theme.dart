import 'package:flutter/material.dart';

// --- Definición de Paleta de Colores ---
const Color primaryAmber = Color(0xFFFFBF00); // Ámbar principal
const Color darkGreyMatte = Color(0xFF1E1E1E); // Fondo (Negro Mate)
const Color surfaceColor = Color(0xFF2C2C2C); // Superficies, Cards

class AppTheme {

  // El tema oscuro para toda la aplicación.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,

      // Colores Base
      scaffoldBackgroundColor: darkGreyMatte,
      primaryColor: primaryAmber,

      // Definición del ColorScheme
      colorScheme: const ColorScheme.dark(
        primary: primaryAmber,
        secondary: primaryAmber,
        surface: surfaceColor,
        background: darkGreyMatte,
        onPrimary: Colors.black, // Texto sobre Ámbar (Usado en AppBar)
        onSurface: Colors.white, // Texto sobre superficies oscuras
      ),

      // Estilo de la Barra de Aplicación
      appBarTheme: const AppBarTheme(
        color: darkGreyMatte, // El fondo de la AppBar es Gris Mate
        elevation: 0,
        // El texto y los iconos por defecto deben ser visibles (Blanco o Ámbar)
        // Usamos Blanco como color de contraste para la AppBar general
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Colors.black),
      ),

      // Estilo de los Botones Principales (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAmber,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
      ),

      // Estilo para TextFields/Inputs
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        labelStyle: TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: primaryAmber, width: 2),
        ),
      ),

      // Estilo para tarjetas
      cardTheme: const CardThemeData(
        color: surfaceColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      ),

      // Estilo de los iconos
      iconTheme: const IconThemeData(
        color: primaryAmber,
      ),
    );
  }
}