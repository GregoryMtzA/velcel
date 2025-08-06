import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// azul oscuro : #004f89
// azul semi claro: #005fb5
// azul claro: #0077b5
// Gris oscuro: #333333
// Gris claro: #F0F0F0
// Blanco: #FFFFFF

class IsselColors {
  static final azulOscuro = Color(0xff604BE8);
  static final azulSemiOscuro = Color(0xff604BE8);
  static final azulClaro = Color(0xff604BE8);
  static final grisOscuro = Color(0xFF333333);
  static final grisMedio = Color(0xffdce1e9);
  static final grisClaro = Color(0xffe3e9f5);
  static final blanco = Color(0xFFFFFFFF);
  static final negro = Color(0xFF000000);
}

ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: IsselColors.grisClaro,

  colorScheme: ColorScheme.light(
      background: IsselColors.grisClaro,
      tertiary: IsselColors.negro,
      primary: IsselColors.negro,
      secondary: IsselColors.blanco,
      onPrimary: IsselColors.blanco,
      onSurface: IsselColors.negro
  ),
  textTheme: GoogleFonts.montserratTextTheme().copyWith(
    titleLarge: TextStyle(color: IsselColors.negro, fontSize: 42, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: IsselColors.negro, fontSize: 36, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(color: IsselColors.azulOscuro, fontSize: 30, fontWeight: FontWeight.bold),
    bodySmall: TextStyle(color: IsselColors.grisOscuro, fontSize: 15),
    bodyMedium: TextStyle(color: IsselColors.negro, fontSize: 17),
    bodyLarge: TextStyle(color: IsselColors.negro, fontSize: 19, fontWeight: FontWeight.w600),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: IsselColors.azulClaro
    )
  ),

  inputDecorationTheme: InputDecorationTheme(
    isCollapsed: true,
    border: UnderlineInputBorder(
      borderSide: BorderSide.none,
    ),
    hintStyle: TextStyle(color: IsselColors.negro.withOpacity(0.5), fontSize: 12),
  ),

  iconTheme: IconThemeData(
    color: IsselColors.negro,
  ),

);

ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: IsselColors.grisOscuro,

    colorScheme: ColorScheme.light(
        background: IsselColors.negro,
        primary: IsselColors.grisClaro,
        secondary: IsselColors.grisOscuro,
        tertiary: IsselColors.blanco,
        onPrimary: IsselColors.grisOscuro,
        onSurface: IsselColors.negro
    ),
    textTheme: GoogleFonts.latoTextTheme().copyWith(

      titleMedium: TextStyle(color: IsselColors.blanco, fontSize: 30, fontWeight: FontWeight.bold),
      titleSmall: TextStyle(color: IsselColors.azulSemiOscuro, fontSize: 30, fontWeight: FontWeight.bold),
      bodySmall: TextStyle(color: IsselColors.blanco, fontSize: 12),
      bodyMedium: TextStyle(color: IsselColors.blanco, fontSize: 15, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: IsselColors.blanco, fontSize: 17, fontWeight: FontWeight.bold),
    ),

    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            foregroundColor: IsselColors.azulClaro
        )
    ),

    inputDecorationTheme: InputDecorationTheme(
      isCollapsed: true,
      border: UnderlineInputBorder(
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: IsselColors.blanco.withOpacity(0.5), fontSize: 12),
    ),

    iconTheme: IconThemeData(
      color: IsselColors.blanco
    ),

);