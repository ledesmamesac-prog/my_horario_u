// file: lib/providers/nota_provider.dart
import 'package:flutter/material.dart';
import '../models/nota.dart';
import '../services/database_service.dart';

class NotaProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  Map<int, List<Nota>> _notasPorMateria = {};

  Map<int, List<Nota>> get notasPorMateria => _notasPorMateria;

  Future<void> loadNotasByMateria(int materiaId) async {
    final notas = await _db.getNotasByMateria(materiaId);
    _notasPorMateria[materiaId] = notas;
    notifyListeners();
  }

  Future<void> addNota(Nota nota) async {
    await _db.insertNota(nota);
    await loadNotasByMateria(nota.materiaId);
  }

  Future<void> deleteNota(int id, int materiaId) async {
    await _db.deleteNota(id);
    await loadNotasByMateria(materiaId);
  }

  Future<void> updateNota(Nota nota) async {
    await _db.updateNota(nota);
    await loadNotasByMateria(nota.materiaId);
  }

  double calcularPromedio(int materiaId) {
    final notas = _notasPorMateria[materiaId] ?? [];
    if (notas.isEmpty) return 0.0;

    double suma = 0;
    double totalPorcentaje = 0;

    for (var nota in notas) {
      suma += nota.notaObtenida * (nota.porcentaje / 100);
      totalPorcentaje += nota.porcentaje;
    }

    if (totalPorcentaje == 0) return 0.0;
    return suma;
  }

  // NUEVO MÉTODO: Calcular promedio final usando cortes
  Future<double> calcularPromedioFinalConCortes(
    int materiaId,
    Map<int, double> promediosCortes,
    Map<int, double> porcentajesCortes,
  ) async {
    if (promediosCortes.isEmpty) return 0.0;

    double sumaTotal = 0;
    double totalPorcentaje = 0;

    promediosCortes.forEach((corteId, promedio) {
      final porcentaje = porcentajesCortes[corteId] ?? 0;
      sumaTotal += promedio * (porcentaje / 100);
      totalPorcentaje += porcentaje;
    });

    if (totalPorcentaje == 0) return 0.0;
    return sumaTotal;
  }

  String getEstado(double promedio) {
    if (promedio >= 3.5) return 'ganando';
    if (promedio >= 3.0) return 'riesgo';
    return 'perdiendo';
  }

  Color getColorEstado(String estado) {
    switch (estado) {
      case 'ganando':
        return Colors.green;
      case 'riesgo':
        return Colors.orange;
      case 'perdiendo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
