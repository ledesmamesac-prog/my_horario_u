// file: lib/screens/notas_screen.dart
import 'package:flutter/material.dart';
import 'package:my_horario_u/models/materia.dart';
import 'package:provider/provider.dart';
import '../models/corte.dart';
import '../models/evaluacion.dart';
import '../providers/materia_provider.dart';
import '../providers/corte_provider.dart';
import '../providers/evaluacion_provider.dart';
import '../theme/app_theme.dart';

class NotasScreen extends StatefulWidget {
  const NotasScreen({super.key});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  int? selectedMateriaId;

  @override
  Widget build(BuildContext context) {
    final materiaProvider = context.watch<MateriaProvider>();
    final corteProvider = context.watch<CorteProvider>();
    final evaluacionProvider = context.watch<EvaluacionProvider>();
    final materias = materiaProvider.materias;

    if (materias.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('NOTAS')),
        body: const Center(
          child: Text('No hay materias registradas',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    if (selectedMateriaId == null) {
      selectedMateriaId = materias.first.id;
      Future.microtask(
          () => corteProvider.loadCortesByMateria(selectedMateriaId!));
    }

    final materia = materiaProvider.getMateriaById(selectedMateriaId!);
    final cortes = corteProvider.getCortesByMateria(selectedMateriaId!);

    // Calcular promedio final
    double promedioFinal = 0;
    if (cortes.isNotEmpty) {
      for (var corte in cortes) {
        if (corte.id != null) {
          evaluacionProvider.loadEvaluacionesByCorte(corte.id!);
          final promedioCorte =
              evaluacionProvider.calcularPromedioCorte(corte.id!);
          promedioFinal += promedioCorte * (corte.porcentaje / 100);
        }
      }
    }

    final estado = _getEstado(promedioFinal);
    final colorEstado = _getColorEstado(estado);
    final porcentajesValidos =
        corteProvider.validarPorcentajes(selectedMateriaId!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTAS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _mostrarAyuda(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // HEADER CON SELECTOR Y PROMEDIO
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.fondoCard,
              border: Border(
                bottom: BorderSide(color: AppColors.moradoPrincipal),
              ),
            ),
            child: Column(
              children: [
                DropdownButton<int>(
                  value: selectedMateriaId,
                  isExpanded: true,
                  dropdownColor: AppColors.fondoCard,
                  items: materias.map((m) {
                    return DropdownMenuItem(
                      value: m.id,
                      child: Text(m.nombre),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => selectedMateriaId = val);
                    corteProvider.loadCortesByMateria(val!);
                  },
                ),
                const SizedBox(height: 16),
                if (!porcentajesValidos)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.riesgoClaro,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning,
                            color: AppColors.riesgo, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Los porcentajes de los cortes deben sumar 100%. Falta: ${corteProvider.getPorcentajeDisponible(selectedMateriaId!).toStringAsFixed(1)}%',
                            style: const TextStyle(
                                color: AppColors.riesgo, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PROMEDIO FINAL',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        Text(
                          promedioFinal.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: colorEstado,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorEstado.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorEstado, width: 2),
                      ),
                      child: Text(
                        estado.toUpperCase(),
                        style: TextStyle(
                          color: colorEstado,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // LISTA DE CORTES
          Expanded(
            child: cortes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open,
                            size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay cortes creados',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Presiona + para crear un corte',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cortes.length,
                    itemBuilder: (context, index) {
                      final corte = cortes[index];
                      return _buildCorteCard(
                          context, corte, evaluacionProvider);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCorteDialog(context, materia: materia),
        child: const Icon(Icons.add),
      ),
    );
  }

  // file: lib/screens/notas_screen.dart
// MANTENER TODOS LOS IMPORTS Y CÓDIGO ANTERIOR

// REEMPLAZAR COMPLETAMENTE ESTE MÉTODO:
  Widget _buildCorteCard(BuildContext context, Corte corte,
      EvaluacionProvider evaluacionProvider) {
    evaluacionProvider.loadEvaluacionesByCorte(corte.id!);
    final evaluaciones = evaluacionProvider.getEvaluacionesByCorte(corte.id!);
    final promedioCorte = evaluacionProvider.calcularPromedioCorte(corte.id!);
    final porcentajesValidos = evaluacionProvider.validarPorcentajes(corte.id!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          corte.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${corte.porcentaje}% del semestre'),
            if (!porcentajesValidos)
              Text(
                'Falta ${evaluacionProvider.getPorcentajeDisponible(corte.id!).toStringAsFixed(1)}% en evaluaciones',
                style: const TextStyle(color: AppColors.riesgo, fontSize: 11),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.moradoClaro,
                borderRadius: BorderRadius.circular(8),
                border: const Border.fromBorderSide(
                  BorderSide(color: AppColors.moradoPrincipal, width: 1.5),
                ),
              ),
              child: Text(
                promedioCorte.toStringAsFixed(2),
                style: const TextStyle(
                  color: AppColors.moradoPrincipal, // Ya visible
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.peligro),
              onPressed: () => _confirmDeleteCorte(context, corte),
            ),
          ],
        ),
        children: [
          if (evaluaciones.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sin evaluaciones',
                style: TextStyle(color: Colors.grey[400]),
              ),
            )
          else
            ...evaluaciones.map((eval) => ListTile(
                  title: Text(eval.tipo),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${eval.porcentaje}% del corte'),
                      // MOSTRAR ESTADO
                      if (eval.isPendiente)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.riesgoClaro,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: const Text(
                            'PENDIENTE',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.riesgo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // CORREGIDO: Validación null-safe
                      if (eval.notaObtenida != null)
                        Text(
                          eval.notaObtenida!.toStringAsFixed(
                              1), // AGREGAR ! PARA ASSERT NON-NULL
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.moradoPrincipal,
                          ),
                        )
                      else
                        const Text(
                          '-',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEvaluacionDialog(context,
                            corte: corte, evaluacion: eval),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 20, color: AppColors.peligro),
                        onPressed: () =>
                            _confirmDeleteEvaluacion(context, eval, corte.id!),
                      ),
                    ],
                  ),
                )),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton.icon(
              onPressed: () => _showEvaluacionDialog(context, corte: corte),
              icon: const Icon(Icons.add),
              label: const Text('Agregar Evaluación'),
            ),
          ),
        ],
      ),
    );
  }

