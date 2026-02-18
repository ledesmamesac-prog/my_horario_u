// file: lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../theme/app_theme.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Manejar tap en notificación
      },
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }

  // ... (El resto de los métodos se mantienen igual)

  Future<void> scheduleApunteNotification({
    required int id,
    required String titulo,
    required DateTime fecha,
  }) async {
    if (fecha.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id,
      '📌 Recordatorio de Apunte',
      titulo,
      tz.TZDateTime.from(fecha, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'apuntes_channel',
          'Recordatorios de Apuntes',
          channelDescription: 'Recordatorios de notas académicas',
          importance: Importance.max,
          priority: Priority.high,
          color: AppColors.acento,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

    Future<void> scheduleTareaNotification({
    required int id,
    required String titulo,
    required String materiaNombre,
    required DateTime fechaEntrega,
  }) async {
    final scheduledTime = DateTime(fechaEntrega.year, fechaEntrega.month, fechaEntrega.day, 8, 0);
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id + 10000,
      '✅ Tarea para Hoy',
      '$titulo ($materiaNombre)',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tareas_channel',
          'Notificaciones de Tareas',
          channelDescription: 'Recordatorios de tareas pendientes',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleActividadNotification({
    required int id,
    required String nombreActividad,
    required String materiaNombre,
    required DateTime fecha,
  }) async {
    final scheduledTime = fecha.subtract(const Duration(days: 1));
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id + 20000,
      '📝 Actividad Mañana',
      '$nombreActividad ($materiaNombre)',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'actividades_channel',
          'Notificaciones de Actividades',
          channelDescription: 'Recordatorios de actividades académicas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleClaseNotification({
    required int id,
    required String materiaNombre,
    required DateTime fechaHora,
    required String aula,
  }) async {
    final scheduledTime = fechaHora.subtract(const Duration(minutes: 30));
    if (scheduledTime.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      id + 30000,
      '📚 Próxima Clase',
      '$materiaNombre en $aula en 30 minutos',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'clases_channel',
          'Notificaciones de Clases',
          channelDescription: 'Recordatorios de clases próximas',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Notificaciones de Prueba',
          channelDescription: 'Canal para notificaciones de prueba',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentSound: true, presentBadge: true, presentAlert: true),
      ),
    );
  }

  Future<void> cancelApunteNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelTareaNotification(int id) async {
    await _notifications.cancel(id + 10000);
  }

  Future<void> cancelActividadNotification(int id) async {
    await _notifications.cancel(id + 20000);
  }

  Future<void> cancelClaseNotification(int id) async {
    await _notifications.cancel(id + 30000);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
