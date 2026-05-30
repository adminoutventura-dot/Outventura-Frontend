import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';

class CategoryCard extends StatelessWidget {
  final Category categoria;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const CategoryCard({
    super.key,
    required this.categoria,
    this.onEditar,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurfaceVariant.withAlpha(40)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primary.withAlpha(18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.category_outlined,
              color: cs.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoria.code,
                  style: tt.titleMedium?.copyWith(color: cs.onSurface),
                ),
                if (categoria.description != null && categoria.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    categoria.description!,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (onEditar != null || onEliminar != null)
            Row(
              children: [
                if (onEditar != null)
                  ActionIcon(
                    icon: Icons.edit_outlined,
                    color: cs.tertiary,
                    onTap: onEditar!,
                  ),
                if (onEditar != null && onEliminar != null)
                  const SizedBox(width: 6),
                if (onEliminar != null)
                  ActionIcon(
                    icon: Icons.delete_outline,
                    color: cs.error,
                    onTap: onEliminar!,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
