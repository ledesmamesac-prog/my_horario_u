// file: lib/providers/horario_provider.dart
import 'package:flutter/material.dart';
import '../models/horario.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/cloud_service.dart';

class HorarioProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final NotificationService _notifications = NotificationService.instance;
  final CloudService _cloud = CloudService.instance;
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
    final id = await _db.insertHorario(horario);
    final horarioConId = horario.copyWith(id: id);
    await _cloud.saveHorario(horarioConId);
    await loadHorarios();
  }

  Future<void> deleteHorario(int id) async {
    // NUEVO: Cancelar notificaciones asociadas
    await _notifications.cancelClaseNotification(id);
    await _db.deleteHorario(id);
    await _cloud.deleteHorario(id);
    await loadHorarios();
  }

  List<Horario> getHorariosByDia(int dia) {
    return _horarios.where((h) => h.diaSemana == dia).toList();
  }

  Horario? getClaseActual() {
    final ahora = DateTime.now();
    final diaActual = ahora.weekday;
    final horaActual = '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';

    final clasesHoy = getHorariosByDia(diaActual);
    for (var h in clasesHoy) {
      if (h.horaInicio.compareTo(horaActual) <= 0 && h.horaFin.compareTo(horaActual) > 0) {
        return h;
      }
    }
    return null;
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

  // Programar notificaciones para todas las clases de la semana
  // [materiaNames]: mapa de materiaId → nombre, para mostrar el nombre real en la notif
  Future<void> scheduleClassNotifications({
    Map<int, String> materiaNames = const {},
  }) async {
    final ahora = DateTime.now();

    // Recorrer los próximos 7 días
    for (int i = 0; i < 7; i++) {
      final fecha = ahora.add(Duration(days: i));
      final dia = fecha.weekday;

      final clasesDelDia = getHorariosByDia(dia);

      for (var horario in clasesDelDia) {
        final nombreMateria = materiaNames[horario.materiaId] ?? 'Clase';
        await _scheduleNotificationForClass(horario, fecha, nombreMateria);
      }
    }

    debugPrint('✅ Notificaciones de clases programadas para la semana');
  }

  Future<void> _scheduleNotificationForClass(
    Horario horario,
    DateTime fecha,
    String nombreMateria,
  ) async {
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

      // Solo programar si la clase es en el futuro
      if (claseDateTime.isBefore(DateTime.now())) {
        return;
      }

      // Una sola notificación: 30 minutos antes
      final notif30min = claseDateTime.subtract(const Duration(minutes: 30));
      if (notif30min.isAfter(DateTime.now())) {
        // ID estable: basado en el horario y el día de la semana (no colisiona)
        final notifId = 30000 + (horario.id! * 10) + fecha.weekday;
        await _notifications.scheduleClaseNotification(
          id: notifId,
          materiaNombre: nombreMateria,
          fechaHora: claseDateTime,
          aula: horario.aula,
        );
        debugPrint('✅ Notif clase 30min: $nombreMateria - ${horario.aula} - $notif30min');
      }
    } catch (e) {
      debugPrint('❌ Error programando notificación de clase: $e');
    }
  }

  // Cancelar todas y reprogramar con nombres actualizados
  Future<void> reprogramarNotificaciones({
    Map<int, String> materiaNames = const {},
  }) async {
    await _notifications.cancelAllNotifications();
    await scheduleClassNotifications(materiaNames: materiaNames);
    debugPrint('✅ Todas las notificaciones reprogramadas');
  }
}
