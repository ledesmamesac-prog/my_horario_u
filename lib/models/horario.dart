// file: lib/models/horario.dart
class Horario {
  final int? id;
  final int materiaId;
  final int diaSemana;
  final String horaInicio;
  final String horaFin;
  final String aula;
  final String modalidad;

  Horario({
    this.id,
    required this.materiaId,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.aula,
    required this.modalidad,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materiaId': materiaId,
      'diaSemana': diaSemana,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'aula': aula,
      'modalidad': modalidad,
    };
  }

  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      id: map['id'],
      materiaId: map['materiaId'],
      diaSemana: map['diaSemana'],
      horaInicio: map['horaInicio'],
      horaFin: map['horaFin'],
      aula: map['aula'],
      modalidad: map['modalidad'],
    );
  }
}
