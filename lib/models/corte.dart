// file: lib/models/corte.dart
class Corte {
  final int? id;
  final int materiaId;
  final String nombre;
  final double porcentaje;
  final int orden;

  Corte({
    this.id,
    required this.materiaId,
    required this.nombre,
    required this.porcentaje,
    required this.orden,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materiaId': materiaId,
      'nombre': nombre,
      'porcentaje': porcentaje,
      'orden': orden,
    };
  }

  factory Corte.fromMap(Map<String, dynamic> map) {
    return Corte(
      id: map['id'],
      materiaId: map['materiaId'],
      nombre: map['nombre'],
      porcentaje: map['porcentaje'],
      orden: map['orden'],
    );
  }

  Corte copyWith({
    int? id,
    int? materiaId,
    String? nombre,
    double? porcentaje,
    int? orden,
  }) {
    return Corte(
      id: id ?? this.id,
      materiaId: materiaId ?? this.materiaId,
      nombre: nombre ?? this.nombre,
      porcentaje: porcentaje ?? this.porcentaje,
      orden: orden ?? this.orden,
    );
  }
}
