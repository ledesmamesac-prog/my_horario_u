import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import '../providers/horario_provider.dart';
import '../providers/materia_provider.dart';
import '../models/horario.dart';
import '../models/materia.dart';
import '../theme/app_theme.dart';

class CompareSchedulesScreen extends StatefulWidget {
  final Map<String, dynamic> friend;

  const CompareSchedulesScreen({super.key, required this.friend});

  @override
  State<CompareSchedulesScreen> createState() => _CompareSchedulesScreenState();
}

class _CompareSchedulesScreenState extends State<CompareSchedulesScreen> {
  Map<String, dynamic>? _friendSchedule;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendSchedule();
  }

  Future<void> _loadFriendSchedule() async {
    final schedule = await context
        .read<SocialProvider>()
        .getFriendSchedule(widget.friend['uid']);
    if (mounted) {
      setState(() {
        _friendSchedule = schedule;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final myHorarios = context.watch<HorarioProvider>().horarios;
    final friendHorarios =
        (_friendSchedule?['horarios'] as List<Horario>?) ?? [];

    return DefaultTabController(
      length: 6, // Lunes a Sábado
      child: Scaffold(
        appBar: AppBar(
          title: Text('Vs ${widget.friend['nombre']}'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Lun'),
              Tab(text: 'Mar'),
              Tab(text: 'Mié'),
              Tab(text: 'Jue'),
              Tab(text: 'Vie'),
              Tab(text: 'Sáb'),
            ],
          ),
        ),
        body: TabBarView(
          children: List.generate(6, (index) {
            final dia = index + 1;
            final misClases = myHorarios
                .where((h) => h.diaSemana == dia)
                .toList()
              ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
            final clasesAmigo = friendHorarios
                .where((h) => h.diaSemana == dia)
                .toList()
              ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

            // Calcular huecos comunes
            final huecosComunes =
                _calcularHuecosComunes(misClases, clasesAmigo);

            return _buildComparisonView(misClases, clasesAmigo, huecosComunes);
          }),
        ),
      ),
    );
  }

  List<String> _calcularHuecosComunes(List<Horario> mis, List<Horario> amigo) {
    // Definimos la jornada de 06:00 a 22:00
    List<TimeRange> misLibres = _getLibres(mis);
    List<TimeRange> amigoLibres = _getLibres(amigo);

    List<String> comunes = [];
    for (var m in misLibres) {
      for (var a in amigoLibres) {
        final intersection = m.intersect(a);
        if (intersection != null && intersection.durationInMinutes >= 30) {
          comunes.add('${intersection.startStr} - ${intersection.endStr}');
        }
      }
    }
    return comunes;
  }

  List<TimeRange> _getLibres(List<Horario> clases) {
    List<TimeRange> ocupados = clases
        .map((h) => TimeRange.fromStrings(h.horaInicio, h.horaFin))
        .toList();
    ocupados.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

    List<TimeRange> libres = [];
    int current = 6 * 60; // 6:00 AM
    int endDay = 22 * 60; // 10:00 PM

    for (var o in ocupados) {
      if (o.startMinutes > current) {
        libres.add(TimeRange(current, o.startMinutes));
      }
      if (o.endMinutes > current) {
        current = o.endMinutes;
      }
    }
    if (current < endDay) {
      libres.add(TimeRange(current, endDay));
    }
    return libres;
  }

  Widget _buildComparisonView(
      List<Horario> misClases, List<Horario> clasesAmigo, List<String> huecos) {
    if (misClases.isEmpty && clasesAmigo.isEmpty) {
      return const Center(child: Text('Sin clases este día'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (huecos.isNotEmpty) ...[
          _buildSectionHeader('ESPACIOS LIBRES COMUNES 💡',
              color: Colors.green),
          ...huecos.map((h) => Card(
                elevation: 0,
                color: Colors.green.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green.withOpacity(0.2)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.auto_awesome, color: Colors.green),
                  title: Text(h,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green)),
                  subtitle: const Text('Momento ideal para estudiar o parchar'),
                ),
              )),
          const SizedBox(height: 24),
        ],
        _buildSectionHeader('MIS CLASES'),
        ...misClases.map((h) => _buildClaseTile(h, AppColors.moradoPrincipal, isMine: true)),
        const SizedBox(height: 24),
        _buildSectionHeader(
            'CLASES DE ${widget.friend['nombre'].toUpperCase()}'),
        ...clasesAmigo.map((h) => _buildClaseTile(h, Colors.orange, isMine: false)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color ?? AppColors.textoMedio,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildClaseTile(Horario h, Color accentColor, {required bool isMine}) {
    String nombreMateria = 'Materia';
    if (isMine) {
      nombreMateria = context.read<MateriaProvider>().getMateriaById(h.materiaId)?.nombre ?? 'Materia';
    } else {
      final friendMaterias = (_friendSchedule?['materias'] as List<Materia>?) ?? [];
      try {
        nombreMateria = friendMaterias.firstWhere((m) => m.id == h.materiaId).nombre;
      } catch (e) {
        nombreMateria = 'Materia';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 30,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(nombreMateria, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${h.horaInicio} - ${h.horaFin} · ${h.aula} (${h.modalidad})'),
        trailing: !isMine 
          ? IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.orange),
              onPressed: () => _showImportConfirm(h, nombreMateria),
            )
          : null,
      ),
    );
  }

  void _showImportConfirm(Horario horarioAmigo, String nombreMateria) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar Materia'),
        content: Text('¿Deseas copiar "$nombreMateria" y todos sus horarios a tu agenda?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _importMateria(horarioAmigo.materiaId, nombreMateria);
            },
            child: const Text('Copiar'),
          ),
        ],
      ),
    );
  }

  Future<void> _importMateria(int friendMateriaId, String nombreMateria) async {
    try {
      final friendMaterias = (_friendSchedule?['materias'] as List<Materia>?) ?? [];
      final friendHorarios = (_friendSchedule?['horarios'] as List<Horario>?) ?? [];
      
      final matAmiga = friendMaterias.firstWhere((m) => m.id == friendMateriaId);
      final horariosAmigos = friendHorarios.where((h) => h.materiaId == friendMateriaId).toList();

      // 1. Agregar materia y obtener nuevo ID
      final materiaProvider = context.read<MateriaProvider>();
      final nuevoId = await materiaProvider.addMateria(matAmiga.copyWith(id: null));

      // 2. Agregar horarios vinculados
      final horarioProvider = context.read<HorarioProvider>();
      for (var h in horariosAmigos) {
        await horarioProvider.addHorario(h.copyWith(id: null, materiaId: nuevoId));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Materia "$nombreMateria" importada con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar: $e')),
        );
      }
    }
  }
}

class TimeRange {
  final int startMinutes;
  final int endMinutes;

  TimeRange(this.startMinutes, this.endMinutes);

  factory TimeRange.fromStrings(String startStr, String endStr) {
    return TimeRange(_toMinutes(startStr), _toMinutes(endStr));
  }

  static int _toMinutes(String s) {
    final parts = s.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  int get durationInMinutes => endMinutes - startMinutes;

  String get startStr => _format(startMinutes);
  String get endStr => _format(endMinutes);

  String _format(int m) {
    final hour = m ~/ 60;
    final min = m % 60;
    return '${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
  }

  TimeRange? intersect(TimeRange other) {
    final start =
        startMinutes > other.startMinutes ? startMinutes : other.startMinutes;
    final end = endMinutes < other.endMinutes ? endMinutes : other.endMinutes;
    if (start < end) return TimeRange(start, end);
    return null;
  }
}
