// file: lib/screens/tarea_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/tarea.dart';
import '../models/materia.dart';
import '../providers/tarea_provider.dart';
import '../providers/materia_provider.dart';
import '../theme/app_theme.dart';

class TareaDetailScreen extends StatelessWidget {
  final Tarea tarea;

  const TareaDetailScreen({super.key, required this.tarea});

  @override
  Widget build(BuildContext context) {
    final materiaProvider = context.watch<MateriaProvider>();
    final tareaProvider = context.watch<TareaProvider>();
    final materia = materiaProvider.getMateriaById(tarea.materiaId);

    if (materia == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tarea')),
        body: const Center(child: Text('Materia no encontrada')),
      );
    }

    final fechaEntrega = DateTime.parse(tarea.fechaEntrega);
    final diasRestantes = fechaEntrega.difference(DateTime.now()).inDays;
    final esUrgente = diasRestantes <= 2 && !tarea.completada;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Tarea'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _editarTarea(context, tarea, materia),
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: AppColors.peligro),
            onPressed: () => _confirmarEliminar(context, tarea, tareaProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              tarea.titulo,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textoOscuro,
                decoration:
                    tarea.completada ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 20),

            // Materia
            _buildInfoCard(
              icon: Icons.book_rounded,
              iconColor: Color(materia.color),
              title: 'Materia',
              content: materia.nombre,
            ),
            const SizedBox(height: 12),

            // Fecha de entrega
            _buildInfoCard(
              icon: Icons.calendar_today_rounded,
              iconColor: esUrgente ? AppColors.peligro : AppColors.acento,
              title: 'Fecha de entrega',
              content:
                  DateFormat('EEEE, d MMMM yyyy', 'es').format(fechaEntrega),
              badge: esUrgente
                  ? Text(
                      diasRestantes == 0
                          ? 'HOY'
                          : '$diasRestantes día${diasRestantes != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: AppColors.peligroTexto,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),

            // Prioridad
            _buildInfoCard(
              icon: Icons.flag_rounded,
              iconColor: tareaProvider.getPrioridadColor(tarea.prioridad),
              title: 'Prioridad',
              content: tarea.prioridad,
            ),

            if (tarea.descripcion.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'DESCRIPCIÓN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textoMedio,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.fondoSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borde),
                ),
                child: Text(
                  tarea.descripcion,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.textoOscuro,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Botón completar/descompletar
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  tareaProvider.toggleTareaCompletada(tarea);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      tarea.completada ? AppColors.textoMedio : AppColors.exito,
                ),
                icon: Icon(
                  tarea.completada
                      ? Icons.replay_rounded
                      : Icons.check_circle_rounded,
                ),
                label: Text(
                  tarea.completada
                      ? 'Marcar como pendiente'
                      : 'Marcar como completada',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    Widget? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fondoCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borde),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textoClaro,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoOscuro,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.peligroFondo,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.peligro),
              ),
              child: badge,
            ),
          ],
        ],
      ),
    );
  }

  void _editarTarea(BuildContext context, Tarea tarea, Materia materia) {
    // Reutilizar el dialog de widgets/tareas_section.dart
    Navigator.pop(context); // Cerrar detalle
    // Abrir editor (implementar llamada al dialog)
  }

  void _confirmarEliminar(
      BuildContext context, Tarea tarea, TareaProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Eliminar "${tarea.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.peligro),
            onPressed: () {
              provider.deleteTarea(tarea.id!, tarea.materiaId);
              Navigator.pop(context); // Cerrar dialog
              Navigator.pop(context); // Cerrar detalle
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
