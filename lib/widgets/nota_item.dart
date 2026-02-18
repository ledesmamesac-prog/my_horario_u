// file: lib/widgets/nota_item.dart
import 'package:flutter/material.dart';
import '../models/nota.dart';
import '../theme/app_theme.dart';

class NotaItem extends StatelessWidget {
  final Nota nota;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const NotaItem({
    super.key,
    required this.nota,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(nota.tipo),
        subtitle: Text('${nota.porcentaje}% del total'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              nota.notaObtenida.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.moradoPrincipal,
              ),
            ),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
