// file: lib/widgets/tareas_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/tarea.dart';
import '../models/materia.dart';
import '../providers/tarea_provider.dart';
import '../theme/app_theme.dart';
import '../screens/tarea_detail_screen.dart';

class TareasSection extends StatefulWidget {
  final Materia materia;

  const TareasSection({super.key, required this.materia});

  @override
  State<TareasSection> createState() => _TareasSectionState();
}

class _TareasSectionState extends State<TareasSection> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TareaProvider>().loadTareasByMateria(widget.materia.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TareaProvider>(
      builder: (context, tareaProvider, _) {
        final tareas = tareaProvider.getTareasByMateria(widget.materia.id!);
        final tareasPendientes = tareas.where((t) => !t.completada).length;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.peligro.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: const Border.fromBorderSide(
                      BorderSide(color: AppColors.peligro),
                    ),
                  ),
                  child: const Icon(Icons.task_alt, color: AppColors.peligro),
                ),
                title: const Text(
                  'TAREAS',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  tareasPendientes > 0
                      ? '$tareasPendientes pendiente${tareasPendientes != 1 ? 's' : ''}'
                      : 'Sin tareas pendientes',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: AppColors.moradoPrincipal),
                      onPressed: () => _showTareaDialog(context),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.moradoPrincipal,
                    ),
                  ],
                ),
                onTap: () => setState(() => _isExpanded = !_isExpanded),
              ),
              if (_isExpanded) _buildTareasList(context, tareas, tareaProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTareasList(
      BuildContext context, List<Tarea> tareas, TareaProvider provider) {
    if (tareas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No hay tareas registradas',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    return Column(
      children: tareas.map((tarea) {
        final fechaEntrega = DateTime.parse(tarea.fechaEntrega);
        final diasRestantes = fechaEntrega.difference(DateTime.now()).inDays;
        final esUrgente = diasRestantes <= 2 && !tarea.completada;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: tarea.completada
                ? AppColors.exitoFondo
                : esUrgente
                    ? AppColors.peligroFondo
                    : AppColors.fondoCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: tarea.completada
                  ? AppColors.exito
                  : esUrgente
                      ? AppColors.peligro
                      : provider.getPrioridadColor(tarea.prioridad),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TareaDetailScreen(tarea: tarea),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: tarea.completada,
                      onChanged: (_) => provider.toggleTareaCompletada(tarea),
                      activeColor: AppColors.exito,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tarea.titulo,
                            style: TextStyle(
                              decoration: tarea.completada
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textoOscuro,
                            ),
                          ),
                          if (tarea.descripcion.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              tarea.descripcion,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textoMedio,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: esUrgente
                                    ? AppColors.peligro
                                    : AppColors.textoClaro,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd/MM/yyyy').format(fechaEntrega),
                                style: TextStyle(
                                  color: esUrgente
                                      ? AppColors.peligroTexto
                                      : AppColors.textoClaro,
                                  fontWeight:
                                      esUrgente ? FontWeight.bold : null,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: provider
                                      .getPrioridadColor(tarea.prioridad)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: provider
                                        .getPrioridadColor(tarea.prioridad),
                                  ),
                                ),
                                child: Text(
                                  tarea.prioridad,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: provider
                                        .getPrioridadColor(tarea.prioridad),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          color: AppColors.moradoPrincipal,
                          onPressed: () =>
                              _showTareaDialog(context, tarea: tarea),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(height: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, size: 18),
                          color: AppColors.peligro,
                          onPressed: () =>
                              _confirmDelete(context, tarea, provider),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showTareaDialog(BuildContext context, {Tarea? tarea}) {
    final tituloController = TextEditingController(text: tarea?.titulo ?? '');
    final descripcionController =
        TextEditingController(text: tarea?.descripcion ?? '');
    DateTime fechaEntrega = tarea != null
        ? DateTime.parse(tarea.fechaEntrega)
        : DateTime.now().add(const Duration(days: 1));
    String prioridad = tarea?.prioridad ?? 'Media';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.fondoCard,
          title: Text(tarea == null ? 'NUEVA TAREA' : 'EDITAR TAREA'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descripcionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: fechaEntrega,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.moradoPrincipal,
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() => fechaEntrega = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Entrega',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(fechaEntrega)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: prioridad,
                  decoration: const InputDecoration(
                    labelText: 'Prioridad',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Alta', 'Media', 'Baja'].map((p) {
                    return DropdownMenuItem(value: p, child: Text(p));
                  }).toList(),
                  onChanged: (val) => setState(() => prioridad = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tituloController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El título es obligatorio')),
                  );
                  return;
                }

                final nuevaTarea = Tarea(
                  id: tarea?.id,
                  materiaId: widget.materia.id!,
                  titulo: tituloController.text,
                  descripcion: descripcionController.text,
                  fechaEntrega: DateFormat('yyyy-MM-dd').format(fechaEntrega),
                  completada: tarea?.completada ?? false,
                  prioridad: prioridad,
                );

                final tareaProvider = context.read<TareaProvider>();
                if (tarea == null) {
                  tareaProvider.addTarea(nuevaTarea, widget.materia.nombre);
                } else {
                  tareaProvider.updateTarea(nuevaTarea, widget.materia.nombre);
                }

                Navigator.pop(context);
              },
              child: const Text('GUARDAR'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, Tarea tarea, TareaProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.fondoCard,
        title: const Text('CONFIRMAR'),
        content: Text('¿Eliminar la tarea "${tarea.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              provider.deleteTarea(tarea.id!, widget.materia.id!);
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}
