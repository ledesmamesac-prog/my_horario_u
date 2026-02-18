// file: lib/models/materia.dart
class Materia {
  final int? id;
  final String nombre;
  final String codigo;
  final String profesor;
  final int creditos;
  final int color;

  Materia({
    this.id,
    required this.nombre,
    required this.codigo,
    required this.profesor,
    required this.creditos,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'profesor': profesor,
      'creditos': creditos,
      'color': color,
    };
  }

  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      id: map['id'],
      nombre: map['nombre'],
      codigo: map['codigo'],
      profesor: map['profesor'],
      creditos: map['creditos'],
      color: map['color'],
    );
  }

  Materia copyWith({
    int? id,
    String? nombre,
    String? codigo,
    String? profesor,
    int? creditos,
    int? color,
  }) {
    return Materia(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      profesor: profesor ?? this.profesor,
      creditos: creditos ?? this.creditos,
      color: color ?? this.color,
    );
  }
}
