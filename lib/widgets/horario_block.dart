// file: lib/widgets/horario_block.dart
import 'package:flutter/material.dart';
import '../models/horario.dart';
import '../models/materia.dart';

class HorarioBlock extends StatelessWidget {
  final Horario horario;
  final Materia materia;

  const HorarioBlock({super.key, required this.horario, required this.materia});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(materia.color).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(materia.color), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            materia.nombre,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${horario.horaInicio} - ${horario.horaFin}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            horario.aula,
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
