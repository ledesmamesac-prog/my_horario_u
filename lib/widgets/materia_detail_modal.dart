// file: lib/widgets/materia_detail_modal.dart
import 'package:flutter/material.dart';
import '../models/materia.dart';
import '../theme/app_theme.dart';

class MateriaDetailModal extends StatelessWidget {
  final Materia materia;
  final double promedio;
  final String estado;
  final Color colorEstado;
  final VoidCallback onVerNotas;

  const MateriaDetailModal({
    super.key,
    required this.materia,
    required this.promedio,
    required this.estado,
    required this.colorEstado,
    required this.onVerNotas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.fondoPrincipal,
            Color(materia.color).withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: AppColors.moradoPrincipal.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HANDLE BAR
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.moradoPrincipal.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // COLOR BAR
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(materia.color).withOpacity(0.3),
                  Color(materia.color),
                  Color(materia.color).withOpacity(0.3),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TÍTULO
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Color(materia.color),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Color(materia.color).withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            materia.nombre.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.moradoPrincipal,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            materia.codigo,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // INFORMACIÓN
                _buildInfoRow(
                  Icons.person,
                  'Profesor',
                  materia.profesor,
                  AppColors.peligro,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.school,
                  'Créditos',
                  '${materia.creditos} créditos académicos',
                  AppColors.moradoPrincipal,
                ),

                const SizedBox(height: 24),

                // PROMEDIO Y ESTADO
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.fondoCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorEstado.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorEstado.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROMEDIO ACTUAL',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            promedio.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: colorEstado,
                              shadows: [
                                Shadow(
                                  color: colorEstado.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colorEstado.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorEstado, width: 2),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _getIconEstado(estado),
                              color: colorEstado,
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              estado.toUpperCase(),
                              style: TextStyle(
                                color: colorEstado,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // BOTÓN VER NOTAS
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onVerNotas,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.moradoPrincipal,
                      foregroundColor: AppColors.fondoPrincipal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.moradoPrincipal.withOpacity(0.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grade, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'VER NOTAS DETALLADAS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconEstado(String estado) {
    switch (estado) {
      case 'ganando':
        return Icons.trending_up;
      case 'riesgo':
        return Icons.warning;
      case 'perdiendo':
        return Icons.trending_down;
      default:
        return Icons.remove;
    }
  }
}
