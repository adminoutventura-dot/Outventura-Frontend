import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/controllers/calendar_page_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/pages/reservation_detail_page.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  final CalendarPageController _controller = CalendarPageController();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final reservasAsync = ref.watch(reservationsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const CustomAppBar(title: 'Calendari'),
      body: reservasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (todas) {
          final eventos = _controller.obtenerEventosActividades(todas);

          if (eventos.isEmpty) {
            return const Center(
              child: Text('No hi ha excursions programades.'),
            );
          }

          return ListView.builder(
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final Booking res = eventos[index];
              final int? actId = res.lines
                  .where((l) => l.activityId != null)
                  .map((l) => l.activityId)
                  .firstOrNull;

              return ListTile(
                leading: Icon(Icons.calendar_month, color: cs.primary),
                title: Text(
                  ref.watch(activityNameProvider(actId)) ?? 'Excursió',
                ),
                subtitle: Text(
                  'Client: ${ref.watch(userNameProvider(res.userId))}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReservationDetailPage(reserva: res),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
