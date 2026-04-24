import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/requests_provider.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
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
    final List<Excursion> excursiones = ref.watch(excursionesProvider);
    final List<Equipamiento> equipamientos = ref.watch(equipamientosProvider);
    final List<Solicitud> solicitudes = ref.watch(solicitudesProvider);
    final usuarios = ref.watch(usuariosProvider);

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
                Theme.of(context).colorScheme.inverseSurface,
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
            color: cs.inverseSurface,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila de tarjetas de estadísticas.
                  Container(
                    decoration: BoxDecoration(
                      color: cs.onInverseSurface,
                      border: Border(
                        bottom: BorderSide(
                          color:   cs.onSurfaceVariant.withAlpha(100),
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
                            value: '${solicitudes.where((Solicitud s) => s.estado == EstadoSolicitud.pendiente).length}',
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
                // Título de sección.
                Text(
                  'SOLICITUDES RECIENTES',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                // Tarjetas de solicitudes recientes.
                for (Solicitud solicitud in solicitudes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SolicitudCard(
                      solicitud: solicitud,
                      excursion: excursiones.firstWhere(
                        (Excursion e) => e.id == solicitud.idExcursion,
                        orElse: () => excursiones.first,
                      ),
                      nombreUsuario: solicitud.idUsuario != null
                          ? () {
                              final u = usuarios.firstWhere((u) => u.id == solicitud.idUsuario, orElse: () => usuarios.first);
                              return '${u.nombre} ${u.apellidos}';
                            }()
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