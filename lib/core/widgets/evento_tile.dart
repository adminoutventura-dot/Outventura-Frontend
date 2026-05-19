import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_text_styles.dart';

/// Card de evento del calendario para solicitudes y reservas.
/// Muestra un punto de color, título, subtítulo y flecha de navegación.
class EventoTile extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;

  const EventoTile({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.onPrimary),
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 6),
        title: Text(
          titulo,
          style: AppTextStyles.titleMedium.copyWith(color: cs.onSurface),
        ),
        subtitle: Text(
          subtitulo,
          style: AppTextStyles.bodyMedium.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
