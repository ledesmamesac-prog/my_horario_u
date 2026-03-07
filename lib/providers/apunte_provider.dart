// file: lib/providers/apunte_provider.dart
import 'package:flutter/material.dart';
import '../models/apunte.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/cloud_service.dart';

class ApunteProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final NotificationService _notifications = NotificationService.instance;
  final CloudService _cloud = CloudService.instance;
  List<Apunte> _apuntes = [];

  List<Apunte> get apuntes => _apuntes;

  ApunteProvider() {
    loadApuntes();
  }

  Future<void> loadApuntes() async {
    _apuntes = await _db.getApuntes();
    notifyListeners();
  }

  Future<void> addApunte(Apunte apunte) async {
    final id = await _db.insertApunte(apunte);
    final apunteConId = apunte.copyWith(id: id);
    await _cloud.saveApunte(apunteConId);

    // NUEVO: Programar notificación si tiene recordatorio
    if (apunte.recordatorioFecha != null) {
      final fecha = DateTime.parse(apunte.recordatorioFecha!);
      if (fecha.isAfter(DateTime.now())) {
        await _notifications.scheduleApunteNotification(
          id: id,
          titulo: apunte.titulo,
          fecha: fecha,
        );
        debugPrint('✅ Notificación programada para apunte ID $id: ${fecha}');
      }
    }

    await loadApuntes();
  }

  Future<void> updateApunte(Apunte apunte) async {
    await _db.updateApunte(apunte);
    await _cloud.saveApunte(apunte);

    // NUEVO: Cancelar notificación anterior
    await _notifications.cancelApunteNotification(apunte.id!);

    // NUEVO: Reagendar si tiene recordatorio
    if (apunte.recordatorioFecha != null) {
      final fecha = DateTime.parse(apunte.recordatorioFecha!);
      if (fecha.isAfter(DateTime.now())) {
        await _notifications.scheduleApunteNotification(
          id: apunte.id!,
          titulo: apunte.titulo,
          fecha: fecha,
        );
        debugPrint('✅ Notificación reprogramada para apunte ID ${apunte.id}: ${fecha}');
      }
    }

    await loadApuntes();
  }

  Future<void> deleteApunte(int id) async {
    // NUEVO: Cancelar notificación al eliminar
    await _notifications.cancelApunteNotification(id);
    await _db.deleteApunte(id);
    await _cloud.deleteApunte(id);
    await loadApuntes();
  }

  List<Apunte> buscar(String query) {
    if (query.isEmpty) return _apuntes;
    final q = query.toLowerCase();
    return _apuntes
        .where((a) =>
    a.titulo.toLowerCase().contains(q) ||
        a.contenido.toLowerCase().contains(q))
        .toList();
  }

  // NUEVO: Método para enviar notificación de prueba
  Future<void> sendTestNotification() async {
    await _notifications.showInstantNotification(
      title: '🔔 Notificación de Prueba',
      body: 'Las notificaciones están funcionando correctamente',
    );
    debugPrint('✅ Notificación de prueba enviada');
  }
}