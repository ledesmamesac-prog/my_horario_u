// file: lib/models/evaluacion.dart
class Evaluacion {
  final int? id;
  final int corteId;
  final String tipo;
  final double porcentaje;
  final double? notaObtenida; // AHORA NULLABLE
  final String? fecha; // NUEVO: Fecha de la actividad (yyyy-MM-dd)
  final String estado; // NUEVO: Pendiente o Calificada

  Evaluacion({
    this.id,
    required this.corteId,
    required this.tipo,
    required this.porcentaje,
    this.notaObtenida,
    this.fecha,
    this.estado = 'Pendiente',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'corteId': corteId,
      'tipo': tipo,
      'porcentaje': porcentaje,
      'notaObtenida': notaObtenida,
      'fecha': fecha,
      'estado': estado,
    };
  }

  factory Evaluacion.fromMap(Map<String, dynamic> map) {
    return Evaluacion(
      id: map['id'],
      corteId: map['corteId'],
      tipo: map['tipo'],
      porcentaje: map['porcentaje'],
      notaObtenida: map['notaObtenida'],
      fecha: map['fecha'],
      estado: map['estado'] ?? 'Pendiente',
    );
  }

  Evaluacion copyWith({
    int? id,
    int? corteId,
    String? tipo,
    double? porcentaje,
    double? notaObtenida,
    String? fecha,
    String? estado,
  }) {
    return Evaluacion(
      id: id ?? this.id,
      corteId: corteId ?? this.corteId,
      tipo: tipo ?? this.tipo,
      porcentaje: porcentaje ?? this.porcentaje,
      notaObtenida: notaObtenida ?? this.notaObtenida,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
    );
  }

  bool get isPendiente => estado == 'Pendiente';
  bool get isCalificada => estado == 'Calificada';
}
