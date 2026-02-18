// file: lib/screens/apunte_editor_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/apunte.dart';
import '../providers/apunte_provider.dart';
import '../theme/app_theme.dart';

class ApunteEditorScreen extends StatefulWidget {
  final Apunte? apunte;

  const ApunteEditorScreen({super.key, this.apunte});

  @override
  State<ApunteEditorScreen> createState() => _ApunteEditorScreenState();
}

class _ApunteEditorScreenState extends State<ApunteEditorScreen> {
  late final TextEditingController _titulo;
  late final TextEditingController _contenido;
  late List<String> _imagenesPaths;
  DateTime? _recordatorio;
  final _picker = ImagePicker();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _titulo = TextEditingController(text: widget.apunte?.titulo ?? '');
    _contenido = TextEditingController(text: widget.apunte?.contenido ?? '');
    _imagenesPaths = List.from(widget.apunte?.imagenesPaths ?? []);
    if (widget.apunte?.recordatorioFecha != null) {
      _recordatorio = DateTime.parse(widget.apunte!.recordatorioFecha!);
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _contenido.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_titulo.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final apunte = Apunte(
        id: widget.apunte?.id,
        titulo: _titulo.text,
        contenido: _contenido.text,
        fechaCreacion: widget.apunte?.fechaCreacion ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        imagenesPaths: _imagenesPaths,
        recordatorioFecha: _recordatorio?.toIso8601String(),
      );

      final provider = context.read<ApunteProvider>();

      if (widget.apunte == null) {
        await provider.addApunte(apunte);
      } else {
        await provider.updateApunte(apunte);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Future<void> _pickImagenes(ImageSource source) async {
    if (source == ImageSource.camera) {
      final picked = await _picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        setState(() => _imagenesPaths.add(picked.path));
      }
    } else {
      final picked = await _picker.pickMultiImage(imageQuality: 70);
      if (picked.isNotEmpty) {
        setState(() {
          _imagenesPaths.addAll(picked.map((e) => e.path));
        });
      }
    }
  }

  void _eliminarImagen(int index) {
    setState(() => _imagenesPaths.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.apunte == null ? 'Nuevo Apunte' : 'Editar Apunte'),
        actions: [
          if (_guardando)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: _guardar,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            TextField(
              controller: _titulo,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                hintText: 'Título del apunte',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 16),

            // Contenido
            TextField(
              controller: _contenido,
              maxLines: null,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
              decoration: const InputDecoration(
                hintText: 'Escribe tu apunte aquí...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),

            const SizedBox(height: 24),

            // Galería de imágenes
            if (_imagenesPaths.isNotEmpty) ...[
              const Text(
                'IMÁGENES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textoMedio,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildImagenesGrid(),
              const SizedBox(height: 24),
            ],

            // Botones de imagen
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImagenes(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Cámara'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImagenes(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Galería'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Recordatorio
            InkWell(
              onTap: _seleccionarRecordatorio,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _recordatorio != null
                      ? AppColors.amarilloClaro
                      : AppColors.fondoSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _recordatorio != null
                        ? AppColors.riesgo
                        : AppColors.borde,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_rounded,
                      color: _recordatorio != null
                          ? AppColors.riesgo
                          : AppColors.textoClaro,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _recordatorio != null
                            ? 'Recordatorio: ${DateFormat('dd/MM/yyyy HH:mm').format(_recordatorio!)}'
                            : 'Agregar recordatorio',
                        style: TextStyle(
                          color: _recordatorio != null
                              ? AppColors.riesgoTexto
                              : AppColors.textoClaro,
                          fontWeight: _recordatorio != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (_recordatorio != null)
                      GestureDetector(
                        onTap: () => setState(() => _recordatorio = null),
                        child: const Icon(Icons.close,
                            size: 18, color: AppColors.peligro),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildImagenesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _imagenesPaths.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_imagenesPaths[index]),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _eliminarImagen(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.peligro,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _seleccionarRecordatorio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha == null) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora == null) return;

    setState(() {
      _recordatorio = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora.hour,
        hora.minute,
      );
    });
  }
}
