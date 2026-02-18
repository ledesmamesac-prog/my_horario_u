// file: lib/screens/qr_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen>
    with SingleTickerProviderStateMixin {
  String? cedula;
  bool isLoading = true;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _loadCedula();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadCedula() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cedula = prefs.getString('cedula_institucional');
      isLoading = false;
    });
  }

  Future<void> _saveCedula(String nueva) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cedula_institucional', nueva);
    setState(() => cedula = nueva);
  }

  void _showConfigDialog() {
    final controller = TextEditingController(text: cedula ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Configurar cédula'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ingresa tu número de cédula institucional:',
                style: TextStyle(color: AppColors.textoMedio)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cédula',
                prefixIcon:
                    Icon(Icons.badge_rounded, color: AppColors.moradoPrincipal),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _saveCedula(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cédula guardada'),
                    backgroundColor: AppColors.exito,
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Código QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: _showConfigDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.moradoPrincipal))
          : cedula == null || cedula!.isEmpty
              ? _buildEmptyState()
              : _buildQRView(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                color: AppColors.moradoClaro,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_2_rounded,
                  size: 64, color: AppColors.moradoPrincipal),
            ),
            const SizedBox(height: 28),
            const Text(
              'Sin cédula configurada',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textoOscuro),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configura tu cédula para generar tu código QR institucional',
              style: TextStyle(color: AppColors.textoMedio),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _showConfigDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Configurar ahora'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRView() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (_, child) => Opacity(
        opacity: _opacityAnim.value,
        child: Transform.scale(scale: _scaleAnim.value, child: child),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'MI CÓDIGO QR',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textoMedio,
                  letterSpacing: 1.5),
            ),
            const Text(
              'Institucional',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textoOscuro),
            ),
            const SizedBox(height: 32),

            // QR Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.fondoCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: AppColors.moradoPrincipal,
                    width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.moradoPrincipal.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: cedula!,
                    version: QrVersions.auto,
                    size: 280,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.moradoOscuro,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.moradoPrincipal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.moradoClaro,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      cedula!,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.moradoPrincipal,
                          letterSpacing: 3),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.fondoSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borde),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.moradoPrincipal),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Presenta este QR para identificarte institucionalmente',
                      style:
                          TextStyle(color: AppColors.textoMedio, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _showConfigDialog,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Actualizar cédula'),
            ),
          ],
        ),
      ),
    );
  }
}
