import 'package:flutter/material.dart';

class AppTab extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;

  const AppTab({
    super.key,
    required this.label,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: seleccionado ? cs.primary : cs.onSurfaceVariant.withAlpha(100),
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(
                color: seleccionado ? cs.primary : cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
