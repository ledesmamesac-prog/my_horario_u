// file: lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    // Inicializar zonas horarias
    tz.initializeTimeZones();
    final locationName = 'America/Bogota';
    tz.setLocalLocation(tz.getLocation(locationName));
    debugPrint('✅ Timezone inicializada: $locationName');

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
        debugPrint('🔔 Notificación tocada: ${details.payload}');
      },
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      // Permiso básico de notificaciones (Android 13+)
      final granted = await android.requestNotificationsPermission();
      debugPrint('📱 Notificaciones: ${granted == true ? "✅" : "❌"}');

      // Permiso de alarmas exactas (Android 12+)
      // USE_EXACT_ALARM y SCHEDULE_EXACT_ALARM están en el manifest
      // pero en Android 12 se debe verificar en runtime
      final alarmStatus = await Permission.scheduleExactAlarm.status;
      debugPrint('⏰ Estado alarmas exactas: $alarmStatus');

      if (alarmStatus.isDenied) {
        final result = await Permission.scheduleExactAlarm.request();
        debugPrint('⏰ Alarmas exactas tras solicitud: ${result.isGranted ? "✅" : "❌"}');
        if (result.isDenied || result.isPermanentlyDenied) {
          debugPrint('⚠️ Sin permiso de alarmas exactas. Las notificaciones pueden llegar tarde.');
        }
      } else if (alarmStatus.isGranted) {
        debugPrint('⏰ Alarmas exactas: ✅ Ya concedidas');
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NOTIFICACIONES DE APUNTES
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> scheduleApunteNotification({
    required int id,
    required String titulo,
    required DateTime fecha,
  }) async {
    if (fecha.isBefore(DateTime.now())) {
      debugPrint('⚠️ Notificación de apunte en el pasado, ignorando');
      return;
    }

    try {
      final tzFecha = tz.TZDateTime.from(fecha, tz.local);

      await _notifications.zonedSchedule(
        id,
        '📝 Recordatorio de Apunte',
        titulo,
        tzFecha,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'apuntes_channel',
            'Recordatorios de Apuntes',
            channelDescription: 'Recordatorios de notas académicas',
            importance: Importance.max,
            priority: Priority.high,
            color: AppColors.moradoPrincipal,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
      );

      debugPrint('✅ Notificación apunte programada: ID=$id, $tzFecha');
    } catch (e) {
      debugPrint('❌ Error programando notificación de apunte: $e');
    }
  }

  Future<void> cancelApunteNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('🔕 Notificación de apunte cancelada: $id');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NOTIFICACIONES DE CLASES
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> scheduleClaseNotification({
    required int id,
    required String materiaNombre,
    required DateTime fechaHora,
    required String aula,
  }) async {
    final scheduledTime = fechaHora.subtract(const Duration(minutes: 30));

    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint('⚠️ Notificación de clase en el pasado, ignorando');
      return;
    }

    try {
      final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

      await _notifications.zonedSchedule(
        id,
        '📚 Próxima Clase en 30 minutos',
        '$materiaNombre en $aula',
        tzScheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'clases_channel',
            'Notificaciones de Clases',
            channelDescription: 'Recordatorios de clases próximas',
            importance: Importance.max,
            priority: Priority.high,
            color: AppColors.acento,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
      );

      debugPrint('✅ Notificación clase programada: ID=$id, $tzScheduled');
    } catch (e) {
      debugPrint('❌ Error programando notificación de clase: $e');
    }
  }

  Future<void> cancelClaseNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('🔕 Notificación de clase cancelada: $id');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NOTIFICACIONES DE TAREAS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> scheduleTareaNotification({
    required int id,
    required String titulo,
    required String materiaNombre,
    required DateTime fechaEntrega,
  }) async {
    final scheduledTime = DateTime(
      fechaEntrega.year,
      fechaEntrega.month,
      fechaEntrega.day,
      8,
      0,
    );

    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint('⚠️ Notificación de tarea en el pasado, ignorando');
      return;
    }

    try {
      final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

      await _notifications.zonedSchedule(
        id + 10000,
        '✅ Tarea para Hoy',
        '$titulo ($materiaNombre)',
        tzScheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tareas_channel',
            'Notificaciones de Tareas',
            channelDescription: 'Recordatorios de tareas pendientes',
            importance: Importance.max,
            priority: Priority.high,
            color: AppColors.exito,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
      );

      debugPrint('✅ Notificación tarea programada: ID=${id + 10000}, $tzScheduled');
    } catch (e) {
      debugPrint('❌ Error programando notificación de tarea: $e');
    }
  }

  Future<void> cancelTareaNotification(int id) async {
    await _notifications.cancel(id + 10000);
    debugPrint('🔕 Notificación de tarea cancelada: ${id + 10000}');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NOTIFICACIONES DE ACTIVIDADES/EVALUACIONES
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> scheduleActividadNotification({
    required int id,
    required String nombreActividad,
    required String materiaNombre,
    required DateTime fecha,
  }) async {
    final scheduledTime = fecha.subtract(const Duration(days: 1));

    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint('⚠️ Notificación de actividad en el pasado, ignorando');
      return;
    }

    try {
      final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

      await _notifications.zonedSchedule(
        id + 20000,
        '📝 Actividad Mañana',
        '$nombreActividad ($materiaNombre)',
        tzScheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'actividades_channel',
            'Notificaciones de Actividades',
            channelDescription: 'Recordatorios de actividades académicas',
            importance: Importance.max,
            priority: Priority.high,
            color: AppColors.riesgo,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
      );

      debugPrint('✅ Notificación actividad programada: ID=${id + 20000}, $tzScheduled');
    } catch (e) {
      debugPrint('❌ Error programando notificación de actividad: $e');
    }
  }

  Future<void> cancelActividadNotification(int id) async {
    await _notifications.cancel(id + 20000);
    debugPrint('🔕 Notificación de actividad cancelada: ${id + 20000}');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NOTIFICACIONES INSTANTÁNEAS Y UTILIDADES
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    try {
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
            color: AppColors.moradoPrincipal,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentSound: true,
            presentBadge: true,
            presentAlert: true,
          ),
        ),
      );
      debugPrint('✅ Notificación instantánea enviada');
    } catch (e) {
      debugPrint('❌ Error enviando notificación instantánea: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('🔕 Notificación cancelada: $id');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('🔕 Todas las notificaciones canceladas');
  }

  Future<void> checkPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    debugPrint('📋 Notificaciones pendientes: ${pending.length}');
    for (var notif in pending) {
      debugPrint('  - ID: ${notif.id}, Título: ${notif.title}');
    }
  }
}