// file: lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Paleta principal
  static const Color moradoPrincipal = Color(0xFF6D28D9);
  static const Color moradoOscuro = Color(0xFF4C1D95);
  static const Color moradoClaro = Color(0xFFEDE9FE);
  static const Color moradoMedio = Color(0xFF8B5CF6);

  // Acento
  static const Color acento = Color(0xFF06B6D4);
  static const Color acentoOscuro = Color(0xFF0891B2);
  static const Color acentoClaro = Color(0xFFCFFAFE);

  // Amarillo
  static const Color amarillo = Color(0xFFFBBF24);
  static const Color amarilloClaro = Color(0xFFFEF3C7);

  // Fondos
  static const Color fondoPrincipal = Color(0xFFF8F7FF);
  static const Color fondoCard = Color(0xFFFFFFFF);
  static const Color fondoSurface = Color(0xFFF1F0FF);

  // Texto
  static const Color textoOscuro = Color(0xFF1E293B);
  static const Color textoMedio = Color(0xFF475569);
  static const Color textoClaro = Color(0xFF94A3B8);
  static const Color textoBlanco = Color(0xFFFFFFFF);

  // Estados
  static const Color exito = Color(0xFF10B981);
  static const Color exitoClaro = Color(0xFFD1FAE5);
  static const Color riesgo = Color(0xFFF59E0B);
  static const Color riesgoClaro = Color(0xFFFEF3C7);
  static const Color peligro = Color(0xFFEF4444);
  static const Color peligroClaro = Color(0xFFFEE2E2);

  // Bordes
  static const Color borde = Color(0xFFE2E8F0);
  static const Color bordeMorado = Color(0xFFDDD6FE);

  // Estados académicos con fondos
  static const Color exitoFondo = Color(0xFFD1FAE5);
  static const Color exitoTexto = Color(0xFF065F46);
  static const Color riesgoFondo = Color(0xFFFEF3C7);
  static const Color riesgoTexto = Color(0xFF92400E);
  static const Color peligroFondo = Color(0xFFFEE2E2);
  static const Color peligroTexto = Color(0xFF991B1B);

  // Helper para obtener color de texto según el fondo
  static Color getTextColorForBackground(Color backgroundColor) {
    // Calcular luminancia
    final luminance = backgroundColor.computeLuminance();
    // Si el fondo es oscuro (< 0.5), usar texto claro
    return luminance < 0.5 ? textoBlanco : textoOscuro;
  }

  // Obtener par de colores para estado académico
  static (Color fondo, Color texto) getEstadoColors(String estado) {
    switch (estado.toLowerCase()) {
      case 'ganando':
        return (exitoFondo, exitoTexto);
      case 'riesgo':
      case 'en riesgo':
        return (riesgoFondo, riesgoTexto);
      case 'perdiendo':
        return (peligroFondo, peligroTexto);
      default:
        return (fondoSurface, textoMedio);
    }
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'sans-serif',
      colorScheme: const ColorScheme.light(
        primary: AppColors.moradoPrincipal,
        onPrimary: AppColors.textoBlanco,
        primaryContainer: AppColors.moradoClaro,
        onPrimaryContainer: AppColors.moradoOscuro,
        secondary: AppColors.acento,
        onSecondary: AppColors.textoBlanco,
        secondaryContainer: AppColors.acentoClaro,
        onSecondaryContainer: AppColors.acentoOscuro,
        surface: AppColors.fondoCard,
        onSurface: AppColors.textoOscuro,
        background: AppColors.fondoPrincipal,
        onBackground: AppColors.textoOscuro,
        error: AppColors.peligro,
        onError: AppColors.textoBlanco,
        outline: AppColors.borde,
      ),
      scaffoldBackgroundColor: AppColors.fondoPrincipal,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fondoPrincipal,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.moradoPrincipal),
        titleTextStyle: TextStyle(
          color: AppColors.textoOscuro,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.fondoCard,
        elevation: 0,
        shadowColor: AppColors.moradoPrincipal.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borde, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.moradoPrincipal,
          foregroundColor: AppColors.textoBlanco,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.moradoPrincipal,
          side: const BorderSide(color: AppColors.moradoPrincipal, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.moradoPrincipal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.moradoPrincipal,
        foregroundColor: AppColors.textoBlanco,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fondoSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.moradoPrincipal, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textoMedio),
        hintStyle: const TextStyle(color: AppColors.textoClaro),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.fondoCard,
        selectedItemColor: AppColors.moradoPrincipal,
        unselectedItemColor: AppColors.textoClaro,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.fondoSurface,
        selectedColor: AppColors.moradoClaro,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borde,
        thickness: 1,
        space: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.moradoPrincipal;
          }
          return AppColors.borde;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
