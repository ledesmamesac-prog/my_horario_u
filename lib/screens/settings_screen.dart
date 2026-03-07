import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final esOscuro = themeProvider.themeMode == ThemeMode.dark ||
                           (themeProvider.themeMode == ThemeMode.system && 
                            MediaQuery.of(context).platformBrightness == Brightness.dark);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Sección de Apariencia
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8, top: 8),
                child: Text(
                  'APARIENCIA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textoClaro,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Card(
                child: SwitchListTile(
                  title: const Text(
                    'Modo Oscuro',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Cambiar entre modo claro y oscuro',
                    style: TextStyle(fontSize: 12),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: esOscuro ? AppColors.moradoOscuro : AppColors.moradoClaro,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      esOscuro ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: esOscuro ? AppColors.textoBlanco : AppColors.moradoPrincipal,
                    ),
                  ),
                  value: esOscuro,
                  activeColor: AppColors.moradoPrincipal,
                  onChanged: (value) {
                    themeProvider.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              
              // Sección de Acerca de
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  'ACERCA DE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textoClaro,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.fondoSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline_rounded, color: AppColors.textoMedio),
                  ),
                  title: const Text('Versión', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Text('1.0.0', style: TextStyle(color: AppColors.textoClaro)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
