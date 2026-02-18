// file: lib/models/nota.dart
class Nota {
  final int? id;
  final int materiaId;
  final String tipo;
  final double porcentaje;
  final double notaObtenida;

  Nota({
    this.id,
    required this.materiaId,
    required this.tipo,
    required this.porcentaje,
    required this.notaObtenida,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materiaId': materiaId,
      'tipo': tipo,
      'porcentaje': porcentaje,
      'notaObtenida': notaObtenida,
    };
  }

  factory Nota.fromMap(Map<String, dynamic> map) {
    return Nota(
      id: map['id'],
      materiaId: map['materiaId'],
      tipo: map['tipo'],
      porcentaje: map['porcentaje'],
      notaObtenida: map['notaObtenida'],
    );
  }
}
