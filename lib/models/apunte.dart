// file: lib/models/apunte.dart
class Apunte {
  final int? id;
  final String titulo;
  final String contenido;
  final String fechaCreacion;
  final List<String> imagenesPaths; // CAMBIADO: ahora es lista
  final String? recordatorioFecha;

  Apunte({
    this.id,
    required this.titulo,
    required this.contenido,
    required this.fechaCreacion,
    List<String>? imagenesPaths, // CAMBIADO
    this.recordatorioFecha,
  }) : imagenesPaths = imagenesPaths ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'contenido': contenido,
      'fechaCreacion': fechaCreacion,
      'imagenesPaths': imagenesPaths.join('|||'), // NUEVO: separador
      'recordatorioFecha': recordatorioFecha,
    };
  }

  factory Apunte.fromMap(Map<String, dynamic> map) {
    final imagenesStr = map['imagenesPaths'] as String?;
    final imagenes = imagenesStr != null && imagenesStr.isNotEmpty
        ? imagenesStr.split('|||')
        : <String>[];

    return Apunte(
      id: map['id'],
      titulo: map['titulo'],
      contenido: map['contenido'],
      fechaCreacion: map['fechaCreacion'],
      imagenesPaths: imagenes,
      recordatorioFecha: map['recordatorioFecha'],
    );
  }

  Apunte copyWith({
    int? id,
    String? titulo,
    String? contenido,
    String? fechaCreacion,
    List<String>? imagenesPaths,
    String? recordatorioFecha,
  }) {
    return Apunte(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      contenido: contenido ?? this.contenido,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      imagenesPaths: imagenesPaths ?? this.imagenesPaths,
      recordatorioFecha: recordatorioFecha ?? this.recordatorioFecha,
    );
  }

  bool get tieneRecordatorio => recordatorioFecha != null;
  bool get tieneImagenes => imagenesPaths.isNotEmpty;
}
