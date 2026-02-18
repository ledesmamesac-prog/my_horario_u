// file: lib/providers/evaluacion_provider.dart
import 'package:flutter/material.dart';
import '../models/evaluacion.dart';
import '../models/materia.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class EvaluacionProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final NotificationService _notifications = NotificationService.instance;
  Map<int, List<Evaluacion>> _evaluacionesPorCorte = {};

  Map<int, List<Evaluacion>> get evaluacionesPorCorte => _evaluacionesPorCorte;

  Future<void> loadEvaluacionesByCorte(int corteId) async {
    final evaluaciones = await _db.getEvaluacionesByCorte(corteId);
    _evaluacionesPorCorte[corteId] = evaluaciones;
    notifyListeners();
  }

  Future<void> addEvaluacion(Evaluacion evaluacion, Materia materia) async {
    final id = await _db.insertEvaluacion(evaluacion);

    if (evaluacion.isPendiente && evaluacion.fecha != null) {
      final fecha = DateTime.parse(evaluacion.fecha!);
      if (fecha.isAfter(DateTime.now())) {
        await _notifications.scheduleActividadNotification(
          id: id,
          nombreActividad: evaluacion.tipo,
          materiaNombre: materia.nombre,
          fecha: fecha,
        );
      }
    }

    await loadEvaluacionesByCorte(evaluacion.corteId);
  }

  Future<void> updateEvaluacion(Evaluacion evaluacion, Materia materia) async {
    await _db.updateEvaluacion(evaluacion);

    await _notifications.cancelActividadNotification(evaluacion.id!);

    if (evaluacion.isPendiente && evaluacion.fecha != null) {
      final fecha = DateTime.parse(evaluacion.fecha!);
      if (fecha.isAfter(DateTime.now())) {
        await _notifications.scheduleActividadNotification(
          id: evaluacion.id!,
          nombreActividad: evaluacion.tipo,
          materiaNombre: materia.nombre,
          fecha: fecha,
        );
      }
    }

    await loadEvaluacionesByCorte(evaluacion.corteId);
  }

  Future<void> deleteEvaluacion(int id, int corteId) async {
    await _notifications.cancelActividadNotification(id);
    await _db.deleteEvaluacion(id);
    await loadEvaluacionesByCorte(corteId);
  }

  List<Evaluacion> getEvaluacionesByCorte(int corteId) {
    return _evaluacionesPorCorte[corteId] ?? [];
  }

  double calcularPromedioCorte(int corteId) {
    final evaluaciones = _evaluacionesPorCorte[corteId] ?? [];
    final evaluacionesCalificadas = evaluaciones
        .where((e) => e.notaObtenida != null && !e.isPendiente)
        .toList();

    if (evaluacionesCalificadas.isEmpty) return 0.0;

    double sumaPonderada = 0;
    for (var eval in evaluacionesCalificadas) {
      sumaPonderada += eval.notaObtenida! * (eval.porcentaje / 100);
    }

    return sumaPonderada;
  }

  bool validarPorcentajes(int corteId) {
    final evaluaciones = _evaluacionesPorCorte[corteId] ?? [];
    if (evaluaciones.isEmpty) return true;
    double suma = evaluaciones.fold(0, (prev, e) => prev + e.porcentaje);
    return (suma - 100.0).abs() < 0.01;
  }

  double getPorcentajeDisponible(int corteId) {
    final evaluaciones = _evaluacionesPorCorte[corteId] ?? [];
    double suma = evaluaciones.fold(0, (prev, e) => prev + e.porcentaje);
    return 100.0 - suma;
  }
}
