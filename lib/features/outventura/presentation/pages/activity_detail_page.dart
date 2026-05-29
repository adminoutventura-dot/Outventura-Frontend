import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/widgets/detail_sliver_header.dart';
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

    // Buscamos la actividad actualizada
    final Activity actual = actividadesAsync.maybeWhen(
      data: (lista) => lista.cast<Activity>().firstWhere(
        (a) => a.id == actividad.id,
        orElse: () => actividad,
      ),
      orElse: () => actividad,
    );

    // Resolvemos el nombre del guía
    final String nombreGuia = actual.guideId != null
        ? ref.watch(userNameProvider(actual.guideId!))
        : 'Guía no asignado'; // TODO: hardcodeado

    final todasLasReservas = ref.watch(reservationsProvider).value ?? [];
    int inscritosActuales = 0;
    
    for (final reserva in todasLasReservas) {
      // Solo contamos las reservas activas (no las canceladas ni las finalizadas)
      if (reserva.status == WorkflowStatus.pendiente ||
          reserva.status == WorkflowStatus.confirmada ||
          reserva.status == WorkflowStatus.enCurso) {
        
        // Buscamos si esta reserva tiene una línea que sea de esta actividad
        for (final linea in reserva.lines) {
          if (linea.activityId == actual.id) {
            inscritosActuales += linea.quantity; // Sumamos los participantes
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
            subtitle: 'Detalles de la actividad', // TODO: hardcodeado
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

                  // ESTADÍSTICAS (Aquí mostramos los calculados y los máximos)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _StatItem(
                          label: 'Fecha', // TODO: hardcodeado
                          value: FormateadorFecha.short(actual.initDate),
                          cs: cs,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 36, color: cs.outlineVariant),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatItem(
                          label: 'Ocupación', // TODO: hardcodeado
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
                        'Guía', // TODO: hardcodeado
                        nombreGuia,
                      ),
                      DetailRow(
                        Icons.schedule_outlined,
                        'Horario', // TODO: hardcodeado
                        '${FormateadorFecha.timeOnly(actual.initDate)} - ${FormateadorFecha.timeOnly(actual.endDate)}',
                      ),
                      if (actual.startEndPoint != null)
                        DetailRow(
                          Icons.place_outlined,
                          'Punto de encuentro', // TODO: hardcodeado
                          actual.startEndPoint!,
                        ),
                      DetailRow(
                        Icons.terrain_outlined,
                        'Dificultad', // TODO: hardcodeado
                        'Nivel ${actual.difficulty}', // TODO: hardcodeado
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