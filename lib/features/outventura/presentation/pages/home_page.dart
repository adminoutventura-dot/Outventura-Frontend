import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/request_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/stat_card.dart';
import 'package:outventura/features/outventura/data/fakes/solicitudes_fake.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({super.key});

  @override
  State<HomeAdminPage> createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
                            value: '4',
                            label: 'EXCURSIONES',
                          ),
                          const SizedBox(width: 10),
                          // Tarjeta de materiales.
                          StatCard(
                            colorScheme: cs,
                            textTheme: tt,
                            value: '8',
                            label: 'MATERIALES',
                          ),
                          const SizedBox(width: 10),
                          // Tarjeta de pendientes.
                          StatCard(
                            colorScheme: cs,
                            textTheme: tt,
                            value: '2',
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
                for (var solicitud in solicitudesFake)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SolicitudCard(solicitud: solicitud),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}