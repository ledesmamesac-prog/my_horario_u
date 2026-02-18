// file: lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/materia.dart';
import '../models/horario.dart';
import '../models/nota.dart';
import '../models/corte.dart';
import '../models/evaluacion.dart';
import '../models/tarea.dart';
import '../models/apunte.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('horario_u_v2.db'); // NOMBRE NUEVO = BD LIMPIA
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE materias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        codigo TEXT NOT NULL,
        profesor TEXT NOT NULL,
        creditos INTEGER NOT NULL,
        color INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE horarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        materiaId INTEGER NOT NULL,
        diaSemana INTEGER NOT NULL,
        horaInicio TEXT NOT NULL,
        horaFin TEXT NOT NULL,
        aula TEXT NOT NULL,
        modalidad TEXT NOT NULL,
        FOREIGN KEY (materiaId) REFERENCES materias (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE notas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        materiaId INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        porcentaje REAL NOT NULL,
        notaObtenida REAL NOT NULL,
        FOREIGN KEY (materiaId) REFERENCES materias (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE cortes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        materiaId INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        porcentaje REAL NOT NULL,
        orden INTEGER NOT NULL,
        FOREIGN KEY (materiaId) REFERENCES materias (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE evaluaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        corteId INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        porcentaje REAL NOT NULL,
        notaObtenida REAL,
        fecha TEXT,
        estado TEXT DEFAULT 'Pendiente',
        FOREIGN KEY (corteId) REFERENCES cortes (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tareas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        materiaId INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        fechaEntrega TEXT NOT NULL,
        completada INTEGER NOT NULL DEFAULT 0,
        prioridad TEXT NOT NULL,
        FOREIGN KEY (materiaId) REFERENCES materias (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE apuntes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        contenido TEXT NOT NULL,
        fechaCreacion TEXT NOT NULL,
        imagenesPaths TEXT,
        recordatorioFecha TEXT
      )
  ''');
  }

  // ── MATERIAS ──────────────────────────────────────────────────────────────
  Future<int> insertMateria(Materia materia) async {
    final db = await database;
    return await db.insert('materias', materia.toMap());
  }

  Future<List<Materia>> getMaterias() async {
    final db = await database;
    final result = await db.query('materias');
    return result.map((map) => Materia.fromMap(map)).toList();
  }

  Future<int> updateMateria(Materia materia) async {
    final db = await database;
    return await db.update('materias', materia.toMap(),
        where: 'id = ?', whereArgs: [materia.id]);
  }

  Future<int> deleteMateria(int id) async {
    final db = await database;
    return await db.delete('materias', where: 'id = ?', whereArgs: [id]);
  }

  // ── HORARIOS ──────────────────────────────────────────────────────────────
  Future<int> insertHorario(Horario horario) async {
    final db = await database;
    return await db.insert('horarios', horario.toMap());
  }

  Future<List<Horario>> getHorarios() async {
    final db = await database;
    final result = await db.query('horarios');
    return result.map((map) => Horario.fromMap(map)).toList();
  }

  Future<int> deleteHorario(int id) async {
    final db = await database;
    return await db.delete('horarios', where: 'id = ?', whereArgs: [id]);
  }

  // ── NOTAS ─────────────────────────────────────────────────────────────────
  Future<int> insertNota(Nota nota) async {
    final db = await database;
    return await db.insert('notas', nota.toMap());
  }

  Future<List<Nota>> getNotasByMateria(int materiaId) async {
    final db = await database;
    final result =
        await db.query('notas', where: 'materiaId = ?', whereArgs: [materiaId]);
    return result.map((map) => Nota.fromMap(map)).toList();
  }

  Future<int> deleteNota(int id) async {
    final db = await database;
    return await db.delete('notas', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateNota(Nota nota) async {
    final db = await database;
    return await db
        .update('notas', nota.toMap(), where: 'id = ?', whereArgs: [nota.id]);
  }

  // ── CORTES ────────────────────────────────────────────────────────────────
  Future<int> insertCorte(Corte corte) async {
    final db = await database;
    return await db.insert('cortes', corte.toMap());
  }

  Future<List<Corte>> getCortesByMateria(int materiaId) async {
    final db = await database;
    final result = await db.query('cortes',
        where: 'materiaId = ?', whereArgs: [materiaId], orderBy: 'orden ASC');
    return result.map((map) => Corte.fromMap(map)).toList();
  }

  Future<int> updateCorte(Corte corte) async {
    final db = await database;
    return await db.update('cortes', corte.toMap(),
        where: 'id = ?', whereArgs: [corte.id]);
  }

  Future<int> deleteCorte(int id) async {
    final db = await database;
    return await db.delete('cortes', where: 'id = ?', whereArgs: [id]);
  }

  // ── EVALUACIONES ──────────────────────────────────────────────────────────
  Future<int> insertEvaluacion(Evaluacion evaluacion) async {
    final db = await database;
    return await db.insert('evaluaciones', evaluacion.toMap());
  }

  Future<List<Evaluacion>> getEvaluacionesByCorte(int corteId) async {
    final db = await database;
    final result = await db
        .query('evaluaciones', where: 'corteId = ?', whereArgs: [corteId]);
    return result.map((map) => Evaluacion.fromMap(map)).toList();
  }

  Future<int> updateEvaluacion(Evaluacion evaluacion) async {
    final db = await database;
    return await db.update('evaluaciones', evaluacion.toMap(),
        where: 'id = ?', whereArgs: [evaluacion.id]);
  }

  Future<int> deleteEvaluacion(int id) async {
    final db = await database;
    return await db.delete('evaluaciones', where: 'id = ?', whereArgs: [id]);
  }

  // ── TAREAS ────────────────────────────────────────────────────────────────
  Future<int> insertTarea(Tarea tarea) async {
    final db = await database;
    return await db.insert('tareas', tarea.toMap());
  }

  Future<List<Tarea>> getTareasByMateria(int materiaId) async {
    final db = await database;
    final result = await db.query('tareas',
        where: 'materiaId = ?',
        whereArgs: [materiaId],
        orderBy: 'fechaEntrega ASC');
    return result.map((map) => Tarea.fromMap(map)).toList();
  }

  Future<int> updateTarea(Tarea tarea) async {
    final db = await database;
    return await db.update('tareas', tarea.toMap(),
        where: 'id = ?', whereArgs: [tarea.id]);
  }

  Future<int> deleteTarea(int id) async {
    final db = await database;
    return await db.delete('tareas', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Tarea>> getAllTareas() async {
    final db = await database;
    final result = await db.query('tareas', orderBy: 'fechaEntrega ASC');
    return result.map((map) => Tarea.fromMap(map)).toList();
  }

  // ── APUNTES ───────────────────────────────────────────────────────────────
  Future<int> insertApunte(Apunte apunte) async {
    final db = await database;
    return await db.insert('apuntes', apunte.toMap());
  }

  Future<List<Apunte>> getApuntes() async {
    final db = await database;
    final result = await db.query('apuntes', orderBy: 'fechaCreacion DESC');
    return result.map((map) => Apunte.fromMap(map)).toList();
  }

  Future<int> updateApunte(Apunte apunte) async {
    final db = await database;
    return await db.update('apuntes', apunte.toMap(),
        where: 'id = ?', whereArgs: [apunte.id]);
  }

  Future<int> deleteApunte(int id) async {
    final db = await database;
    return await db.delete('apuntes', where: 'id = ?', whereArgs: [id]);
  }
}
