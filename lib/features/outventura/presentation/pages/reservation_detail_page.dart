import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/core/widgets/detail_section.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';

class ReservationDetailPage extends ConsumerWidget {
  final Reserva reserva;

  const ReservationDetailPage({super.key, required this.reserva});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final String nombreUsuario = ref.watch(nombreUsuarioProvider(reserva.idUsuario));
    final excursion = reserva.idExcursion != null
        ? ref.watch(excursionPorIdProvider(reserva.idExcursion!))
        : null;

    final Color accentColor = switch (reserva.estado) {
      EstadoReserva.pendiente   => cs.tertiary,
      EstadoReserva.confirmada  => cs.primary,
      EstadoReserva.enCurso     => cs.secondary,
      EstadoReserva.finalizada  => cs.secondary.withValues(alpha: 0.35),
      EstadoReserva.cancelada   => cs.error,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(s.reservationDetail(reserva.id)),
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
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              reserva.estado.localizedLabel(s),
              style: tt.labelLarge?.copyWith(color: cs.onPrimary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // Información general
          DetailSection(
            title: s.generalInfo,
            children: [
              DetailRow(Icons.person_outline, s.user, nombreUsuario),
              if (excursion != null)
                DetailRow(
                  Icons.hiking_outlined,
                  s.excursion,
                  '${excursion.puntoInicio} ? ${excursion.puntoFin}',                
                ),
              DetailRow(
                Icons.calendar_today_outlined,
                s.start,
                FormateadorFecha.withTime(reserva.fechaInicio),              
              ),
              DetailRow(
                Icons.event_outlined,
                s.end,
                FormateadorFecha.withTime(reserva.fechaFin),              
              ),
            ],
          ),

          // Material reservado
          if (reserva.lineas.isNotEmpty) ...[
            const SizedBox(height: 20),
            DetailSection(
              title: s.reservedMaterial,
              children: [
                for (final linea in reserva.lineas)
                  Builder(builder: (context) {
                    final String nombre = ref.watch(nombreEquipamientoProvider(linea.idEquipamiento));
                    return DetailRow(
                      Icons.inventory_2_outlined,
                      nombre,
                      s.unitsShort(linea.cantidad),                    
                    );
                  }),
              ],
            ),
          ],

          // Daños
          if (reserva.cargoDanios > 0 || reserva.itemsDaniados.isNotEmpty) ...[
            const SizedBox(height: 20),
            DetailSection(
              title: s.damages,
              children: [
                if (reserva.cargoDanios > 0)
                  DetailRow(
                    Icons.euro_outlined,
                    s.damageCharge,
                    s.priceEur(reserva.cargoDanios.toStringAsFixed(2)),                  
                  ),
                for (final entry in reserva.itemsDaniados.entries)
                  Builder(builder: (context) {
                    final String nombre = ref.watch(nombreEquipamientoProvider(entry.key));
                    return DetailRow(
                      Icons.warning_amber_outlined,
                      nombre,
                      s.damagedItems(entry.value),                    
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

