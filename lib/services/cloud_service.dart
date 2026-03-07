import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/materia.dart';
import '../models/horario.dart';
import '../models/nota.dart';
import '../models/corte.dart';
import '../models/evaluacion.dart';
import '../models/tarea.dart';
import '../models/apunte.dart';

class CloudService {
  static final CloudService instance = CloudService._init();
  CloudService._init();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // ── MATERIAS ──────────────────────────────────────────────────────────────
  Future<void> saveMateria(Materia materia) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('materias').doc(materia.id.toString()).set(materia.toMap());
  }

  Future<void> deleteMateria(int id) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('materias').doc(id.toString()).delete();
  }

  // ── HORARIOS ──────────────────────────────────────────────────────────────
  Future<void> saveHorario(Horario horario) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('horarios').doc(horario.id.toString()).set(horario.toMap());
  }

  Future<void> deleteHorario(int id) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('horarios').doc(id.toString()).delete();
  }

  // ── TAREAS ────────────────────────────────────────────────────────────────
  Future<void> saveTarea(Tarea tarea) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('tareas').doc(tarea.id.toString()).set(tarea.toMap());
  }

  Future<void> deleteTarea(int id) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('tareas').doc(id.toString()).delete();
  }

  // ── NOTAS ─────────────────────────────────────────────────────────────────
  Future<void> saveNota(Nota nota) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('notas').doc(nota.id.toString()).set(nota.toMap());
  }

  Future<void> deleteNota(int id) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('notas').doc(id.toString()).delete();
  }

  // ── APUNTES ───────────────────────────────────────────────────────────────
  Future<void> saveApunte(Apunte apunte) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('apuntes').doc(apunte.id.toString()).set(apunte.toMap());
  }

  Future<void> deleteApunte(int id) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('apuntes').doc(id.toString()).delete();
  }

  // ── CORTES & EVALUACIONES ──────────────────────────────────────────────────
  Future<void> saveCorte(Corte corte) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('cortes').doc(corte.id.toString()).set(corte.toMap());
  }

  Future<void> deleteCorte(int id) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('cortes').doc(id.toString()).delete();
  }

  Future<void> saveEvaluacion(Evaluacion evaluacion) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('evaluaciones').doc(evaluacion.id.toString()).set(evaluacion.toMap());
  }

  Future<void> deleteEvaluacion(int id) async {
    if (_userId == null) return;
    await _db.collection('users').doc(_userId).collection('evaluaciones').doc(id.toString()).delete();
  }
}
