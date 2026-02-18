// file: lib/providers/apunte_provider.dart
import 'package:flutter/material.dart';
import '../models/apunte.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class ApunteProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final NotificationService _notifications = NotificationService.instance;
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
    
    if (apunte.recordatorioFecha != null) {
      final fecha = DateTime.parse(apunte.recordatorioFecha!);
      if (fecha.isAfter(DateTime.now())) {
        await _notifications.scheduleApunteNotification(
          id: id,
          titulo: apunte.titulo,
          fecha: fecha,
        );
      }
    }

    await loadApuntes();
  }

  Future<void> updateApunte(Apunte apunte) async {
    await _db.updateApunte(apunte);

    await _notifications.cancelApunteNotification(apunte.id!);

    if (apunte.recordatorioFecha != null) {
      final fecha = DateTime.parse(apunte.recordatorioFecha!);
      if (fecha.isAfter(DateTime.now())) {
        await _notifications.scheduleApunteNotification(
          id: apunte.id!,
          titulo: apunte.titulo,
          fecha: fecha,
        );
      }
    }

    await loadApuntes();
  }

  Future<void> deleteApunte(int id) async {
    await _notifications.cancelApunteNotification(id);
    await _db.deleteApunte(id);
    await loadApuntes();
  }

  // NUEVO: Método para enviar una notificación de prueba
  Future<void> sendTestNotification() async {
    await _notifications.showInstantNotification(
      title: '🔔 Notificación de Prueba',
      body: 'Si ves esto, las notificaciones de la app funcionan.',
    );
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
}
