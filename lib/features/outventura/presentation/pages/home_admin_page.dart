import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/presentation/pages/users_page.dart';
import 'package:outventura/features/outventura/presentation/pages/reservations_page.dart';
import 'package:outventura/features/outventura/presentation/pages/requests_page.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/request_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/stat_card.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/l10n/app_localizations.dart';

class HomeAdminPage extends ConsumerWidget {
  const HomeAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;
    final List<Activity> excursiones = ref.watch(excursionesProvider).value ?? [];
    final List<Equipamiento> equipamientos = ref.watch(equipamientosProvider).value ?? [];
    final List<Solicitud> solicitudes = ref.watch(solicitudesProvider).value ?? [];

    return Scaffold(
      // Barra superior con título y fondo degradado.
      appBar: AppBar(
        title: Text(s.adminPanel),
        // Icono del Drawer
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surfaceContainer,
                Theme.of(context).colorScheme.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      // Drawer
      drawer: const AppDrawer(),

      body: Column(
        children: [
          // Contenedor de estadísticas.
          Container(
            color: cs.surfaceContainer,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila de tarjetas de estadísticas.
                  Container(
                    decoration: BoxDecoration(
                      color: cs.onPrimary,
                      border: Border(
                        bottom: BorderSide(
                          color: cs.onSurfaceVariant.withAlpha(50),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Row(
                        children: [
                          // Tarjeta de excursiones.
                          StatCard(
                            colorScheme: cs,
                            textTheme: tt,
                            value: '${excursiones.length}',
                            label: s.excursionsLabel,
                          ),
                          const SizedBox(width: 10),
                          // Tarjeta de equipamiento.
                          StatCard(
                            colorScheme: cs,
                            textTheme: tt,
                            value: '${equipamientos.length}',
                            label: s.equipmentLabel,
                          ),
                          const SizedBox(width: 10),
                          // Tarjeta de pendientes.
                          StatCard(
                            colorScheme: cs,
                            textTheme: tt,
                            value:
                                '${solicitudes.where((Solicitud s) => s.estado == EstadoSolicitud.pendiente).length}',
                            label: s.pendingLabel,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Contenido principal.
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 24),
                // Sección de accesos rápidos de gestión.
                Text(
                  s.management,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    backgroundColor: cs.surface,
                    label: s.users,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UsersPage()),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    backgroundColor: cs.surface,
                    label: s.reservations,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ReservationsPage(puedeGestionar: true, puedeCrear: true)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    backgroundColor: cs.surface,
                    label: s.requests,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RequestsPage(puedeGestionar: true, puedeCrear: true)),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                // Título de sección.
                Text(
                  s.recentRequests,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),

                // Tarjetas de solicitudes recientes.
                for (Solicitud solicitud in solicitudes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SolicitudCard(
                      solicitud: solicitud,
                      excursion: ref.watch(excursionPorIdProvider(solicitud.idExcursion)) ?? excursiones.first,
                      nombreUsuario: solicitud.idUsuario != null
                          ? ref.watch(nombreUsuarioProvider(solicitud.idUsuario!))
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
