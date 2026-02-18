// file: lib/providers/tarea_provider.dart
import 'package:flutter/material.dart';
import '../models/tarea.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class TareaProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final NotificationService _notifications = NotificationService.instance;
  Map<int, List<Tarea>> _tareasPorMateria = {};

  Map<int, List<Tarea>> get tareasPorMateria => _tareasPorMateria;

  Future<void> loadTareasByMateria(int materiaId) async {
    final tareas = await _db.getTareasByMateria(materiaId);
    _tareasPorMateria[materiaId] = tareas;
    notifyListeners();
  }

  Future<void> addTarea(Tarea tarea, String materiaNombre) async {
    final id = await _db.insertTarea(tarea);

    final fechaEntrega = DateTime.parse(tarea.fechaEntrega);
    if (fechaEntrega.isAfter(DateTime.now())) {
      await _notifications.scheduleTareaNotification(
        id: id,
        titulo: tarea.titulo,
        materiaNombre: materiaNombre,
        fechaEntrega: fechaEntrega,
      );
    }

    await loadTareasByMateria(tarea.materiaId);
  }

  Future<void> updateTarea(Tarea tarea, String materiaNombre) async {
    await _db.updateTarea(tarea);

    await _notifications.cancelTareaNotification(tarea.id!);

    final fechaEntrega = DateTime.parse(tarea.fechaEntrega);
    if (fechaEntrega.isAfter(DateTime.now())) {
      await _notifications.scheduleTareaNotification(
        id: tarea.id!,
        titulo: tarea.titulo,
        materiaNombre: materiaNombre,
        fechaEntrega: fechaEntrega,
      );
    }

    await loadTareasByMateria(tarea.materiaId);
  }

  Future<void> toggleTareaCompletada(Tarea tarea) async {
    final tareaActualizada = tarea.copyWith(completada: !tarea.completada);
    await _db.updateTarea(tareaActualizada);
    await loadTareasByMateria(tarea.materiaId);
  }

  Future<void> deleteTarea(int id, int materiaId) async {
    await _notifications.cancelTareaNotification(id);
    await _db.deleteTarea(id);
    await loadTareasByMateria(materiaId);
  }

  List<Tarea> getTareasByMateria(int materiaId) {
    return _tareasPorMateria[materiaId] ?? [];
  }

  List<Tarea> getTareasPendientes(int materiaId) {
    final tareas = _tareasPorMateria[materiaId] ?? [];
    return tareas.where((t) => !t.completada).toList();
  }

  // --- MÉTODOS RESTAURADOS PARA EL CALENDARIO ---
  
  List<Tarea> getTareasByFecha(DateTime fecha) {
    final List<Tarea> tareasDia = [];
    final fechaString = fecha.toIso8601String().split('T').first;
    for (var tareas in _tareasPorMateria.values) {
      tareasDia.addAll(tareas.where((t) => t.fechaEntrega.split('T').first == fechaString));
    }
    return tareasDia;
  }

  Map<DateTime, List<Tarea>> getTareasDelMes(int year, int month) {
    final Map<DateTime, List<Tarea>> tareasPorDia = {};

    // Cargar todas las tareas de todas las materias si aún no se ha hecho
    // Esto es un parche para asegurar que el calendario tenga datos.
    // Una mejor solución sería tener un método `loadAllTareas`.
    for (var materiaId in _tareasPorMateria.keys) {
       final tareasList = _tareasPorMateria[materiaId] ?? [];
        for (var tarea in tareasList) {
          final fecha = DateTime.parse(tarea.fechaEntrega);
          if (fecha.year == year && fecha.month == month) {
            final day = DateTime(fecha.year, fecha.month, fecha.day);
            if (tareasPorDia[day] == null) {
              tareasPorDia[day] = [];
            }
            tareasPorDia[day]!.add(tarea);
          }
        }
    }
    return tareasPorDia;
  }

  Color getPrioridadColor(String prioridad) {
    switch (prioridad) {
      case 'Alta':
        return Colors.red;
      case 'Media':
        return Colors.orange;
      case 'Baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
