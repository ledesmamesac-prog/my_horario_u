// file: lib/providers/materia_provider.dart
import 'package:flutter/material.dart';
import '../models/materia.dart';
import '../services/database_service.dart';

class MateriaProvider extends ChangeNotifier {
  List<Materia> _materias = [];
  final DatabaseService _db = DatabaseService.instance;

  List<Materia> get materias => _materias;

  MateriaProvider() {
    loadMaterias();
  }

  Future<void> loadMaterias() async {
    _materias = await _db.getMaterias();
    notifyListeners();
  }

  Future<void> addMateria(Materia materia) async {
    await _db.insertMateria(materia);
    await loadMaterias();
  }

  Future<void> updateMateria(Materia materia) async {
    await _db.updateMateria(materia);
    await loadMaterias();
  }

  Future<void> deleteMateria(int id) async {
    await _db.deleteMateria(id);
    await loadMaterias();
  }

  Materia? getMateriaById(int id) {
    try {
      return _materias.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }
}
