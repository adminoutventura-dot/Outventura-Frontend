import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/data/fakes/solicitudes_fake.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/request_card.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes'),
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.inverseSurface,
                cs.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: solicitudesFake.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index < solicitudesFake.length) {
            return SolicitudCard(
              solicitud: solicitudesFake[index],
              onGestionar: () {},
            );
          }
          return Center(
            child: Text(
              'No hay más solicitudes',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          );
        },
      ),
    );
  }
}
