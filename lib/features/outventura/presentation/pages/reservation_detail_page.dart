import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';

class ReservationDetailPage extends ConsumerWidget {
  final Reserva reserva;

  const ReservationDetailPage({super.key, required this.reserva});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final String nombreUsuario = ref.watch(nombreUsuarioProvider(reserva.idUsuario));
    final excursion = reserva.idExcursion != null
        ? ref.watch(excursionPorIdProvider(reserva.idExcursion!))
        : null;

    final Color accentColor = switch (reserva.estado) {
      EstadoReserva.pendiente   => cs.tertiary,
      EstadoReserva.confirmada  => cs.secondary,
      EstadoReserva.enCurso     => cs.primary,
      EstadoReserva.finalizada  => cs.primaryContainer,
      EstadoReserva.cancelada   => cs.error,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Reserva #${reserva.id}'),
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
              reserva.estado.label,
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
              _Row(Icons.person_outline, 'Usuario', nombreUsuario, cs, tt),
              if (excursion != null)
                _Row(
                  Icons.hiking_outlined,
                  'Excursión',
                  '${excursion.puntoInicio} → ${excursion.puntoFin}',
                  cs,
                  tt,
                ),
              _Row(
                Icons.calendar_today_outlined,
                'Inicio',
                FormateadorFecha.withTime(reserva.fechaInicio),
                cs,
                tt,
              ),
              _Row(
                Icons.event_outlined,
                'Fin',
                FormateadorFecha.withTime(reserva.fechaFin),
                cs,
                tt,
              ),
            ],
          ),

          // Material reservado
          if (reserva.lineas.isNotEmpty) ...[
            const SizedBox(height: 20),
            _Section(
              title: 'Material reservado',
              cs: cs,
              tt: tt,
              children: [
                for (final linea in reserva.lineas)
                  Builder(builder: (context) {
                    final String nombre =
                        ref.watch(nombreEquipamientoProvider(linea.idEquipamiento));
                    return _Row(
                      Icons.inventory_2_outlined,
                      nombre,
                      '${linea.cantidad} ud.',
                      cs,
                      tt,
                    );
                  }),
              ],
            ),
          ],

          // Daños
          if (reserva.cargoDanios > 0 || reserva.itemsDaniados.isNotEmpty) ...[
            const SizedBox(height: 20),
            _Section(
              title: 'Daños',
              cs: cs,
              tt: tt,
              children: [
                if (reserva.cargoDanios > 0)
                  _Row(
                    Icons.euro_outlined,
                    'Cargo por daños',
                    '${reserva.cargoDanios.toStringAsFixed(2)} €',
                    cs,
                    tt,
                  ),
                for (final entry in reserva.itemsDaniados.entries)
                  Builder(builder: (context) {
                    final String nombre =
                        ref.watch(nombreEquipamientoProvider(entry.key));
                    return _Row(
                      Icons.warning_amber_outlined,
                      nombre,
                      '${entry.value} dañado(s)',
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
