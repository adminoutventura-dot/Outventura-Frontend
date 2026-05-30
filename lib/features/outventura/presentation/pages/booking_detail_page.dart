import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/features/outventura/domain/entities/booking.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/presentation/providers/booking_provider.dart';
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

    final reservasAsync = ref.watch(reservationsProvider);
    final Booking actual = reservasAsync.maybeWhen(
      data: (lista) => lista.cast<Booking>().firstWhere(
        (r) => r.id == reserva.id,
        orElse: () => reserva,
      ),
      orElse: () => reserva,
    );

    final String nombreUsuario = ref.watch(userNameProvider(reserva.userId));

    // Extrae el ID de la actividad buscando en la lista interna de líneas
    final int? activityIdFromLine = actual.lines
        .where((l) => l.activityId != null)
        .map((l) => l.activityId)
        .firstOrNull;

    final actividad = activityIdFromLine != null
        ? ref.watch(activityByIdProvider(activityIdFromLine))
        : null;

    final List<Equipment> equipamientos =
        ref.watch(equipmentProvider).value ?? [];
    final double totalAlquiler = calcularPrecioReserva(
      lineas: actual.lines,
      fechaDesde: actual.startDate,
      fechaHasta: actual.endDate,
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
              padding: EdgeInsets.fromLTRB(
                20,
                24,
                20,
                MediaQuery.of(context).padding.bottom + 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: DetailStatItem(
                          label: s.start,
                          value: FormateadorFecha.short(actual.startDate),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 36, color: cs.outlineVariant),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DetailStatItem(
                          label: s.end,
                          value: FormateadorFecha.short(actual.endDate),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  DetailSection(
                    title: s.generalInfo,
                    children: [
                      DetailRow(Icons.person_outline, s.user, nombreUsuario),
                      if (actividad != null)
                        DetailRow(
                          Icons.hiking_outlined,
                          s.actividad,
                          actividad.title,
                        ),
                      DetailRow(
                        Icons.calendar_today_outlined,
                        s.start,
                        FormateadorFecha.withTime(actual.startDate),
                      ),
                      DetailRow(
                        Icons.event_outlined,
                        s.end,
                        FormateadorFecha.withTime(actual.endDate),
                      ),
                    ],
                  ),

                  if (actual.lines.any((l) => l.equipmentId != null)) ...[
                    const SizedBox(height: 20),
                    DetailSection(
                      title: s.reservedMaterial,
                      children: [
                        for (final linea in actual.lines.where(
                          (l) => l.equipmentId != null,
                        ))
                          DetailRow(
                            Icons.inventory_2_outlined,
                            ref.watch(
                              equipmentNameProvider(linea.equipmentId!),
                            ),
                            s.unitsShort(linea.quantity),
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),
                  DetailSection(
                    title: s.priceSummary,
                    children: [
                      DetailRow(
                        Icons.credit_card_outlined,
                        s.materialsRental,
                        s.priceEur(totalAlquiler.toStringAsFixed(2)),
                      ),
                      DetailRow(
                        Icons.analytics_outlined,
                        s.total,
                        s.priceEur(totalAlquiler.toStringAsFixed(2)),
                      ),
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
