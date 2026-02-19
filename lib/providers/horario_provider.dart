// file: lib/providers/horario_provider.dart
import 'package:flutter/material.dart';
import '../models/horario.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class HorarioProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final NotificationService _notifications = NotificationService.instance;
  List<Horario> _horarios = [];

  List<Horario> get horarios => _horarios;

  HorarioProvider() {
    loadHorarios();
  }

  Future<void> loadHorarios() async {
    _horarios = await _db.getHorarios();
    notifyListeners();

    // NUEVO: Programar notificaciones al cargar horarios
    await scheduleClassNotifications();
  }

  Future<void> addHorario(Horario horario) async {
    await _db.insertHorario(horario);
    await loadHorarios();
  }

  Future<void> deleteHorario(int id) async {
    // NUEVO: Cancelar notificaciones asociadas
    await _notifications.cancelClaseNotification(id);
    await _db.deleteHorario(id);
    await loadHorarios();
  }

  List<Horario> getHorariosByDia(int dia) {
    return _horarios.where((h) => h.diaSemana == dia).toList();
  }

  Horario? getProximaClase() {
    final ahora = DateTime.now();
    final diaActual = ahora.weekday;
    final horaActual = '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';

    // Buscar en el día actual
    final clasesHoy = getHorariosByDia(diaActual)
        .where((h) => h.horaInicio.compareTo(horaActual) > 0)
        .toList()
      ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

    if (clasesHoy.isNotEmpty) {
      return clasesHoy.first;
    }

    // Buscar en días siguientes
    for (int i = 1; i <= 6; i++) {
      final siguienteDia = (diaActual + i) > 6 ? (diaActual + i) - 6 : diaActual + i;
      final clasesSiguienteDia = getHorariosByDia(siguienteDia);
      if (clasesSiguienteDia.isNotEmpty) {
        clasesSiguienteDia.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
        return clasesSiguienteDia.first;
      }
    }

    return null;
  }

  // NUEVO: Programar notificaciones para todas las clases de la semana
  Future<void> scheduleClassNotifications() async {
    final ahora = DateTime.now();

    // Recorrer los próximos 7 días
    for (int i = 0; i < 7; i++) {
      final fecha = ahora.add(Duration(days: i));
      final dia = fecha.weekday;

      final clasesDelDia = getHorariosByDia(dia);

      for (var horario in clasesDelDia) {
        await _scheduleNotificationForClass(horario, fecha);
      }
    }

    debugPrint('✅ Notificaciones de clases programadas para la semana');
  }

  Future<void> _scheduleNotificationForClass(Horario horario, DateTime fecha) async {
    try {
      // Parsear hora de inicio
      final parts = horario.horaInicio.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Crear DateTime exacto de la clase
      final claseDateTime = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hour,
        minute,
      );

      // Solo programar si es en el futuro
      if (claseDateTime.isBefore(DateTime.now())) {
        return;
      }

      // Notificación 30 minutos antes
      final notif30min = claseDateTime.subtract(const Duration(minutes: 30));
      if (notif30min.isAfter(DateTime.now())) {
        await _notifications.scheduleClaseNotification(
          id: horario.id! * 100, // ID único para 30 min
          materiaNombre: 'Próxima clase', // Se completa en el provider de materias
          fechaHora: claseDateTime,
          aula: horario.aula,
        );
        debugPrint('✅ Notificación 30min programada: ${horario.id} - $notif30min');
      }

      // Notificación 60 minutos antes
      final notif60min = claseDateTime.subtract(const Duration(minutes: 60));
      if (notif60min.isAfter(DateTime.now())) {
        await _notifications.scheduleClaseNotification(
          id: horario.id! * 1000, // ID único para 60 min
          materiaNombre: 'Clase en 1 hora',
          fechaHora: claseDateTime,
          aula: horario.aula,
        );
        debugPrint('✅ Notificación 60min programada: ${horario.id} - $notif60min');
      }
    } catch (e) {
      debugPrint('❌ Error programando notificación: $e');
    }
  }

  // NUEVO: Método manual para reprogramar notificaciones
  Future<void> reprogramarNotificaciones() async {
    await _notifications.cancelAllNotifications();
    await scheduleClassNotifications();
    debugPrint('✅ Todas las notificaciones reprogramadas');
  }
}
