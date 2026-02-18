// file: lib/screens/apuntes_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/apunte.dart';
import '../providers/apunte_provider.dart';
import '../theme/app_theme.dart';
import 'apunte_detail_screen.dart';
import 'apunte_editor_screen.dart';

class ApuntesScreen extends StatefulWidget {
  const ApuntesScreen({super.key});

  @override
  State<ApuntesScreen> createState() => _ApuntesScreenState();
}

class _ApuntesScreenState extends State<ApuntesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apuntes'),
        actions: [
          // NUEVO: Botón para probar notificaciones
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Probar notificación',
            onPressed: () {
              context.read<ApunteProvider>().sendTestNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enviando notificación de prueba...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _mostrarBuscador(context),
          ),
        ],
      ),
      body: Consumer<ApunteProvider>(
        builder: (context, provider, _) {
          final apuntes =
              _query.isEmpty ? provider.apuntes : provider.buscar(_query);

          if (apuntes.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apuntes.length,
            itemBuilder: (context, index) {
              return _ApunteCard(
                apunte: apuntes[index],
                onEdit: () =>
                    _showApunteDialog(context, apunte: apuntes[index]),
                onDelete: () => _confirmDelete(context, apuntes[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showApunteDialog(context),
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Nuevo Apunte'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.moradoClaro,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sticky_note_2_outlined,
              size: 56,
              color: AppColors.moradoPrincipal,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sin apuntes aún',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textoOscuro,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea tu primer apunte académico',
            style: TextStyle(color: AppColors.textoMedio),
          ),
        ],
      ),
    );
  }

  void _mostrarBuscador(BuildContext context) {
    showSearch(
      context: context,
      delegate: _ApunteSearchDelegate(context.read<ApunteProvider>()),
    );
  }

  void _showApunteDialog(BuildContext context, {Apunte? apunte}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApunteEditorScreen(apunte: apunte),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Apunte apunte) {
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
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ... (El resto del archivo se mantiene igual)

// ─── Card de Apunte ───────────────────────────────────────────────────────────

class _ApunteCard extends StatelessWidget {
  final Apunte apunte;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ApunteCard({
    required this.apunte,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('dd MMM yyyy').format(
      DateTime.parse(apunte.fechaCreacion),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.fondoCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borde),
        boxShadow: [
          BoxShadow(
            color: AppColors.moradoPrincipal.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ApunteDetailScreen(apunte: apunte),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        apunte.titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textoOscuro,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert,
                          color: AppColors.textoClaro),
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Editar')),
                        PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                      ],
                    ),
                  ],
                ),

                if (apunte.contenido.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    apunte.contenido,
                    style: const TextStyle(
                      color: AppColors.textoMedio,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                if (apunte.tieneImagenes) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: apunte.imagenesPaths.length > 3
                          ? 4
                          : apunte.imagenesPaths.length,
                      itemBuilder: (context, i) {
                        if (i == 3 && apunte.imagenesPaths.length > 4) {
                          return Container(
                            width: 80,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: BoxDecoration(
                              color: AppColors.moradoPrincipal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: AppColors.moradoPrincipal),
                            ),
                            child: Center(
                              child: Text(
                                '+${apunte.imagenesPaths.length - 3}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.moradoPrincipal,
                                ),
                              ),
                            ),
                          );
                        }

                        return Container(
                          width: 80,
                          margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(apunte.imagenesPaths[i]),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.fondoSurface,
                                child: const Center(
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 14, color: AppColors.textoClaro),
                    const SizedBox(width: 4),
                    Text(fecha,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textoClaro)),
                    if (apunte.tieneRecordatorio) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.amarilloClaro,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.notifications_active_rounded,
                                size: 12, color: AppColors.riesgo),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM HH:mm').format(
                                DateTime.parse(apunte.recordatorioFecha!),
                              ),
                              style: const TextStyle(
                                fontSize: 11,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Search Delegate ──────────────────────────────────────────────────────────

class _ApunteSearchDelegate extends SearchDelegate {
  final ApunteProvider provider;
  _ApunteSearchDelegate(this.provider);

  @override
  String get searchFieldLabel => 'Buscar apuntes...';

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final resultados = provider.buscar(query);
    if (resultados.isEmpty) {
      return const Center(child: Text('Sin resultados'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resultados.length,
      itemBuilder: (context, i) => ListTile(
        title: Text(resultados[i].titulo),
        subtitle: Text(resultados[i].contenido,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        onTap: () => close(context, resultados[i]),
      ),
    );
  }
}
