// file: lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/materia_provider.dart';
import 'providers/horario_provider.dart';
import 'providers/nota_provider.dart';
import 'providers/corte_provider.dart';
import 'providers/evaluacion_provider.dart';
import 'providers/tarea_provider.dart';
import 'providers/apunte_provider.dart';
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
        ChangeNotifierProvider(create: (_) => TareaProvider()),
        ChangeNotifierProvider(create: (_) => ApunteProvider()),
      ],
      child: MaterialApp(
        title: 'My Horario U',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigation(),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    MateriasScreen(),
    HorarioScreen(),
    NotasScreen(),
    ApuntesScreen(),
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
      await horarioProvider.scheduleClassNotifications();
    }
  }

  void _onNavigationChanged() {
    if (navigationNotifier.value != _selectedIndex) {
      setState(() => _selectedIndex = navigationNotifier.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.fondoCard,
          border: Border(
            top: BorderSide(color: AppColors.borde, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.moradoPrincipal.withOpacity(0.06),
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
            selectedItemColor: AppColors.moradoPrincipal,
            unselectedItemColor: AppColors.textoClaro,
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
