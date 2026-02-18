// file: lib/providers/corte_provider.dart
import 'package:flutter/material.dart';
import '../models/corte.dart';
import '../services/database_service.dart';

class CorteProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  Map<int, List<Corte>> _cortesPorMateria = {};

  Map<int, List<Corte>> get cortesPorMateria => _cortesPorMateria;

  Future<void> loadCortesByMateria(int materiaId) async {
    final cortes = await _db.getCortesByMateria(materiaId);
    _cortesPorMateria[materiaId] = cortes;
    notifyListeners();
  }

  Future<void> addCorte(Corte corte) async {
    await _db.insertCorte(corte);
    await loadCortesByMateria(corte.materiaId);
  }

  Future<void> deleteCorte(int id, int materiaId) async {
    await _db.deleteCorte(id);
    await loadCortesByMateria(materiaId);
  }

  Future<void> updateCorte(Corte corte) async {
    await _db.updateCorte(corte);
    await loadCortesByMateria(corte.materiaId);
  }

  List<Corte> getCortesByMateria(int materiaId) {
    return _cortesPorMateria[materiaId] ?? [];
  }

  bool validarPorcentajes(int materiaId) {
    final cortes = _cortesPorMateria[materiaId] ?? [];
    if (cortes.isEmpty) return true;

    double suma = 0;
    for (var corte in cortes) {
      suma += corte.porcentaje;
    }

    return (suma - 100.0).abs() < 0.01;
  }

  double getPorcentajeDisponible(int materiaId) {
    final cortes = _cortesPorMateria[materiaId] ?? [];
    double suma = 0;
    for (var corte in cortes) {
      suma += corte.porcentaje;
    }
    return 100.0 - suma;
  }
}
