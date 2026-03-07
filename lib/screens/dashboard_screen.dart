// file: lib/screens/dashboard_screen.dart
// REEMPLAZAR TODOS LOS COLORES HARDCODEADOS POR LOS DE AppColors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/materia_provider.dart';
import '../providers/horario_provider.dart';
import '../providers/nota_provider.dart';
import '../providers/corte_provider.dart';
import '../providers/evaluacion_provider.dart';
import '../screens/qr_screen.dart';
import 'dart:async';
import '../models/horario.dart';
import '../theme/app_theme.dart'; // NUEVO IMPORT
import '../services/auth_service.dart'; // NUEVO import
import 'settings_screen.dart'; // NUEVO import

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Horario U'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
              child: Consumer<AuthService>(
                builder: (context, auth, _) {
                  final user = auth.currentUser;
                  return CircleAvatar(
                    backgroundColor: AppColors.moradoClaro,
                    radius: 18,
                    backgroundImage: user?.photoURL != null 
                        ? NetworkImage(user!.photoURL!) 
                        : null,
                    child: user?.photoURL == null 
                        ? const Icon(
                            Icons.person_rounded,
                            color: AppColors.moradoPrincipal,
                            size: 20,
                          )
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QRScreen()),
        ),
        icon: const Icon(Icons.qr_code_2_rounded),
        label: const Text('Mi QR'),
      ),
      body: Consumer5<MateriaProvider, HorarioProvider, NotaProvider,
          CorteProvider, EvaluacionProvider>(
        builder: (context, materiaProvider, horarioProvider, notaProvider,
            corteProvider, evaluacionProvider, _) {
          final materias = materiaProvider.materias;
          final claseActual = horarioProvider.getClaseActual();
          final proximaClase = horarioProvider.getProximaClase();

          double promedioGeneral = 0;
          int materiasConNotas = 0;

          for (var materia in materias) {
            corteProvider.loadCortesByMateria(materia.id!);
            final cortes = corteProvider.getCortesByMateria(materia.id!);
            if (cortes.isNotEmpty) {
              double pm = 0;
              for (var corte in cortes) {
                if (corte.id != null) {
                  evaluacionProvider.loadEvaluacionesByCorte(corte.id!);
                  pm += evaluacionProvider.calcularPromedioCorte(corte.id!) *
                      (corte.porcentaje / 100);
                }
              }
              if (pm > 0) {
                promedioGeneral += pm;
                materiasConNotas++;
              }
            }
          }
          if (materiasConNotas > 0) {
            promedioGeneral /= materiasConNotas;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPromedioCard(promedioGeneral),
                const SizedBox(height: 16),
                if (claseActual != null) ...[
                  _ClaseActualCard(horario: claseActual, materiaProvider: materiaProvider),
                  const SizedBox(height: 16),
                ] else if (proximaClase != null) ...[
                  _buildProximaClaseCard(
                      context, proximaClase, materiaProvider),
                  const SizedBox(height: 16),
                ],
                _buildAlertasCard(materias, corteProvider, evaluacionProvider),
                const SizedBox(height: 16),
                _buildMateriasResumen(
                  context,
                  materias,
                  corteProvider,
                  evaluacionProvider,
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromedioCard(double promedio) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.moradoPrincipal, AppColors.moradoOscuro],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.moradoPrincipal.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PROMEDIO GENERAL',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                promedio.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProximaClaseCard(
      BuildContext context, horario, MateriaProvider mp) {
    final materia = mp.getMateriaById(horario.materiaId);
    if (materia == null) return const SizedBox();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : AppColors.acentoClaro,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Theme.of(context).colorScheme.outline : AppColors.acento.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.acento,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.access_time_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PRÓXIMA CLASE',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: isDark ? const Color(0xFFC7B1F3) : AppColors.acentoOscuro)),
                const SizedBox(height: 4),
                Text(materia.nombre,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface)),
                Text(
                  '${_convertirA12H(horario.horaInicio)} · ${horario.aula}',
                  style: TextStyle(
                      color: isDark ? Colors.white60 : AppColors.textoMedio, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertasCard(
      List materias, CorteProvider cp, EvaluacionProvider ep) {
    final enRiesgo = <Map<String, dynamic>>[];
    for (var m in materias) {
      final cortes = cp.getCortesByMateria(m.id!);
      if (cortes.isEmpty) continue;
      double pm = 0;
      for (var c in cortes) {
        if (c.id != null)
          pm += ep.calcularPromedioCorte(c.id!) * (c.porcentaje / 100);
      }
      if (pm > 0 && pm < 3.5) enRiesgo.add({'materia': m, 'promedio': pm});
    }

    if (enRiesgo.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.riesgoClaro,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.riesgo.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.riesgo),
              SizedBox(width: 8),
              Text('ALERTAS ACADÉMICAS',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.riesgo,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          ...enRiesgo.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '⚠ ${item['materia'].nombre}: ${item['promedio'].toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.riesgo),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMateriasResumen(
      BuildContext context, List materias, CorteProvider cp, EvaluacionProvider ep) {
    if (materias.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No tienes materias registradas')),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TUS MATERIAS',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textoMedio,
                letterSpacing: 1)),
        const SizedBox(height: 12),
        ...materias.map((materia) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final cortes = cp.getCortesByMateria(materia.id!);
          double pm = 0;
          for (var c in cortes) {
            if (c.id != null)
              pm += ep.calcularPromedioCorte(c.id!) * (c.porcentaje / 100);
          }

          final estado = _getEstado(pm);
          final color = _getColorEstado(estado);
          final colorBg = _getColorBgEstado(estado);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Theme.of(context).colorScheme.surface : AppColors.fondoCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? Theme.of(context).colorScheme.outline : AppColors.borde),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Color(materia.color),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(materia.nombre,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface)),
                      Text('${materia.profesor} · ${materia.creditos} créditos',
                          style: TextStyle(
                              color: isDark ? Colors.white60 : AppColors.textoClaro, fontSize: 12)),
                    ],
                  ),
                ),
                if (pm > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      pm.toStringAsFixed(2),
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _convertirA12H(String hora24) {
    final parts = hora24.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour:$minute $period';
  }

  String _getEstado(double p) {
    if (p >= 3.5) return 'ganando';
    if (p >= 3.0) return 'riesgo';
    return 'perdiendo';
  }

  Color _getColorEstado(String e) {
    switch (e) {
      case 'ganando':
        return AppColors.exito;
      case 'riesgo':
        return AppColors.riesgo;
      case 'perdiendo':
        return AppColors.peligro;
      default:
        return Colors.grey;
    }
  }

  Color _getColorBgEstado(String e) {
    switch (e) {
      case 'ganando':
        return AppColors.exitoClaro;
      case 'riesgo':
        return AppColors.riesgoClaro;
      case 'perdiendo':
        return AppColors.peligroClaro;
      default:
        return AppColors.fondoSurface;
    }
  }
}

class _ClaseActualCard extends StatefulWidget {
  final Horario horario;
  final MateriaProvider materiaProvider;

  const _ClaseActualCard({
    required this.horario,
    required this.materiaProvider,
  });

  @override
  State<_ClaseActualCard> createState() => _ClaseActualCardState();
}

class _ClaseActualCardState extends State<_ClaseActualCard> {
  late Timer _timer;
  Duration _tiempoRestante = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calcularTiempoRestante();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calcularTiempoRestante();
    });
  }

  void _calcularTiempoRestante() {
    final partesParseadas = widget.horario.horaFin.split(':');
    final horaFin = int.parse(partesParseadas[0]);
    final minFin = int.parse(partesParseadas[1]);

    final ahora = DateTime.now();
    final fechaFin = DateTime(ahora.year, ahora.month, ahora.day, horaFin, minFin);

    setState(() {
      _tiempoRestante = fechaFin.difference(ahora);
      if (_tiempoRestante.isNegative) {
        _tiempoRestante = Duration.zero;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds <= 0) return "Terminando...";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return d.inHours > 0 ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }

  String _convertirA12H(BuildContext context, String hora24) {
    final parts = hora24.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    final materia = widget.materiaProvider.getMateriaById(widget.horario.materiaId);
    if (materia == null) return const SizedBox();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF431407) : AppColors.peligroFondo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF7B2A18) : AppColors.peligro.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.peligro,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.play_circle_fill_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('EN CURSO',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: isDark ? const Color(0xFFFCA5A5) : AppColors.peligro)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.peligro,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatDuration(_tiempoRestante),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(materia.nombre,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface)),
                Text(
                  'Termina a las ${_convertirA12H(context, widget.horario.horaFin)} · ${widget.horario.aula}',
                  style: TextStyle(
                      color: isDark ? Colors.white60 : AppColors.textoMedio, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
