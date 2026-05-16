import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/core/widgets/detail_section.dart';
import 'package:outventura/core/widgets/detail_sliver_header.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';

class ReservationDetailPage extends ConsumerWidget {
  final Reservation reserva;

  const ReservationDetailPage({super.key, required this.reserva});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;

    // USO DE PROVIDERS REACIVOS DIRECTOS
    final String nombreUsuario = ref.watch(userNameProvider(reserva.userId));
    final actividad = reserva.activityId != null
        ? ref.watch(activityByIdProvider(reserva.activityId!))
        : null;

    // --- CÁLCULOS ---
    final List<Equipment> equipamientos = ref.watch(equipmentProvider).value ?? [];
    final int dias = reserva.endDate.difference(reserva.startDate).inDays;
    final int multiplicadorDias = dias <= 0 ? 1 : dias;

    final double totalAlquiler = reserva.lines.fold(0.0, (sum, linea) {
      final equip = equipamientos.cast<Equipment?>().firstWhere((e) => e?.id == linea.equipmentId, orElse: () => null);
      return sum + (equip != null ? (equip.pricePerDay * linea.quantity * multiplicadorDias) : 0.0);
    });

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
          DetailSliverHeader(
            title: s.reservationDetail(reserva.id),
            subtitle: reserva.status.localizedLabel(s),
            color: accentColor,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(context).padding.bottom + 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DetailStatItem(label: s.start, value: FormateadorFecha.short(reserva.startDate)),
                      Container(width: 1, height: 36, color: cs.outlineVariant),
                      DetailStatItem(label: s.end, value: FormateadorFecha.short(reserva.endDate)),
                      if (reserva.lines.isNotEmpty) ...[
                        Container(width: 1, height: 36, color: cs.outlineVariant),
                        DetailStatItem(label: s.reservedMaterial, value: '${reserva.lines.length}'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  DetailSection(
                    title: s.generalInfo,
                    children: [
                      DetailRow(Icons.person_outline, s.user, nombreUsuario),
                      if (actividad != null)
                        DetailRow(Icons.hiking_outlined, s.actividad, '${actividad.startPoint} → ${actividad.endPoint}'),
                      DetailRow(Icons.calendar_today_outlined, s.start, FormateadorFecha.withTime(reserva.startDate)),
                      DetailRow(Icons.event_outlined, s.end, FormateadorFecha.withTime(reserva.endDate)),
                    ],
                  ),
                  if (reserva.lines.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    DetailSection(
                      title: s.reservedMaterial,
                      children: [
                        for (final linea in reserva.lines)
                          DetailRow(
                            Icons.inventory_2_outlined,
                            ref.watch(equipmentNameProvider(linea.equipmentId)),
                            s.unitsShort(linea.quantity),
                          ),
                      ],
                    ),
                  ],
                  if (reserva.damageFee > 0 || reserva.damagedItems.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    DetailSection(
                      title: s.damages,
                      children: [
                        if (reserva.damageFee > 0)
                          DetailRow(Icons.euro_outlined, s.damageCharge, s.priceEur(reserva.damageFee.toStringAsFixed(2))),
                        for (final entry in reserva.damagedItems.entries)
                          DetailRow(
                            Icons.warning_amber_outlined,
                            ref.watch(equipmentNameProvider(entry.key)),
                            s.damagedItems(entry.value),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  DetailSection(
                    title: s.priceSummary,
                    children: [
                      DetailRow(Icons.credit_card_outlined, s.materialsRental, s.priceEur(totalAlquiler.toStringAsFixed(2))),
                      if (reserva.damageFee > 0)
                        DetailRow(Icons.warning_amber_outlined, s.totalDamages, '+ ${s.priceEur(reserva.damageFee.toStringAsFixed(2))}'),
                      DetailRow(Icons.analytics_outlined, s.total, s.priceEur((totalAlquiler + reserva.damageFee).toStringAsFixed(2))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}