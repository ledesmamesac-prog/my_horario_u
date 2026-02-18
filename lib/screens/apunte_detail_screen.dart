// file: lib/screens/apunte_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/apunte.dart';
import '../providers/apunte_provider.dart';
import '../theme/app_theme.dart';
import 'apunte_editor_screen.dart';

class ApunteDetailScreen extends StatelessWidget {
  final Apunte apunte;

  const ApunteDetailScreen({super.key, required this.apunte});

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('d MMMM yyyy', 'es').format(
      DateTime.parse(apunte.fechaCreacion),
    );

    return Scaffold(
      backgroundColor: AppColors.fondoPrincipal,
      appBar: AppBar(
        title: const Text('Apunte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _editarApunte(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: AppColors.peligro),
            onPressed: () => _confirmarEliminar(context),
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
              apunte.titulo,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.textoOscuro,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // Fecha y recordatorio
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.fondoSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borde),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 14, color: AppColors.textoClaro),
                      const SizedBox(width: 6),
                      Text(fecha,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textoMedio)),
                    ],
                  ),
                ),
                if (apunte.tieneRecordatorio) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.amarilloClaro,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.riesgo),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.notifications_active_rounded,
                            size: 14, color: AppColors.riesgo),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd/MM HH:mm').format(
                            DateTime.parse(apunte.recordatorioFecha!),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.riesgoTexto,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Contenido
            if (apunte.contenido.isNotEmpty)
              Text(
                apunte.contenido,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: AppColors.textoOscuro,
                  letterSpacing: 0.2,
                ),
              ),

            // Imágenes
            if (apunte.tieneImagenes) ...[
              const SizedBox(height: 32),
              const Text(
                'IMÁGENES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textoMedio,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _buildImagenesGrid(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagenesGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: apunte.imagenesPaths.length,
      itemBuilder: (context, index) {
        final imagePath = apunte.imagenesPaths[index];
        return GestureDetector(
          onTap: () => _verImagenCompleta(context, index),
          child: Hero(
            tag: 'imagen_$index',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borde, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.moradoPrincipal.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.fondoSurface,
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined,
                        color: AppColors.textoClaro),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _verImagenCompleta(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ImagenFullScreen(
          imagePaths: apunte.imagenesPaths,
          initialIndex: index,
        ),
      ),
    );
  }

  void _editarApunte(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApunteEditorScreen(apunte: apunte),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar apunte'),
        content: Text('¿Eliminar "${apunte.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.peligro),
            onPressed: () {
              context.read<ApunteProvider>().deleteApunte(apunte.id!);
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

// ═══════════════════════════════════════════════════════════════════════════
// PANTALLA FULLSCREEN PARA IMÁGENES CON PAGEVIEW
// ═══════════════════════════════════════════════════════════════════════════

class _ImagenFullScreen extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const _ImagenFullScreen({
    required this.imagePaths,
    required this.initialIndex,
  });

  @override
  State<_ImagenFullScreen> createState() => _ImagenFullScreenState();
}

class _ImagenFullScreenState extends State<_ImagenFullScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1} / ${widget.imagePaths.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemCount: widget.imagePaths.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Hero(
                tag: 'imagen_$index',
                child: Image.file(
                  File(widget.imagePaths[index]),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image_outlined,
                        color: Colors.white, size: 64),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
