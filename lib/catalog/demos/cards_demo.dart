import 'package:flutter/material.dart';
import 'package:outventura/features/auth/data/fakes/users_fake.dart';
import 'package:outventura/features/outventura/data/fakes/equipment_fake.dart';
import 'package:outventura/features/outventura/data/fakes/excursions_fake.dart';
import 'package:outventura/features/outventura/data/fakes/reservations_fake.dart';
import 'package:outventura/features/outventura/data/fakes/requests_fake.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/widgets/equipment_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/excursion_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/request_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_line_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/stat_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/user_card.dart';

class CardsDemo extends StatelessWidget {
  const CardsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cards')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // STAT CARD
          Text('StatCard – Fila de estadísticas', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          Row(
            children: [
              StatCard(colorScheme: cs, textTheme: tt, value: '12', label: 'Reservas'),
              const SizedBox(width: 8),
              StatCard(colorScheme: cs, textTheme: tt, value: '3', label: 'Pendientes'),
              const SizedBox(width: 8),
              StatCard(colorScheme: cs, textTheme: tt, value: '47', label: 'Usuarios'),
            ],
          ),

          // EXCURSION CARD
          const SizedBox(height: 24),
          Text('ExcursionCard – Con imagen (admin)', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          ExcursionCard(
            excursion: catalogoExcursiones[0],
            onEditar: () {},
            onEliminar: () {},
          ),

          const SizedBox(height: 16),
          Text('ExcursionCard – Sin imagen (usuario)', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          ExcursionCard(
            excursion: catalogoExcursiones[2],
            onSolicitar: () {},
          ),

          // SOLICITUD CARD
          const SizedBox(height: 24),
          Text('SolicitudCard – Solo lectura', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          SolicitudCard(
            solicitud: solicitudesFake[0],
            excursion: catalogoExcursiones.firstWhere((Activity e) => e.id == solicitudesFake[0].idExcursion),
          ),

          const SizedBox(height: 16),
          Text('SolicitudCard – Pendiente con acciones', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          SolicitudCard(
            solicitud: solicitudesFake[1],
            excursion: catalogoExcursiones.firstWhere((Activity e) => e.id == solicitudesFake[1].idExcursion),
            onGestionar: () {},
            onCancelar: () {},
            onEditar: () {},
          ),

          // RESERVA CARD
          const SizedBox(height: 24),
          Text('ReservaCard – Pendiente con acciones', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          ReservaCard(
            reserva: reservasFake[0],
            nombreUsuario: '${usuariosFake[2].name} ${usuariosFake[2].surname}',
            nombreExcursion: () {
              final Activity? ex = catalogoExcursiones.where((Activity e) => e.id == reservasFake[0].idExcursion).firstOrNull;
              return ex != null ? '${ex.startPoint} → ${ex.endPoint}' : null;
            }(),
            lineas: reservasFake[0].lineas.map((LineaReserva l) {
              final Equipamiento eq = equipamientosFake.firstWhere((Equipamiento e) => e.id == l.idEquipamiento, orElse: () => equipamientosFake.first);
              return (nombre: eq.title, imagen: eq.imageAsset, cantidad: l.cantidad);
            }).toList(),
            onAprobar: () {},
            onRechazar: () {},
          ),

          const SizedBox(height: 16),
          Text('ReservaCard – Confirmada', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          ReservaCard(
            reserva: reservasFake[1],
            nombreUsuario: '${usuariosFake[2].name} ${usuariosFake[2].surname}',
            lineas: reservasFake[1].lineas.map((LineaReserva l) {
              final Equipamiento eq = equipamientosFake.firstWhere((Equipamiento e) => e.id == l.idEquipamiento, orElse: () => equipamientosFake.first);
              return (nombre: eq.title, imagen: eq.imageAsset, cantidad: l.cantidad);
            }).toList(),
            onRegistrarDevolucion: () {},
            onCancelar: () {},
          ),

          // RESERVATION LINE CARD
          const SizedBox(height: 24),
          Text('ReservationLineCard – Sin daños', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          ReservationLineCard(
            linea: reservasFake[0].lineas.first,
            equipamiento: equipamientosFake.firstWhere(
              (Equipamiento e) => e.id == reservasFake[0].lineas.first.idEquipamiento,
              orElse: () => equipamientosFake.first,
            ),
            cantidadDaniada: 0,
            onEdit: () {},
            onDelete: () {},
          ),

          const SizedBox(height: 16),
          Text('ReservationLineCard – Con daños', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          ReservationLineCard(
            linea: reservasFake[0].lineas.first,
            equipamiento: equipamientosFake.firstWhere(
              (Equipamiento e) => e.id == reservasFake[0].lineas.first.idEquipamiento,
              orElse: () => equipamientosFake.first,
            ),
            cantidadDaniada: 2,
            onEdit: () {},
            onDelete: () {},
            menosCoste: () {},
            masCoste: () {},
          ),

          // EQUIPAMIENTO CARD
          const SizedBox(height: 24),
          Text('EquipmentCard – Solo lectura', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          EquipmentCard(equipamiento: equipamientosFake[0]),

          const SizedBox(height: 16),
          Text('EquipmentCard – Con acciones', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          EquipmentCard(
            equipamiento: equipamientosFake[1],
            onEditar: () {},
            onEliminar: () {},
          ),

          // USER CARD
          const SizedBox(height: 24),
          Text('UserCard – Superadmin', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          UserCard(usuario: usuariosFake[0], onEditar: () {}, onEliminar: () {}),

          const SizedBox(height: 16),
          Text('UserCard – Admin', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          UserCard(usuario: usuariosFake[1]),

          const SizedBox(height: 16),
          Text('UserCard – Usuario', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          UserCard(usuario: usuariosFake[2]),
        ],
      ),
    );
  }
}

