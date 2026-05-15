import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/core/widgets/detail_section.dart';
import 'package:outventura/core/widgets/detail_sliver_header.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';

class ReservationDetailPage extends ConsumerWidget {
  final Reservation reserva;

  const ReservationDetailPage({super.key, required this.reserva});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;

    final String nombreUsuario = ref.watch(userNameProvider(reserva.userId));
    final actividad = reserva.activityId != null
        ? ref.watch(activityByIdProvider(reserva.activityId!))
        : null;

    final Color accentColor = switch (reserva.status) {
      ReservationStatus.pendiente  => cs.tertiary,
      ReservationStatus.confirmada => cs.primary,
      ReservationStatus.enCurso    => cs.secondary,
      ReservationStatus.finalizada => cs.secondary.withValues(alpha: 0.35),
      ReservationStatus.cancelada  => cs.error,
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header 
          DetailSliverHeader(
            title: s.reservationDetail(reserva.id),
            subtitle: reserva.status.localizedLabel(s),
            color: accentColor,
          ),

          // Contenido 
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB( 20, 24, 20, MediaQuery.of(context).padding.bottom + 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  Row(
                    children: [
                      // Fecha de inicio
                      DetailStatItem(
                        label: s.start,
                        value: FormateadorFecha.short(reserva.startDate),
                      ),
                      Container(width: 1, height: 36, color: cs.outlineVariant),
                      // Fecha de fin
                      DetailStatItem(
                        label: s.end,
                        value: FormateadorFecha.short(reserva.endDate),
                      ),
                      // Material reservado
                      if (reserva.lines.isNotEmpty) ...[
                        Container(width: 1, height: 36, color: cs.outlineVariant),
                        DetailStatItem(
                          label: s.reservedMaterial,
                          value: '${reserva.lines.length}',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Información general
                  DetailSection(
                    title: s.generalInfo,
                    children: [
                      DetailRow(Icons.person_outline, s.user, nombreUsuario),
                      if (actividad != null)
                        DetailRow(
                          Icons.hiking_outlined,
                          s.actividad,
                          '${actividad.startPoint} → ${actividad.endPoint}',
                        ),
                      DetailRow(
                        Icons.calendar_today_outlined,
                        s.start,
                        FormateadorFecha.withTime(reserva.startDate),
                      ),
                      DetailRow(
                        Icons.event_outlined,
                        s.end,
                        FormateadorFecha.withTime(reserva.endDate),
                      ),
                    ],
                  ),

                  // Material reservado
                  if (reserva.lines.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    DetailSection(
                      title: s.reservedMaterial,
                      children: [
                        for (final linea in reserva.lines)
                          Builder(builder: (context) {
                            final String nombre = ref.watch(equipmentNameProvider(linea.equipmentId));
                            return DetailRow(
                              Icons.inventory_2_outlined,
                              nombre,
                              s.unitsShort(linea.quantity),
                            );
                          }),
                      ],
                    ),
                  ],

                  // Daños
                  if (reserva.damageFee > 0 || reserva.damagedItems.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    DetailSection(
                      title: s.damages,
                      children: [
                        if (reserva.damageFee > 0)
                          DetailRow(
                            Icons.euro_outlined,
                            s.damageCharge,
                            s.priceEur(reserva.damageFee.toStringAsFixed(2)),
                          ),
                        for (final entry in reserva.damagedItems.entries)
                          Builder(builder: (context) {
                            final String nombre = ref.watch(equipmentNameProvider(entry.key));
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
            ),
          ),
        ],
      ),
    );
  }
}


