import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/core/widgets/detail_section.dart';
import 'package:outventura/core/widgets/detail_sliver_header.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'dart:convert';

class EquipmentDetailPage extends ConsumerWidget {
  final Equipment equipamiento;

  const EquipmentDetailPage({super.key, required this.equipamiento});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    // Evaluar el estado del material para colores y etiquetas
    final String statusCode = equipamiento.status?.code ?? 'AVAILABLE';
    final bool esAgotado = statusCode == 'AVAILABLE' && equipamiento.availableUnits <= 0;
    final bool esMantenimiento = statusCode == 'MAINTENANCE';
    final bool esFueraServicio = statusCode == 'OUT_OF_SERVICE';
    final bool esNoDisponible = statusCode == 'UNAVAILABLE';
    final bool esDescatalogado = statusCode == 'DISCONTINUED';

    Color statusColor = cs.primary;
    String labelTexto = s.statusAvailable;

    if (esAgotado) {
      statusColor = cs.tertiary;
      labelTexto = s.statusOutOfStock;
    } else if (esMantenimiento) {
      statusColor = cs.onSurfaceVariant;
      labelTexto = s.statusMaintenance;
    } else if (esFueraServicio) {
      statusColor = cs.error;
      labelTexto = s.statusOutOfService;
    } else if (esNoDisponible) {
      statusColor = cs.outline;
      labelTexto = s.temporarilyUnavailable;
    } else if (esDescatalogado) {
      statusColor = cs.error.withValues(alpha: 0.6);
      labelTexto = s.discontinued;
    }

    // Extraer imagen y montar el texto de categorías
    final String? imagen = equipamiento.imageAsset;
    final String categoriasTexto = equipamiento.categories.isEmpty 
        ? s.noCategory 
        : equipamiento.categories.map((c) => c.localizedLabel(s)).join(', ');

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          DetailSliverHeader(
            title: equipamiento.title,
            subtitle: labelTexto,
            color: statusColor,
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
                  // --- IMAGEN DEL MATERIAL ---
                  if (imagen != null && imagen.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: cs.primaryContainer.withValues(alpha: 0.3),
                        boxShadow: [
                          BoxShadow(
                            color: cs.onSurface.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: imagen.startsWith('assets/')
                          ? Image.asset(imagen, fit: BoxFit.cover)
                          : Image.memory(base64Decode(imagen), fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // --- ESTADÍSTICAS RÁPIDAS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: DetailStatItem(
                          label: s.pricePerDay,
                          value: '${equipamiento.pricePerDay.toStringAsFixed(2)} €',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 36, color: cs.outlineVariant),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DetailStatItem(
                          label: s.totalStock,
                          value: '${equipamiento.availableUnits} / ${equipamiento.totalUnits}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- SECCIÓN: INFORMACIÓN GENERAL ---
                  DetailSection(
                    title: s.generalInfo,
                    children: [
                      DetailRow(
                        Icons.category_outlined,
                        s.categories,
                        categoriasTexto,
                      ),
                      DetailRow(
                        Icons.inventory_2_outlined,
                        s.status,
                        labelTexto,
                      ),
                    ],
                  ),

                  // --- SECCIÓN: DESCRIPCIÓN ---
                  if (equipamiento.description != null && equipamiento.description!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    DetailSection(
                      title: s.description,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Text(
                            equipamiento.description!,
                            style: tt.bodyLarge?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // --- SECCIÓN: TARIFAS Y FIANZAS ---
                  const SizedBox(height: 20),
                  DetailSection(
                    title: s.rates, 
                    children: [
                      DetailRow(
                        Icons.payments_outlined,
                        s.pricePerDay,
                        '${equipamiento.pricePerDay.toStringAsFixed(2)} €',
                      ),
                      DetailRow(
                        Icons.warning_amber_outlined,
                        s.damageFee,
                        '${equipamiento.damageFee.toStringAsFixed(2)} €',
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