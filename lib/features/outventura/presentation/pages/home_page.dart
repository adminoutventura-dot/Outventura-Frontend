import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/pages/equipment_page.dart';
import 'package:outventura/features/outventura/presentation/pages/excursions_page.dart';
import 'package:outventura/features/outventura/presentation/pages/users_page.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/request_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/stat_card.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';

class HomeAdminPage extends ConsumerWidget {
  const HomeAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final List<Excursion> excursiones = ref.watch(excursionesProvider).value ?? [];
    final List<Equipamiento> equipamientos = ref.watch(equipamientosProvider).value ?? [];
    final List<Solicitud> solicitudes = ref.watch(solicitudesProvider).value ?? [];

    return Scaffold(
      // Barra superior con título y fondo degradado.
      appBar: AppBar(
        title: const Text('Panel de Administración'),
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
                            label: 'EXCURSIONES',
                          ),
                          const SizedBox(width: 10),
                          // Tarjeta de equipamiento.
                          StatCard(
                            colorScheme: cs,
                            textTheme: tt,
                            value: '${equipamientos.length}',
                            label: 'EQUIPAMIENTO',
                          ),
                          const SizedBox(width: 10),
                          // Tarjeta de pendientes.
                          StatCard(
                            colorScheme: cs,
                            textTheme: tt,
                            value:
                                '${solicitudes.where((Solicitud s) => s.estado == EstadoSolicitud.pendiente).length}',
                            label: 'PENDIENTES',
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
                  'GESTIÓN',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    label: 'Excursiones',
                    icon: Icons.hiking_outlined,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ExcursionsPage(puedeGestionar: true)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    label: 'Equipamiento',
                    icon: Icons.inventory_2_outlined,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EquipmentPage(puedeGestionar: true)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    label: 'Usuarios',
                    icon: Icons.people_outline,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UsersPage()),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                // Título de sección.
                Text(
                  'SOLICITUDES RECIENTES',
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

class HomeClientePage extends ConsumerWidget {
  final Usuario usuario;

  const HomeClientePage({super.key, required this.usuario});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final List<Reserva> misReservas = (ref.watch(reservasProvider).value ?? [])
        .where((Reserva r) => r.idUsuario == usuario.id)
        .toList();
    final List<Solicitud> misSolicitudes = (ref.watch(solicitudesProvider).value ?? [])
        .where((Solicitud s) => s.idUsuario == usuario.id)
        .toList();
    final int solicitudesPendientes = misSolicitudes
        .where((Solicitud s) => s.estado == EstadoSolicitud.pendiente)
        .length;
    final List<Excursion> excursiones = ref.watch(excursionesProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Cliente'),
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
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            color: cs.surfaceContainer,
            child: SafeArea(
              bottom: false,
              child: Container(
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
                      StatCard(
                        colorScheme: cs,
                        textTheme: tt,
                        value: '${misReservas.length}',
                        label: 'MIS RESERVAS',
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        colorScheme: cs,
                        textTheme: tt,
                        value: '${misSolicitudes.length}',
                        label: 'MIS SOLICITUDES',
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        colorScheme: cs,
                        textTheme: tt,
                        value: '$solicitudesPendientes',
                        label: 'PENDIENTES',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 24),
                Text(
                  'Hola, ${usuario.nombre}',
                  style: tt.titleLarge?.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: 6),
                Text(
                  'Desde aquí puedes crear y revisar tus reservas y solicitudes.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                // Botones de navegación a reservas y solicitudes
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Mis Reservas',
                    icon: Icons.event_available_outlined,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/reservas');
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Mis Solicitudes',
                    icon: Icons.assignment_outlined,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/solicitudes');
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'SOLICITUDES RECIENTES',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                if (misSolicitudes.isEmpty)
                  Text(
                    'No tienes solicitudes todavía.',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  )
                else
                  for (final Solicitud solicitud in misSolicitudes.take(3))
                    Builder(builder: (context) {
                      final Excursion? exc = ref.watch(excursionPorIdProvider(solicitud.idExcursion));
                      if (exc == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SolicitudCard(
                          solicitud: solicitud,
                          excursion: exc,
                          nombreUsuario:
                              '${usuario.nombre} ${usuario.apellidos}',
                        ),
                      );
                    }),
                const SizedBox(height: 24),
                // Sección de nuevas excursiones
                Text(
                  'NUEVAS EXCURSIONES',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                if (excursiones.isEmpty)
                  Text(
                    'No hay excursiones nuevas.',
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  )
                else
                // TODO: Pasar a widget separado y mostrar solo las 3 últimas
                  for (final Excursion excursion in excursiones.take(3).toList().reversed)
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(Icons.hiking_outlined),
                        title: Text(
                          excursion.puntoInicio,
                          style: tt.titleMedium,
                        ),
                        subtitle: excursion.descripcion != null
                            ? Text(
                                excursion.descripcion!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                        trailing: Icon(Icons.arrow_forward_ios, color: cs.primary, size: 18),
                        onTap: () {
                          // Navegar a la página de detalles de la excursión si existe
                          Navigator.of(context).pushNamed('/excursion', arguments: excursion);
                        },
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
