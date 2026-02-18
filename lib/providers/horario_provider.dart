// file: lib/providers/horario_provider.dart
import 'package:flutter/material.dart';
import '../models/horario.dart';
import '../services/database_service.dart';

class HorarioProvider extends ChangeNotifier {
  List<Horario> _horarios = [];
  final DatabaseService _db = DatabaseService.instance;

  List<Horario> get horarios => _horarios;

  HorarioProvider() {
    loadHorarios();
  }

  Future<void> loadHorarios() async {
    _horarios = await _db.getHorarios();
    notifyListeners();
  }

  Future<void> addHorario(Horario horario) async {
    await _db.insertHorario(horario);
    await loadHorarios();
  }

  Future<void> deleteHorario(int id) async {
    await _db.deleteHorario(id);
    await loadHorarios();
  }

  List<Horario> getHorariosByDia(int dia) {
    return _horarios.where((h) => h.diaSemana == dia).toList();
  }

  Horario? getProximaClase() {
    final now = DateTime.now();
    final currentDay = now.weekday;
    final currentTime = TimeOfDay.now();

    for (var horario in _horarios) {
      if (horario.diaSemana == currentDay) {
        final horarioTime = _parseTime(horario.horaInicio);
        if (_isAfter(horarioTime, currentTime)) {
          return horario;
        }
      }
    }
    return null;
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  bool _isAfter(TimeOfDay a, TimeOfDay b) {
    return a.hour > b.hour || (a.hour == b.hour && a.minute > b.minute);
  }
}
