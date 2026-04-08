import 'package:flutter/material.dart';
import 'package:outventura/features/outventura/data/fakes/excursiones_fake.dart';
import 'package:outventura/features/outventura/data/fakes/solicitudes_fake.dart';
import 'package:outventura/features/outventura/presentation/widgets/excursion_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/request_card.dart';

class CardsDemo extends StatelessWidget {
  const CardsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cards')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- EXCURSION CARD ----
          Text(
            'ExcursionCard – Con imagen (admin)',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          ExcursionCard(
            excursion: excursionCatalog[0],
            imageAsset: 'assets/images/Camino.jpg',
            onEditar: () {},
            onEliminar: () {},
          ),

          const SizedBox(height: 16),
          Text(
            'ExcursionCard – Sin imagen (usuario)',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          ExcursionCard(
            excursion: excursionCatalog[2],
            onSolicitar: () {},
          ),

          // ---- SOLICITUD CARD ----
          const SizedBox(height: 20),
          Text(
            'SolicitudCard – Solo lectura',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          SolicitudCard(solicitud: solicitudesFake[0]),

          const SizedBox(height: 16),
          Text(
            'SolicitudCard – Con icono Gestionar',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          SolicitudCard(
            solicitud: solicitudesFake[1],
            onGestionar: () {},
          ),
        ],
      ),
    );
  }
}

