import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart';
import 'scanner_screen.dart';
import 'friends_list_screen.dart';

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
                      color: esOscuro
                          ? AppColors.moradoOscuro
                          : AppColors.moradoClaro,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      esOscuro
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: esOscuro
                          ? AppColors.textoBlanco
                          : AppColors.moradoPrincipal,
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

              // Sección Perfil y Social
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  'PERFIL Y SOCIAL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textoClaro,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline_rounded,
                          color: AppColors.moradoPrincipal),
                      title: const Text('Mi Perfil y QR',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Ver mi info y código compartido'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen())),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.qr_code_scanner_rounded,
                          color: AppColors.moradoPrincipal),
                      title: const Text('Escanear Amigo',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Agregar a un compañero por QR'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ScannerScreen())),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.people_outline_rounded,
                          color: AppColors.moradoPrincipal),
                      title: const Text('Mis Amigos',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Ver lista y comparar horarios'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FriendsListScreen())),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sección Cuenta
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  'CUENTA',
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
                  leading:
                      const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: const Text('Cerrar Sesión',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent)),
                  onTap: () {
                    context.read<AuthService>().signOut();
                    Navigator.pop(context); // Volver al AuthWrapper
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
                    child: const Icon(Icons.info_outline_rounded,
                        color: AppColors.textoMedio),
                  ),
                  title: const Text('Versión',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Text('3.5.0',
                      style: TextStyle(color: AppColors.textoClaro)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
