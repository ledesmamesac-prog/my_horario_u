// file: lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/sync_service.dart';
import 'providers/evaluacion_provider.dart';
import 'providers/social_provider.dart';
import 'screens/login_screen.dart';
import 'providers/materia_provider.dart';
import 'providers/horario_provider.dart';
import 'providers/nota_provider.dart';
import 'providers/corte_provider.dart';
import 'providers/tarea_provider.dart';
import 'providers/apunte_provider.dart';
import 'providers/theme_provider.dart'; // NUEVO
import 'screens/dashboard_screen.dart';
import 'screens/materias_screen.dart';
import 'screens/horario_screen.dart';
import 'screens/notas_screen.dart';
import 'screens/apuntes_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';  // NUEVO
import 'package:intl/intl.dart';                    // NUEVO

final ValueNotifier<int> navigationNotifier = ValueNotifier<int>(0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // NUEVO: Inicializar locale español
  await initializeDateFormatting('es', null);
  Intl.defaultLocale = 'es';
  debugPrint('✅ Locale español inicializado');

  // Inicializar notificaciones
  await NotificationService.instance.initialize();

  runApp(const MyHorarioU());
}

class MyHorarioU extends StatelessWidget {
  const MyHorarioU({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MateriaProvider()),
        ChangeNotifierProvider(create: (_) => HorarioProvider()), // Auto-programa notificaciones
        ChangeNotifierProvider(create: (_) => NotaProvider()),
        ChangeNotifierProvider(create: (_) => CorteProvider()),
        ChangeNotifierProvider(create: (_) => EvaluacionProvider()),
        ChangeNotifierProvider(create: (_) => SocialProvider()),
        ChangeNotifierProvider(create: (_) => TareaProvider()),
        ChangeNotifierProvider(create: (_) => ApunteProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // NUEVO
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'My Horario U',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthWrapper(),
          routes: {
            '/dashboard': (context) => const MainNavigation(),
            '/materias': (context) => const MateriasScreen(),
            '/horario': (context) => const HorarioScreen(),
            '/notas': (context) => const NotasScreen(),
            '/apuntes': (context) => const ApuntesScreen(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // Usuario logueado: Disparar sincronización inicial una vez
          if (!_isSyncing) {
            _handleInitialSync(context);
          }
          return const MainNavigation();
        }

        return const LoginScreen();
      },
    );
  }

  Future<void> _handleInitialSync(BuildContext context) async {
    setState(() { _isSyncing = true; });
    
    debugPrint("🔄 Iniciando sincronización de datos...");
    
    try {
      // 1. Subir local a nube (por si tiene datos previos al login)
      await SyncService.instance.pushAllToCloud();
      
      // 2. Traer nube a local (por si viene de otro dispositivo)
      await SyncService.instance.syncFromCloud();
      
      // 3. Recargar todos los providers para mostrar datos frescos
      if (mounted) {
        context.read<MateriaProvider>().loadMaterias();
        context.read<HorarioProvider>().loadHorarios();
        context.read<TareaProvider>().loadAllTareas(); // Nota: Asegúrate de que exista
        context.read<NotaProvider>().notasPorMateria.clear(); // Forzar recarga bajo demanda
        context.read<ApunteProvider>().loadApuntes();
      }
      
      debugPrint("✅ Sincronización completada con éxito");
    } catch (e) {
      debugPrint("❌ Error en sincronización inicial: $e");
    }
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MateriasScreen(),
    const HorarioScreen(),
    const NotasScreen(),
    const ApuntesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    navigationNotifier.addListener(_onNavigationChanged);
    WidgetsBinding.instance.addObserver(this);

    // NUEVO: Reprogramar notificaciones cuando la app vuelve al foreground
    _reprogramarNotificaciones();
  }

  @override
  void dispose() {
    navigationNotifier.removeListener(_onNavigationChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // NUEVO: Detectar cuando la app vuelve del background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reprogramarNotificaciones();
    }
  }

  Future<void> _reprogramarNotificaciones() async {
    // Esperar a que los providers estén listos
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      final horarioProvider = context.read<HorarioProvider>();
      final materiaProvider = context.read<MateriaProvider>();

      // Construir mapa materiaId → nombre para que las notificaciones
      // muestren el nombre real de cada materia
      final materiaNames = {
        for (var m in materiaProvider.materias)
          if (m.id != null) m.id!: m.nombre,
      };

      await horarioProvider.scheduleClassNotifications(
        materiaNames: materiaNames,
      );
    }
  }

  void _onNavigationChanged() {
    if (navigationNotifier.value != _selectedIndex) {
      setState(() => _selectedIndex = navigationNotifier.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : AppColors.moradoPrincipal.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() => _selectedIndex = index);
              navigationNotifier.value = index;
            },
            backgroundColor: Colors.transparent,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: isDark ? Colors.white60 : AppColors.textoClaro,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_rounded),
                label: 'Materias',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_rounded),
                label: 'Horario',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grade_rounded),
                label: 'Calificaciones',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sticky_note_2_rounded),
                label: 'Apuntes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
