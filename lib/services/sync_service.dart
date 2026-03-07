import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import '../models/materia.dart';
import '../models/horario.dart';
import '../models/tarea.dart';
import '../models/nota.dart';
import '../models/apunte.dart';
import '../models/corte.dart';
import '../models/evaluacion.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  SyncService._init();

  final DatabaseService _localDb = DatabaseService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> syncFromCloud() async {
    if (_userId == null) return;

    final userDoc = _firestore.collection('users').doc(_userId);

    // 1. Sincronizar Materias
    final materiasSnap = await userDoc.collection('materias').get();
    for (var doc in materiasSnap.docs) {
      final materia = Materia.fromMap(doc.data());
      await _localDb.insertMateria(materia);
    }

    // 2. Sincronizar Horarios
    final horariosSnap = await userDoc.collection('horarios').get();
    for (var doc in horariosSnap.docs) {
      final horario = Horario.fromMap(doc.data());
      await _localDb.insertHorario(horario);
    }

    // 3. Sincronizar Tareas
    final tareasSnap = await userDoc.collection('tareas').get();
    for (var doc in tareasSnap.docs) {
      final tarea = Tarea.fromMap(doc.data());
      await _localDb.insertTarea(tarea);
    }

    // 4. Sincronizar Notas
    final notasSnap = await userDoc.collection('notas').get();
    for (var doc in notasSnap.docs) {
      final nota = Nota.fromMap(doc.data());
      await _localDb.insertNota(nota);
    }

    // 5. Sincronizar Apuntes
    final apuntesSnap = await userDoc.collection('apuntes').get();
    for (var doc in apuntesSnap.docs) {
      final apunte = Apunte.fromMap(doc.data());
      await _localDb.insertApunte(apunte);
    }

    // 6. Sincronizar Cortes
    final cortesSnap = await userDoc.collection('cortes').get();
    for (var doc in cortesSnap.docs) {
      final corte = Corte.fromMap(doc.data());
      await _localDb.insertCorte(corte);
    }

    // 7. Sincronizar Evaluaciones
    final evaluacionesSnap = await userDoc.collection('evaluaciones').get();
    for (var doc in evaluacionesSnap.docs) {
      final evaluacion = Evaluacion.fromMap(doc.data());
      await _localDb.insertEvaluacion(evaluacion);
    }
  }

  Future<void> pushAllToCloud() async {
    if (_userId == null) return;

    final userDoc = _firestore.collection('users').doc(_userId);

    // 1. Materias
    final materias = await _localDb.getMaterias();
    for (var m in materias) {
      await userDoc.collection('materias').doc(m.id.toString()).set(m.toMap());
    }

    // 2. Horarios
    final horarios = await _localDb.getHorarios();
    for (var h in horarios) {
      await userDoc.collection('horarios').doc(h.id.toString()).set(h.toMap());
    }

    // 3. Tareas
    final tareas = await _localDb.getAllTareas();
    for (var t in tareas) {
      await userDoc.collection('tareas').doc(t.id.toString()).set(t.toMap());
    }

    // 4. Apuntes
    final apuntes = await _localDb.getApuntes();
    for (var a in apuntes) {
      await userDoc.collection('apuntes').doc(a.id.toString()).set(a.toMap());
    }

    // 5. Cortes y sus hijos
    for (var m in materias) {
      final cortes = await _localDb.getCortesByMateria(m.id!);
      for (var c in cortes) {
        await userDoc.collection('cortes').doc(c.id.toString()).set(c.toMap());
        
        final evals = await _localDb.getEvaluacionesByCorte(c.id!);
        for (var e in evals) {
          await userDoc.collection('evaluaciones').doc(e.id.toString()).set(e.toMap());
        }
      }
      
      final notas = await _localDb.getNotasByMateria(m.id!);
      for (var n in notas) {
        await userDoc.collection('notas').doc(n.id.toString()).set(n.toMap());
      }
    }
  }
}
