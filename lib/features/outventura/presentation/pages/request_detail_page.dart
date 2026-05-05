import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';

class RequestDetailPage extends ConsumerWidget {
  final Solicitud solicitud;

  const RequestDetailPage({super.key, required this.solicitud});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final excursion = ref.watch(excursionPorIdProvider(solicitud.idExcursion));
    final String? nombreUsuario = solicitud.idUsuario != null
        ? ref.watch(nombreUsuarioProvider(solicitud.idUsuario!))
        : null;
    final String? nombreExperto = solicitud.idExperto != null
        ? ref.watch(nombreUsuarioProvider(solicitud.idExperto!))
        : null;
    final reserva = solicitud.idReserva != null
        ? ref.watch(reservaPorIdProvider(solicitud.idReserva!))
        : null;

    // TODO: Arreglar colores
    final Color accentColor = switch (solicitud.estado) {
      EstadoSolicitud.pendiente  => cs.tertiary,
      EstadoSolicitud.confirmada => cs.secondary,
      EstadoSolicitud.enCurso    => cs.primary,
      EstadoSolicitud.finalizada => cs.primaryContainer,
      EstadoSolicitud.cancelada  => cs.error,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitud #${solicitud.id}'),
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.surfaceContainer, cs.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              solicitud.estado.label,
              style: tt.labelLarge?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // Información general
          _Section(
            title: 'Información general',
            cs: cs,
            tt: tt,
            children: [
              if (nombreUsuario != null)
                _Row(Icons.person_outline, 'Usuario', nombreUsuario, cs, tt),
              if (nombreExperto != null)
                _Row(Icons.star_outline, 'Experto asignado', nombreExperto, cs, tt),
              _Row(
                Icons.group_outlined,
                'Participantes',
                '${solicitud.numeroParticipantes} personas',
                cs,
                tt,
              ),
              if (solicitud.precioTotal > 0)
                _Row(
                  Icons.euro_outlined,
                  'Precio total',
                  '${solicitud.precioTotal.toStringAsFixed(2)} €',
                  cs,
                  tt,
                ),
              if (reserva != null)
                _Row(
                  Icons.book_online_outlined,
                  'Reserva asociada',
                  '#${reserva.id}',
                  cs,
                  tt,
                ),
            ],
          ),

          // Excursión
          if (excursion != null) ...[
            const SizedBox(height: 20),
            _Section(
              title: 'Excursión',
              cs: cs,
              tt: tt,
              children: [
                _Row(
                  Icons.hiking_outlined,
                  'Ruta',
                  '${excursion.puntoInicio} → ${excursion.puntoFin}',
                  cs,
                  tt,
                ),
                _Row(
                  Icons.calendar_today_outlined,
                  'Inicio',
                  FormateadorFecha.withTime(excursion.fechaInicio),
                  cs,
                  tt,
                ),
                _Row(
                  Icons.event_outlined,
                  'Fin',
                  FormateadorFecha.withTime(excursion.fechaFin),
                  cs,
                  tt,
                ),
                if (excursion.precio > 0)
                  _Row(
                    Icons.euro_outlined,
                    'Precio base',
                    '${excursion.precio.toStringAsFixed(2)} €/persona',
                    cs,
                    tt,
                  ),
              ],
            ),
          ],

          // Materiales solicitados
          if (solicitud.materialesSolicitados.isNotEmpty) ...[
            const SizedBox(height: 20),
            _Section(
              title: 'Material solicitado',
              cs: cs,
              tt: tt,
              children: [
                for (final entry in solicitud.materialesSolicitados.entries)
                  Builder(builder: (context) {
                    final String nombre =
                        ref.watch(nombreEquipamientoProvider(entry.key));
                    return _Row(
                      Icons.inventory_2_outlined,
                      nombre,
                      '${entry.value} ud.',
                      cs,
                      tt,
                    );
                  }),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// TODO: Pasar a Widgets auxiliares

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final ColorScheme cs;
  final TextTheme tt;

  const _Section({
    required this.title,
    required this.children,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.onSurfaceVariant.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.12),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme cs;
  final TextTheme tt;

  const _Row(this.icon, this.label, this.value, this.cs, this.tt);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          ),
          Text(
            value,
            style: tt.bodyMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
