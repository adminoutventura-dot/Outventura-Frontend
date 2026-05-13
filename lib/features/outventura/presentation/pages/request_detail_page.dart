import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/date_formatter.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/core/widgets/detail_section.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';

class RequestDetailPage extends ConsumerWidget {
  final Request solicitud;

  const RequestDetailPage({super.key, required this.solicitud});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

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

    // Colores igual que en request_card.dart
    final Color accentColor = switch (solicitud.status) {
      RequestStatus.confirmada => cs.primary,
      RequestStatus.pendiente => cs.tertiary,
      RequestStatus.finalizada => cs.secondary.withValues(alpha: 0.35),
      RequestStatus.cancelada => cs.error,
      RequestStatus.enCurso => cs.secondary,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(s.requestDetail(solicitud.id)),
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
              solicitud.status.localizedLabel(s),
              style: tt.labelLarge?.copyWith(color: cs.onPrimary),
              textAlign: TextAlign.center,
            ),
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
              if (solicitud.totalPrice > 0)
                DetailRow(
                  Icons.euro_outlined,
                  s.totalPrice,
                  s.priceEur(solicitud.totalPrice.toStringAsFixed(2)),                
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
                  Builder(builder: (context) {
                    final String nombre = ref.watch(equipmentNameProvider(entry.key));
                    return DetailRow(
                      Icons.inventory_2_outlined,
                      nombre,
                      s.unitsShort(entry.value),                    
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

