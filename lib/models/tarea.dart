// file: lib/models/tarea.dart
class Tarea {
  final int? id;
  final int materiaId;
  final String titulo;
  final String descripcion;
  final String fechaEntrega; // Formato: yyyy-MM-dd
  final bool completada;
  final String prioridad; // Alta, Media, Baja

  Tarea({
    this.id,
    required this.materiaId,
    required this.titulo,
    required this.descripcion,
    required this.fechaEntrega,
    this.completada = false,
    required this.prioridad,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materiaId': materiaId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaEntrega': fechaEntrega,
      'completada': completada ? 1 : 0,
      'prioridad': prioridad,
    };
  }

  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['id'],
      materiaId: map['materiaId'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      fechaEntrega: map['fechaEntrega'],
      completada: map['completada'] == 1,
      prioridad: map['prioridad'],
    );
  }

  Tarea copyWith({
    int? id,
    int? materiaId,
    String? titulo,
    String? descripcion,
    String? fechaEntrega,
    bool? completada,
    String? prioridad,
  }) {
    return Tarea(
      id: id ?? this.id,
      materiaId: materiaId ?? this.materiaId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
      completada: completada ?? this.completada,
      prioridad: prioridad ?? this.prioridad,
    );
  }
}
