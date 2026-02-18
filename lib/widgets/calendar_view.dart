// file: lib/widgets/calendar_view.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/tarea_provider.dart';
import '../providers/materia_provider.dart';
import '../theme/app_theme.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Consumer2<TareaProvider, MateriaProvider>(
      builder: (context, tareaProvider, materiaProvider, _) {
        final tareasMes = tareaProvider.getTareasDelMes(
          _focusedDay.year,
          _focusedDay.month,
        );

        return Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.moradoPrincipal.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.moradoPrincipal,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.peligro,
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.moradoPrincipal,
                  ),
                ),
                eventLoader: (day) {
                  final fecha = DateFormat('yyyy-MM-dd').format(day);
                  return tareasMes[fecha] ?? [];
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
              ),
            ),
            if (_selectedDay != null) ...[
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'TAREAS DEL DÍA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.moradoPrincipal,
                  ),
                ),
              ),
              Expanded(
                child: _buildTareasList(
                  context,
                  tareasMes[DateFormat('yyyy-MM-dd').format(_selectedDay!)] ??
                      [],
                  materiaProvider,
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Text(
                    'Selecciona un día para ver las tareas',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTareasList(
    BuildContext context,
    List tareas,
    MateriaProvider materiaProvider,
  ) {
    if (tareas.isEmpty) {
      return Center(
        child: Text(
          'No hay tareas para este día',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tareas.length,
      itemBuilder: (context, index) {
        final tarea = tareas[index];
        final materia = materiaProvider.getMateriaById(tarea.materiaId);

        if (materia == null) return const SizedBox();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 4,
              height: 50,
              color: Color(materia.color),
            ),
            title: Text(
              tarea.titulo,
              style: TextStyle(
                decoration:
                    tarea.completada ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(materia.nombre),
                if (tarea.descripcion.isNotEmpty)
                  Text(
                    tarea.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: Icon(
              tarea.completada
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: tarea.completada ? Colors.green : AppColors.peligro,
            ),
          ),
        );
      },
    );
  }
}
