import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/widgets/detail_sliver_header.dart';
import 'package:outventura/features/auth/domain/entities/guide.dart';
import 'package:outventura/features/auth/presentation/providers/guides_provider.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/core/widgets/detail_section.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/features/outventura/presentation/providers/booking_provider.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';

class ActivityDetailPage extends ConsumerWidget {
  final Activity actividad;

  const ActivityDetailPage({super.key, required this.actividad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final actividadesAsync = ref.watch(activitiesProvider);

    // Busca la actividad actualizada
    final Activity actual = actividadesAsync.maybeWhen(
      data: (lista) => lista.cast<Activity>().firstWhere(
        (a) => a.id == actividad.id,
        orElse: () => actividad,
      ),
      orElse: () => actividad,
    );

    // Resolve el nombre del guía
    final List<Guide> guias = ref.watch(guidesProvider).value ?? [];
    final Guide? guia = guias.firstWhereOrNull((g) => g.id == actual.guideId);
    
    final String nombreGuia = guia != null
        ? '${guia.user?.name ?? ''} ${guia.user?.surname ?? ''}'.trim()
        : 'Guía no asignado';

    final todasLasReservas = ref.watch(reservationsProvider).value ?? [];
    int inscritosActuales = 0;
    
    for (final reserva in todasLasReservas) {
      // Solo cuenta las reservas activas (no las canceladas ni las finalizadas)
      if (reserva.status == WorkflowStatus.pendiente ||
          reserva.status == WorkflowStatus.confirmada ||
          reserva.status == WorkflowStatus.enCurso) {
        
        // Busca si esta reserva tiene una línea que sea de esta actividad
        for (final linea in reserva.lines) {
          if (linea.activityId == actual.id) {
            inscritosActuales += linea.quantity; // Suma los participantes
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          DetailSliverHeader(
            title: actual.title,
            subtitle: s.activityDetails,
            color: cs.primary,
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
                  // FOTO
                  if (actual.imageAsset != null && actual.imageAsset!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: actual.imageAsset!.startsWith('assets/')
                            ? Image.asset(actual.imageAsset!, fit: BoxFit.cover)
                            : Image.memory(
                                base64Decode(actual.imageAsset!.contains(',')
                                    ? actual.imageAsset!.split(',').last
                                    : actual.imageAsset!),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ESTADÍSTICAS (Aquí muestra los calculados y los máximos)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _StatItem(
                          label: s.date,
                          value: FormateadorFecha.short(actual.initDate),
                          cs: cs,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 36, color: cs.outlineVariant),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatItem(
                          label: s.occupancy,
                          // Aquí se pinta el "calculado / máximo"
                          value: '$inscritosActuales / ${actual.maxParticipants}',
                          cs: cs,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // DESCRIPCIÓN
                  if (actual.description != null && actual.description!.isNotEmpty) ...[
                    Text(
                      s.description.toUpperCase(),
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      actual.description!,
                      style: tt.bodyLarge?.copyWith(
                        color: cs.onSurface,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // INFORMACIÓN GENERAL
                  DetailSection(
                    title: s.generalInfo,
                    children: [
                      DetailRow(
                        Icons.person_pin_outlined,
                        s.guide,
                        nombreGuia,
                      ),
                      DetailRow(
                        Icons.schedule_outlined,
                        s.schedule,
                        '${FormateadorFecha.timeOnly(actual.initDate)} - ${FormateadorFecha.timeOnly(actual.endDate)}',
                      ),
                      if (actual.startEndPoint != null)
                        DetailRow(
                          Icons.place_outlined,
                          s.meetingPoint,
                          actual.startEndPoint!,
                        ),
                      DetailRow(
                        Icons.terrain_outlined,
                        s.difficulty,
                        '${s.level} ${actual.difficulty}',
                      ),
                    ],
                  ),

                  // MATERIAL RECOMENDADO (Se oculta solo si está vacío)
                  if (actual.recommendedEquipmentIds.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    DetailSection(
                      title: s.recommendedMaterial,
                      children: [
                        for (final eqId in actual.recommendedEquipmentIds)
                          DetailRow(
                            Icons.inventory_2_outlined,
                            ref.watch(equipmentNameProvider(eqId)),
                            '', 
                          ),
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

// Widget auxiliar
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;

  const _StatItem({required this.label, required this.value, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 1.1,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}