// REEMPLAZAR COMPLETAMENTE ESTE MÉTODO:
  void _showEvaluacionDialog(BuildContext context,
      {required Corte corte, Evaluacion? evaluacion}) {
    final tipoController = TextEditingController(text: evaluacion?.tipo ?? '');
    final porcentajeController = TextEditingController(
      text: evaluacion?.porcentaje.toString() ?? '',
    );
    final notaController = TextEditingController(
      text:
          evaluacion?.notaObtenida?.toString() ?? '', // AGREGAR ? PARA NULLABLE
    );

    // NUEVO: Campos para actividad futura
    DateTime? fechaActividad =
        evaluacion?.fecha != null ? DateTime.parse(evaluacion!.fecha!) : null;
    bool esActividadFutura = evaluacion?.isPendiente ?? false;

    final evaluacionProvider = context.read<EvaluacionProvider>();
    final porcentajeDisponible =
        evaluacionProvider.getPorcentajeDisponible(corte.id!);

    final materiaProvider = context.read<MateriaProvider>();
    final materia = materiaProvider.getMateriaById(corte.materiaId);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
              evaluacion == null ? 'NUEVA EVALUACIÓN' : 'EDITAR EVALUACIÓN'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (evaluacion == null && porcentajeDisponible > 0)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.moradoPrincipal.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Porcentaje disponible: ${porcentajeDisponible.toStringAsFixed(1)}%',
                      style: const TextStyle(
                          color: AppColors.moradoPrincipal, fontSize: 12),
                    ),
                  ),

                TextField(
                  controller: tipoController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo (Parcial, Quiz, Tarea, etc.)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: porcentajeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Porcentaje del corte (%)',
                    border: OutlineInputBorder(),
                    helperText: 'Debe sumar 100% en el corte',
                  ),
                ),
                const SizedBox(height: 12),

                // NUEVO: Checkbox para actividad futura
                CheckboxListTile(
                  title: const Text('Es una actividad futura (sin nota aún)'),
                  value: esActividadFutura,
                  onChanged: (value) {
                    setState(() => esActividadFutura = value ?? false);
                  },
                ),

                // NUEVO: Selector de fecha si es actividad futura
                if (esActividadFutura) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: fechaActividad ??
                            DateTime.now().add(const Duration(days: 1)),
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
                        setState(() => fechaActividad = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de la Actividad',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        fechaActividad != null
                            ? '${fechaActividad!.day}/${fechaActividad!.month}/${fechaActividad!.year}'
                            : 'Seleccionar fecha',
                      ),
                    ),
                  ),
                ],

                // Campo de nota (solo si NO es actividad futura)
                if (!esActividadFutura) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: notaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nota Obtenida (0.0 - 5.0)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
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
                // Validaciones
                if (tipoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El tipo es obligatorio')),
                  );
                  return;
                }

                if (esActividadFutura && fechaActividad == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Selecciona la fecha de la actividad')),
                  );
                  return;
                }

                final nuevaEvaluacion = Evaluacion(
                  id: evaluacion?.id,
                  corteId: corte.id!,
                  tipo: tipoController.text,
                  porcentaje: double.tryParse(porcentajeController.text) ?? 0,
                  notaObtenida: esActividadFutura
                      ? null
                      : double.tryParse(notaController.text),
                  fecha: esActividadFutura
                      ? '${fechaActividad!.year}-${fechaActividad!.month.toString().padLeft(2, '0')}-${fechaActividad!.day.toString().padLeft(2, '0')}'
                      : null,
                  estado: esActividadFutura ? 'Pendiente' : 'Calificada',
                );

                if (evaluacion == null) {
                  // CORREGIDO: Agregar segundo parámetro
                  context.read<EvaluacionProvider>().addEvaluacion(
                        nuevaEvaluacion,
                        (materia?.nombre ?? 'Materia')
                            as Materia, // SEGUNDO PARÁMETRO
                      );
                } else {
                  context
                      .read<EvaluacionProvider>()
                      .updateEvaluacion(nuevaEvaluacion, materia as Materia);
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

// MANTENER TODOS LOS DEMÁS MÉTODOS SIN CAMBIOS

  void _showCorteDialog(BuildContext context, {materia, Corte? corte}) {
    final nombreController = TextEditingController(text: corte?.nombre ?? '');
    final porcentajeController = TextEditingController(
      text: corte?.porcentaje.toString() ?? '',
    );

    final corteProvider = context.read<CorteProvider>();
    final porcentajeDisponible =
        corteProvider.getPorcentajeDisponible(selectedMateriaId!);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(corte == null ? 'NUEVO CORTE' : 'EDITAR CORTE'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (corte == null && porcentajeDisponible > 0)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.moradoPrincipal.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Porcentaje disponible: ${porcentajeDisponible.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      color: AppColors.moradoPrincipal, fontSize: 12),
                ),
              ),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre (ej: Corte 1)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: porcentajeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Porcentaje del semestre (%)',
                border: OutlineInputBorder(),
                helperText: 'Total debe sumar 100%',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              final porcentaje =
                  double.tryParse(porcentajeController.text) ?? 0;

              if (porcentaje <= 0 || porcentaje > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Porcentaje inválido')),
                );
                return;
              }

              final nuevoCorte = Corte(
                id: corte?.id,
                materiaId: selectedMateriaId!,
                nombre: nombreController.text,
                porcentaje: porcentaje,
                orden: corte?.orden ??
                    corteProvider
                            .getCortesByMateria(selectedMateriaId!)
                            .length +
                        1,
              );

              if (corte == null) {
                context.read<CorteProvider>().addCorte(nuevoCorte);
              } else {
                context.read<CorteProvider>().updateCorte(nuevoCorte);
              }

              Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCorte(BuildContext context, Corte corte) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CONFIRMAR'),
        content: Text(
            '¿Eliminar ${corte.nombre}? Se eliminarán todas sus evaluaciones.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context
                  .read<CorteProvider>()
                  .deleteCorte(corte.id!, selectedMateriaId!);
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEvaluacion(
      BuildContext context, Evaluacion evaluacion, int corteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CONFIRMAR'),
        content: const Text('¿Eliminar esta evaluación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context
                  .read<EvaluacionProvider>()
                  .deleteEvaluacion(evaluacion.id!, corteId);
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }

  void _mostrarAyuda(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CÓMO FUNCIONA'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Crea cortes (ej: Corte 1, Corte 2, Corte 3)'),
              SizedBox(height: 8),
              Text('2. Asigna porcentaje a cada corte (deben sumar 100%)'),
              SizedBox(height: 8),
              Text('3. Dentro de cada corte, agrega evaluaciones'),
              SizedBox(height: 8),
              Text('4. Las evaluaciones de cada corte deben sumar 100%'),
              SizedBox(height: 8),
              Text('5. El promedio final se calcula automáticamente'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ENTENDIDO'),
          ),
        ],
      ),
    );
  }

  String _getEstado(double promedio) {
    if (promedio >= 3.5) return 'ganando';
    if (promedio >= 3.0) return 'riesgo';
    return 'perdiendo';
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'ganando':
        return Colors.green;
      case 'riesgo':
        return Colors.orange;
      case 'perdiendo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
