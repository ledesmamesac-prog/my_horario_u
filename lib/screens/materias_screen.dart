// file: lib/screens/materias_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../models/materia.dart';
import '../providers/materia_provider.dart';
import '../widgets/tareas_section.dart';
import '../theme/app_theme.dart';

class MateriasScreen extends StatelessWidget {
  const MateriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Materias')),
      body: Consumer<MateriaProvider>(
        builder: (context, provider, _) {
          final materias = provider.materias;
          if (materias.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: const BoxDecoration(
                      color: AppColors.moradoClaro,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.book_rounded,
                        size: 56, color: AppColors.moradoPrincipal),
                  ),
                  const SizedBox(height: 24),
                  const Text('Sin materias',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textoOscuro)),
                  const SizedBox(height: 8),
                  const Text('Agrega tu primera materia',
                      style: TextStyle(color: AppColors.textoMedio)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: materias.length,
            itemBuilder: (context, index) {
              final materia = materias[index];
              return Column(
                children: [
                  _MateriaCard(
                    materia: materia,
                    onEdit: () => _showMateriaDialog(context, materia: materia),
                    onDelete: () => _confirmDelete(context, materia),
                  ),
                  TareasSection(materia: materia),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMateriaDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva Materia'),
      ),
    );
  }

  void _showMateriaDialog(BuildContext context, {Materia? materia}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MateriaFormSheet(materia: materia),
    );
  }

  void _confirmDelete(BuildContext context, Materia materia) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar materia'),
        content: Text('¿Eliminar "${materia.nombre}" y todos sus datos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.peligro),
            onPressed: () {
              context.read<MateriaProvider>().deleteMateria(materia.id!);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ─── Card de Materia ──────────────────────────────────────────────────────────

class _MateriaCard extends StatelessWidget {
  final Materia materia;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MateriaCard({
    required this.materia,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.fondoCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borde),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(materia.color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(materia.color), width: 2),
              ),
              child: Center(
                child: Text(
                  materia.nombre.isNotEmpty
                      ? materia.nombre[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Color(materia.color),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(materia.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.textoOscuro)),
                  const SizedBox(height: 2),
                  Text(
                    '${materia.codigo.isNotEmpty ? materia.codigo + ' · ' : ''}${materia.profesor}',
                    style: const TextStyle(
                        color: AppColors.textoMedio, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.moradoClaro,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${materia.creditos} créditos',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.moradoPrincipal),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded,
                      color: AppColors.moradoPrincipal, size: 20),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded,
                      color: AppColors.peligro, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Formulario ───────────────────────────────────────────────────────────────

class _MateriaFormSheet extends StatefulWidget {
  final Materia? materia;
  const _MateriaFormSheet({this.materia});

  @override
  State<_MateriaFormSheet> createState() => _MateriaFormSheetState();
}

class _MateriaFormSheetState extends State<_MateriaFormSheet> {
  late final TextEditingController _nombre;
  late final TextEditingController _codigo;
  late final TextEditingController _profesor;
  late final TextEditingController _creditos;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.materia?.nombre ?? '');
    _codigo = TextEditingController(text: widget.materia?.codigo ?? '');
    _profesor = TextEditingController(text: widget.materia?.profesor ?? '');
    _creditos =
        TextEditingController(text: widget.materia?.creditos.toString() ?? '3');
    _color = widget.materia != null
        ? Color(widget.materia!.color)
        : AppColors.moradoPrincipal;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _codigo.dispose();
    _profesor.dispose();
    _creditos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.fondoCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borde,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.materia == null ? 'Nueva Materia' : 'Editar Materia',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textoOscuro),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: 'Nombre *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codigo,
              decoration: const InputDecoration(labelText: 'Código (opcional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _profesor,
              decoration: const InputDecoration(labelText: 'Profesor'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _creditos,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Créditos'),
            ),
            const SizedBox(height: 16),

            // Selector de color
            const Text('Color de la materia',
                style: TextStyle(
                    color: AppColors.textoMedio,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                AppColors.moradoPrincipal,
                AppColors.acento,
                AppColors.amarillo,
                AppColors.exito,
                AppColors.peligro,
                AppColors.riesgo,
                const Color(0xFFEC4899),
                const Color(0xFF3B82F6),
              ].map((c) {
                final isSelected = _color.value == c.value;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.textoOscuro, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: c.withOpacity(0.4), blurRadius: 8)
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList()
                ..add(
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Seleccionar color'),
                        content: BlockPicker(
                          pickerColor: _color,
                          onColorChanged: (c) {
                            setState(() => _color = c);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.green, Colors.blue],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borde),
                      ),
                      child: const Icon(Icons.palette_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardar,
                child: Text(widget.materia == null
                    ? 'Crear Materia'
                    : 'Guardar Cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _guardar() {
    if (_nombre.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio')),
      );
      return;
    }

    final nuevaMateria = Materia(
      id: widget.materia?.id,
      nombre: _nombre.text,
      codigo: _codigo.text,
      profesor: _profesor.text,
      creditos: int.tryParse(_creditos.text) ?? 3,
      color: _color.value,
    );

    if (widget.materia == null) {
      context.read<MateriaProvider>().addMateria(nuevaMateria);
    } else {
      context.read<MateriaProvider>().updateMateria(nuevaMateria);
    }

    Navigator.pop(context);
  }
}
