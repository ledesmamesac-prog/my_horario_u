// file: lib/screens/horario_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/horario.dart';
import '../providers/horario_provider.dart';
import '../providers/materia_provider.dart';
import '../providers/corte_provider.dart';
import '../providers/evaluacion_provider.dart';
import '../providers/tarea_provider.dart';
import '../widgets/materia_detail_modal.dart';
import '../widgets/calendar_view.dart';
import 'notas_screen.dart';
import '../theme/app_theme.dart';

enum VistaHorario { semanal, mensual, tareas }

class HorarioScreen extends StatefulWidget {
  const HorarioScreen({super.key});

  @override
  State<HorarioScreen> createState() => _HorarioScreenState();
}

class _HorarioScreenState extends State<HorarioScreen> {
  final List<String> dias = const ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
  VistaHorario _vistaActual = VistaHorario.semanal;

  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _bodyScrollController = ScrollController();
  final ScrollController _timeAxisScrollController = ScrollController();
  final ScrollController _bodyHorizontalScrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    final materiaProvider = context.read<MateriaProvider>();
    final tareaProvider = context.read<TareaProvider>();
    for (var materia in materiaProvider.materias) {
      tareaProvider.loadTareasByMateria(materia.id!);
    }

    _bodyHorizontalScrollController.addListener(() {
      _headerScrollController.jumpTo(_bodyHorizontalScrollController.offset);
    });
     _bodyScrollController.addListener(() {
      _timeAxisScrollController.jumpTo(_bodyScrollController.offset);
    });
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _bodyScrollController.dispose();
    _timeAxisScrollController.dispose();
    _bodyHorizontalScrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HORARIO'),
        actions: [
          PopupMenuButton<VistaHorario>(
            icon: const Icon(Icons.view_module),
            onSelected: (vista) => setState(() => _vistaActual = vista),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: VistaHorario.semanal,
                child: Row(
                  children: [
                    Icon(Icons.view_week),
                    SizedBox(width: 8),
                    Text('Vista Semanal'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: VistaHorario.mensual,
                child: Row(
                  children: [
                    Icon(Icons.calendar_month),
                    SizedBox(width: 8),
                    Text('Vista Mensual'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: VistaHorario.tareas,
                child: Row(
                  children: [
                    Icon(Icons.task),
                    SizedBox(width: 8),
                    Text('Vista de Tareas'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildVistaActual(),
      floatingActionButton: _vistaActual == VistaHorario.semanal
          ? FloatingActionButton(
              onPressed: () => _showHorarioDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildVistaActual() {
    switch (_vistaActual) {
      case VistaHorario.semanal:
        return _buildVistaSemanal();
      case VistaHorario.mensual:
        return const CalendarView();
      case VistaHorario.tareas:
        return _buildVistaTareas();
    }
  }

  Widget _buildVistaSemanal() {
    return Consumer2<HorarioProvider, MateriaProvider>(
      builder: (context, hp, mp, _) {
        return Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Row(
                children: [
                  _buildEjeHoras(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _bodyHorizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                         width: MediaQuery.of(context).size.width * 1.8,
                        child: SingleChildScrollView(
                          controller: _bodyScrollController,
                          child: Row(
                             crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                                6,
                                (i) => Expanded(
                                      child: _buildDiaColumn(context, i + 1, hp, mp),
                                    )),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEjeHoras() {
    final horas = List.generate(18, (i) => i + 6); // 6AM a 8PM

    return SizedBox(
      width: 48,
      child: SingleChildScrollView(
        controller: _timeAxisScrollController,
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: horas.map((h) {
            final label = h < 12 ? '${h}am' : (h == 12 ? '12pm' : '${h - 12}pm');
            return Container(
              height: 64,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textoClaro,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildVistaTareas() {
    return Consumer2<TareaProvider, MateriaProvider>(
      builder: (context, tareaProvider, materiaProvider, _) {
        final ahora = DateTime.now();
        final tareasMes =
            tareaProvider.getTareasDelMes(ahora.year, ahora.month);

        if (tareasMes.isEmpty) {
          return const Center(
            child: Text(
              'No hay tareas este mes',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final fechasOrdenadas = tareasMes.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: fechasOrdenadas.length,
          itemBuilder: (context, index) {
            final fecha = fechasOrdenadas[index] as DateTime;
            final tareas = tareasMes[fecha]!;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.fondoCard,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.moradoPrincipal,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${fecha.day} de ${_getNombreMes(fecha.month)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.moradoPrincipal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...tareas.map((tarea) {
                    final materia =
                        materiaProvider.getMateriaById(tarea.materiaId);
                    if (materia == null) return const SizedBox();

                    return ListTile(
                      leading: Container(
                        width: 4,
                        height: 50,
                        color: Color(materia.color),
                      ),
                      title: Text(
                        tarea.titulo,
                        style: TextStyle(
                          decoration: tarea.completada
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(materia.nombre),
                      trailing: Icon(
                        tarea.completada
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: tarea.completada
                            ? Colors.green
                            : const Color(0xFFFF00E5),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getNombreMes(int mes) {
    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return meses[mes - 1];
  }

  Widget _buildHeader() {
    final ahora = DateTime.now();
    return SizedBox(
      height: 52,
      child: Row(
        children: [
           SizedBox(width: 48),
          Expanded(
            child: SingleChildScrollView(
              controller: _headerScrollController,
               physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                 width: MediaQuery.of(context).size.width * 1.8,
                child: Row(
                  children: List.generate(6, (i) {
                    final dia = dias[i];
                    final esHoy = (ahora.weekday == i + 1);
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: esHoy
                              ? AppColors.moradoPrincipal
                              : AppColors.fondoSurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            dia,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: esHoy ? Colors.white : AppColors.textoMedio,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaColumn(
    BuildContext context,
    int dia,
    HorarioProvider hp,
    MateriaProvider mp,
  ) {
    final horariosDelDia = hp.getHorariosByDia(dia);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.borde, width: 1),
        ),
      ),
      child: Stack(
        children: [
          // Líneas de horas
          Column(
            children: List.generate(
                18,
                (i) => Container(
                      height: 64,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: AppColors.borde.withOpacity(0.5),
                              width: 1),
                        ),
                      ),
                    )),
          ),
          // Bloques de clases
          ...horariosDelDia.map((horario) {
            final materia = mp.getMateriaById(horario.materiaId);
            if (materia == null) return const SizedBox();

            final inicio = _parseHour(horario.horaInicio);
            final fin = _parseHour(horario.horaFin);
            final top = (inicio - 6) * 64.0;
            final height = (fin - inicio) * 64.0;

            return Positioned(
              top: top,
              left: 2,
              right: 2,
              height: height - 2,
              child: GestureDetector(
                onTap: () => _mostrarDetalleMateria(context, materia),
                onLongPress: () => _confirmDeleteHorario(context, horario),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Color(materia.color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color(materia.color),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(materia.color).withOpacity(0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        materia.nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: Color(materia.color),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (height > 48) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${_convertirA12H(horario.horaInicio)}–${_convertirA12H(horario.horaFin)}',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textoMedio,
                          ),
                        ),
                        if (horario.aula.isNotEmpty)
                          Text(
                            horario.aula,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textoMedio,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  double _parseHour(String hora24) {
    final parts = hora24.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return h + m / 60.0;
  }

  void _mostrarDetalleMateria(BuildContext context, materia) {
    final corteProvider = context.read<CorteProvider>();
    final evaluacionProvider = context.read<EvaluacionProvider>();

    corteProvider.loadCortesByMateria(materia.id!);
    final cortes = corteProvider.getCortesByMateria(materia.id!);

    double promedio = 0;
    if (cortes.isNotEmpty) {
      for (var corte in cortes) {
        if (corte.id != null) {
          evaluacionProvider.loadEvaluacionesByCorte(corte.id!);
          final promedioCorte =
              evaluacionProvider.calcularPromedioCorte(corte.id!);
          promedio += promedioCorte * (corte.porcentaje / 100);
        }
      }
    }

    String estado = 'sin notas';
    Color colorEstado = Colors.grey;

    if (promedio > 0) {
      if (promedio >= 3.5) {
        estado = 'ganando';
        colorEstado = Colors.green;
      } else if (promedio >= 3.0) {
        estado = 'riesgo';
        colorEstado = Colors.orange;
      } else {
        estado = 'perdiendo';
        colorEstado = Colors.red;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MateriaDetailModal(
        materia: materia,
        promedio: promedio,
        estado: estado,
        colorEstado: colorEstado,
        onVerNotas: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotasScreen(),
            ),
          );
        },
      ),
    );
  }

  String _convertirA12H(String hora24) {
    final parts = hora24.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }

  void _showHorarioDialog(BuildContext context) {
    final materiaProvider = context.read<MateriaProvider>();
    final materias = materiaProvider.materias;

    if (materias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero debes crear materias')),
      );
      return;
    }

    int? selectedMateriaId = materias.first.id;
    int selectedDia = 1;
    TimeOfDay horaInicio = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay horaFin = const TimeOfDay(hour: 10, minute: 0);
    final aulaController = TextEditingController();
    String selectedModalidad = 'Presencial';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.fondoCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borde,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Nuevo Horario',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textoOscuro)),
                const SizedBox(height: 20),

                DropdownButtonFormField<int>(
                  value: selectedMateriaId,
                  decoration: const InputDecoration(labelText: 'Materia'),
                  items: materias
                      .map((m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.nombre),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedMateriaId = val),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<int>(
                  value: selectedDia,
                  decoration: const InputDecoration(labelText: 'Día'),
                  items: List.generate(
                      6,
                      (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(dias[i]),
                          )),
                  onChanged: (val) => setState(() => selectedDia = val!),
                ),
                const SizedBox(height: 12),

                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: horaInicio,
                    );
                    if (picked != null) setState(() => horaInicio = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Hora Inicio',
                      suffixIcon: Icon(Icons.access_time_rounded),
                    ),
                    child: Text(_formatTimeOfDay(horaInicio)),
                  ),
                ),
                const SizedBox(height: 12),

                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: horaFin,
                    );
                    if (picked != null) setState(() => horaFin = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Hora Fin',
                      suffixIcon: Icon(Icons.access_time_rounded),
                    ),
                    child: Text(_formatTimeOfDay(horaFin)),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: aulaController,
                  decoration: const InputDecoration(labelText: 'Aula'),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: selectedModalidad,
                  decoration: const InputDecoration(labelText: 'Modalidad'),
                  items: ['Presencial', 'Virtual']
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedModalidad = val!),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_esHoraValida(horaInicio, horaFin)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'La hora de fin debe ser mayor que la de inicio'),
                            backgroundColor: AppColors.peligro,
                          ),
                        );
                        return;
                      }
                      final nuevoHorario = Horario(
                        materiaId: selectedMateriaId!,
                        diaSemana: selectedDia,
                        horaInicio: _timeOfDayTo24HString(horaInicio),
                        horaFin: _timeOfDayTo24HString(horaFin),
                        aula: aulaController.text,
                        modalidad: selectedModalidad,
                      );
                      context.read<HorarioProvider>().addHorario(nuevoHorario);
                      Navigator.pop(context);
                    },
                    child: const Text('Guardar Horario'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _timeOfDayTo24HString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _esHoraValida(TimeOfDay inicio, TimeOfDay fin) {
    final inicioMinutos = inicio.hour * 60 + inicio.minute;
    final finMinutos = fin.hour * 60 + fin.minute;
    return finMinutos > inicioMinutos;
  }

  void _confirmDeleteHorario(BuildContext context, Horario horario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.fondoCard,
        title: const Text('CONFIRMAR'),
        content: const Text('¿Eliminar este horario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<HorarioProvider>().deleteHorario(horario.id!);
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}
