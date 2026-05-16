import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/core/widgets/detail_section.dart';
import 'package:outventura/core/widgets/detail_sliver_header.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';

class RequestDetailPage extends ConsumerWidget {
  final Request solicitud;

  const RequestDetailPage({super.key, required this.solicitud});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;

    final actividad = ref.watch(activityByIdProvider(solicitud.activityId));
    
    final String? nombreUsuario = solicitud.userId != null
        ? ref.watch(userNameProvider(solicitud.userId!))
        : null;
    final String? nombreExperto = solicitud.expertId != null
        ? ref.watch(userNameProvider(solicitud.expertId!))
        : null;
    final reserva = solicitud.reservationId != null
        ? ref.watch(reservationByIdProvider(solicitud.reservationId!))
        : null;

    // --- PRECIO DE LA ACTIVIDAD ---
    final double precioCalculadoActividad = actividad != null
        ? (actividad.price * solicitud.participantCount)
        : (solicitud.totalPrice > 0 ? solicitud.totalPrice : 0.0);

    // --- CÁLCULO DEL PRECIO DE LA RESERVA ---
    final List<Equipment> equipamientos = ref.watch(equipmentProvider).value ?? [];
    double precioReservaConDanios = 0.0;

    if (reserva != null) {
      double costeAlquilerMaterial = 0.0;
      final int dias = reserva.endDate.difference(reserva.startDate).inDays;
      final int multiplicadorDias = dias <= 0 ? 1 : dias;

      for (final linea in reserva.lines) {
        final Equipment? matchingEquip = equipamientos.cast<Equipment?>().firstWhere(
          (e) => e?.id == linea.equipmentId,
          orElse: () => null,
        );
        if (matchingEquip != null) {
          costeAlquilerMaterial += matchingEquip.pricePerDay * linea.quantity * multiplicadorDias;
        }
      }
      precioReservaConDanios = costeAlquilerMaterial + reserva.damageFee;
    }

    final double importeFinalTodoIncluido = precioCalculadoActividad + precioReservaConDanios;

    final Color accentColor = switch (solicitud.status) {
      RequestStatus.confirmada => cs.primary,
      RequestStatus.pendiente  => cs.tertiary,
      RequestStatus.enCurso    => cs.secondary,
      RequestStatus.finalizada => cs.secondary.withValues(alpha: 0.35),
      RequestStatus.cancelada  => cs.error,
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DetailSliverHeader(
            title: s.requestDetail(solicitud.id),
            subtitle: solicitud.status.localizedLabel(s),
            color: accentColor,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(context).padding.bottom + 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  Row(
                    children: [
                      DetailStatItem(
                        label: s.participants,
                        value: '${solicitud.participantCount}',
                      ),
                      if (importeFinalTodoIncluido > 0) ...[
                        Container(width: 1, height: 36, color: cs.outlineVariant),
                        DetailStatItem(
                          label: s.total,
                          value: s.priceEur(importeFinalTodoIncluido.toStringAsFixed(2)),
                        ),
                      ],
                      if (solicitud.requestedMaterials.isNotEmpty) ...[
                        Container(width: 1, height: 36, color: cs.outlineVariant),
                        DetailStatItem(
                          label: s.requestedMaterial,
                          value: '${solicitud.requestedMaterials.length}',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Información general
                  DetailSection(
                    title: s.generalInfo,
                    children: [
                      if (nombreUsuario != null)
                        DetailRow(Icons.person_outline, s.user, nombreUsuario),
                      if (nombreExperto != null)
                        DetailRow(Icons.star_outline, s.assignedExpert, nombreExperto),
                      DetailRow(
                        Icons.group_outlined,
                        s.participants,
                        s.participantsCount(solicitud.participantCount),
                      ),
                      if (reserva != null)
                        DetailRow(
                          Icons.book_online_outlined,
                          s.associatedReservation,
                          '#${reserva.id}',
                        ),
                    ],
                  ),

                  // Actividad
                  if (actividad != null) ...[
                    const SizedBox(height: 20),
                    DetailSection(
                      title: s.actividad,
                      children: [
                        DetailRow(
                          Icons.hiking_outlined,
                          s.route,
                          '${actividad.startPoint} - ${actividad.endPoint}',
                        ),
                        DetailRow(
                          Icons.calendar_today_outlined,
                          s.start,
                          FormateadorFecha.withTime(actividad.initDate),
                        ),
                        DetailRow(
                          Icons.event_outlined,
                          s.end,
                          FormateadorFecha.withTime(actividad.endDate),
                        ),
                        if (actividad.price > 0)
                          DetailRow(
                            Icons.euro_outlined,
                            s.basePrice,
                            s.pricePerPerson(actividad.price.toStringAsFixed(2)),
                          ),
                      ],
                    ),
                  ],

                  // Materiales solicitados
                  if (solicitud.requestedMaterials.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    DetailSection(
                      title: s.requestedMaterial,
                      children: [
                        for (final entry in solicitud.requestedMaterials.entries)
                          DetailRow(
                            Icons.inventory_2_outlined,
                            ref.watch(equipmentNameProvider(entry.key)),
                            s.unitsShort(entry.value),
                          ),
                      ],
                    ),
                  ],

                  // Resumen de precios
                  const SizedBox(height: 20),
                  DetailSection(
                    title: s.priceSummary,
                    children: [
                      DetailRow(
                        Icons.confirmation_number_outlined,
                        s.actividadSection,
                        s.priceEur(precioCalculadoActividad.toStringAsFixed(2)),
                      ),
                      if (reserva != null)
                        DetailRow(
                          Icons.inventory_2_outlined,
                          s.associatedReservation,
                          s.priceEur(precioReservaConDanios.toStringAsFixed(2)),
                        ),
                      DetailRow(
                        Icons.analytics_outlined,
                        s.total,
                        s.priceEur(importeFinalTodoIncluido.toStringAsFixed(2)),
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