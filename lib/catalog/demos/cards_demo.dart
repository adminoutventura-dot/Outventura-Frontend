import 'package:flutter/material.dart';
import 'package:outventura/features/auth/data/fakes/users_fake.dart';
import 'package:outventura/features/outventura/data/fakes/equipment_fake.dart';
import 'package:outventura/features/outventura/data/fakes/activities_fake.dart';
import 'package:outventura/features/outventura/data/fakes/reservations_fake.dart';
import 'package:outventura/features/outventura/data/fakes/requests_fake.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/widgets/equipment_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/activity_card.dart';
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

          // ACTIVITY CARD
          const SizedBox(height: 24),
          Text('ActivityCard – Con imagen (admin)', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          ActivityCard(
            actividad: activitiesFake[0],
            onEditar: () {},
            onEliminar: () {},
          ),

          const SizedBox(height: 16),
          Text('ActivityCard – Sin imagen (usuario)', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          ActivityCard(
            actividad: activitiesFake[2],
            onSolicitar: () {},
          ),

          // SOLICITUD CARD
          const SizedBox(height: 24),
          Text('SolicitudCard – Solo lectura', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          RequestCard(
            solicitud: requestsFake[0],
            actividad: activitiesFake.firstWhere((Activity e) => e.id == requestsFake[0].activityId),
          ),

          const SizedBox(height: 16),
          Text('SolicitudCard – Pendiente con acciones', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          RequestCard(
            solicitud: requestsFake[1],
            actividad: activitiesFake.firstWhere((Activity e) => e.id == requestsFake[1].activityId),
            onGestionar: () {},
            onCancelar: () {},
            onEditar: () {},
          ),

          // RESERVA CARD
          const SizedBox(height: 24),
          Text('ReservaCard – Pendiente con acciones', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          ReservationCard(
            reserva: reservationsFake[0],
            nombreUsuario: '${usersFake[2].name} ${usersFake[2].surname}',
            nombreActividad: () {
              final Activity? ex = activitiesFake.where((Activity e) => e.id == reservationsFake[0].activityId).firstOrNull;
              return ex != null ? '${ex.startPoint} → ${ex.endPoint}' : null;
            }(),
            lineas: reservationsFake[0].lines.map((ReservationLine l) {
              final Equipment eq = equipmentFake.firstWhere((Equipment e) => e.id == l.equipmentId, orElse: () => equipmentFake.first);
              return (nombre: eq.title, imagen: eq.imageAsset, cantidad: l.quantity);
            }).toList(),
            onAprobar: () {},
            onRechazar: () {},
          ),

          const SizedBox(height: 16),
          Text('ReservaCard – Confirmada', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          ReservationCard(
            reserva: reservationsFake[1],
            nombreUsuario: '${usersFake[2].name} ${usersFake[2].surname}',
            lineas: reservationsFake[1].lines.map((ReservationLine l) {
              final Equipment eq = equipmentFake.firstWhere((Equipment e) => e.id == l.equipmentId, orElse: () => equipmentFake.first);
              return (nombre: eq.title, imagen: eq.imageAsset, cantidad: l.quantity);
            }).toList(),
            onRegistrarDevolucion: () {},
            onCancelar: () {},
          ),

          // RESERVATION LINE CARD
          const SizedBox(height: 24),
          Text('ReservationLineCard – Sin daños', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          ReservationLineCard(
            linea: reservationsFake[0].lines.first,
            equipamiento: equipmentFake.firstWhere(
              (Equipment e) => e.id == reservationsFake[0].lines.first.equipmentId,
              orElse: () => equipmentFake.first,
            ),
            cantidadDaniada: 0,
            onEdit: () {},
            onDelete: () {},
          ),

          const SizedBox(height: 16),
          Text('ReservationLineCard – Con daños', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          ReservationLineCard(
            linea: reservationsFake[0].lines.first,
            equipamiento: equipmentFake.firstWhere(
              (Equipment e) => e.id == reservationsFake[0].lines.first.equipmentId,
              orElse: () => equipmentFake.first,
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
          EquipmentCard(equipamiento: equipmentFake[0]),

          const SizedBox(height: 16),
          Text('EquipmentCard – Con acciones', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          EquipmentCard(
            equipamiento: equipmentFake[1],
            onEditar: () {},
            onEliminar: () {},
          ),

          // USER CARD
          const SizedBox(height: 24),
          Text('UserCard – Superadmin', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          UserCard(usuario: usersFake[0], onEditar: () {}, onEliminar: () {}),

          const SizedBox(height: 16),
          Text('UserCard – Admin', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          UserCard(usuario: usersFake[1]),

          const SizedBox(height: 16),
          Text('UserCard – Usuario', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          UserCard(usuario: usersFake[2]),
        ],
      ),
    );
  }
}

