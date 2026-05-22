import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/services/pricing_service.dart';
import 'package:outventura/core/widgets/detail_section.dart';
import 'package:outventura/core/widgets/detail_sliver_header.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';

class ReservationDetailPage extends ConsumerWidget {
  final Booking reserva;

  const ReservationDetailPage({super.key, required this.reserva});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;

    final String nombreUsuario = ref.watch(userNameProvider(reserva.userId));
    final actividad = reserva.activityId != null
        ? ref.watch(activityByIdProvider(reserva.activityId!))
        : null;

    // --- CÁLCULOS ---
    final List<Equipment> equipamientos = ref.watch(equipmentProvider).value ?? [];
    // calcularPrecioReserva gestiona el mínimo de 1 día internamente.
    final double totalAlquiler = calcularPrecioReserva(
      lineas: reserva.lines,
      fechaDesde: actividad?.initDate ?? DateTime.now(),
      fechaHasta: actividad?.endDate ?? DateTime.now(),
      equipamientos: equipamientos,
    );

    final Color accentColor = switch (reserva.status) {
      WorkflowStatus.pendiente => cs.tertiary,
      WorkflowStatus.confirmada => cs.primary,
      WorkflowStatus.enCurso => cs.secondary,
      WorkflowStatus.finalizada => cs.secondary.withValues(alpha: 0.35),
      WorkflowStatus.cancelada => cs.error,
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DetailSliverHeader(
            title: s.reservationDetail,
            subtitle: reserva.status.localizedLabel(s),
            color: accentColor,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(context).padding.bottom + 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats principales
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Participantes
                      if (actividad != null) ...[
                        Expanded(
                          child: DetailStatItem(
                            label: s.start,
                            value: FormateadorFecha.short(actividad.initDate),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(width: 1, height: 36, color: cs.outlineVariant),
                        const SizedBox(width: 12),

                        // Fin (fecha de devolución)
                        Expanded(
                          child: DetailStatItem(
                            label: s.end,
                            value: FormateadorFecha.short(actividad.endDate),
                          ),
                        ),
                      ],

                      // Cantidad de material reservado (solo si es > 0)
                      if (reserva.lines.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Container(width: 1, height: 36, color: cs.outlineVariant),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DetailStatItem(
                            label: s.reservedMaterial,
                            value: '${reserva.lines.length}',
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sección de información general
                  DetailSection(
                    title: s.generalInfo,
                    children: [
                      // Nombre del usuario que hizo la reserva
                      DetailRow(Icons.person_outline, s.user, nombreUsuario),

                      // Actividad asociada a la reserva (si existe)
                      if (actividad != null) ...[
                        DetailRow(Icons.hiking_outlined, s.actividad, '${actividad.startPoint} → ${actividad.endPoint}'),
                      
                        // Fecha de inicio (fecha de recogida del material)
                        DetailRow(Icons.calendar_today_outlined, s.start, FormateadorFecha.withTime(actividad.initDate)),
                      
                        // Fecha de fin (fecha de devolución del material)
                        DetailRow(Icons.event_outlined, s.end, FormateadorFecha.withTime(actividad.endDate)),
                      ],
                    ],
                  ),

                  // Sección de material reservado (solo si hay material reservado)
                  if (reserva.lines.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    DetailSection(
                      title: s.reservedMaterial,
                      children: [
                        for (final linea in reserva.lines)
                        // Lineas de material reservado
                          DetailRow(
                            Icons.inventory_2_outlined,
                            ref.watch(equipmentNameProvider(linea.equipmentId)),
                            s.unitsShort(linea.quantity),
                          ),
                      ],
                    ),
                  ],

                  // Sección de daños (solo si hay daños registrados)
                  if (reserva.damageFee > 0 || reserva.damagedItems.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    DetailSection(
                      title: s.damages,
                      children: [
                        // Si hay una penalización por daños, muestra un item con el coste total de la penalización.
                        if (reserva.damageFee > 0)
                          DetailRow(Icons.euro_outlined, s.damageCharge, s.priceEur(reserva.damageFee.toStringAsFixed(2))),
                        
                        // Si hay material dañado, muestra un item por cada tipo de material dañado con la cantidad dañada.
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
                  // Sección de resumen de precios
                  DetailSection(
                    title: s.priceSummary,
                    children: [
                      // Precio total del alquiler
                      DetailRow(Icons.credit_card_outlined, s.materialsRental, s.priceEur(totalAlquiler.toStringAsFixed(2))),
                      
                      // Si hay una penalización por daños, se muestra como un item.
                      if (reserva.damageFee > 0)
                        DetailRow(Icons.warning_amber_outlined, s.totalDamages, '+ ${s.priceEur(reserva.damageFee.toStringAsFixed(2))}'),
                      // Precio total (alquiler + daños)
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