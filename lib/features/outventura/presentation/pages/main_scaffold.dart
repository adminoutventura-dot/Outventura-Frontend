import 'package:flutter/material.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/presentation/pages/equipment_page.dart';
import 'package:outventura/features/outventura/presentation/pages/excursions_page.dart';
import 'package:outventura/features/outventura/presentation/pages/home_page.dart';
import 'package:outventura/features/outventura/presentation/pages/requests_page.dart';
import 'package:outventura/features/outventura/presentation/pages/reservations_page.dart';
import 'package:outventura/features/outventura/presentation/pages/users_page.dart';

class MainScaffold extends StatefulWidget {
  final Usuario usuario;

  const MainScaffold({super.key, required this.usuario});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _indiceActual = 0;

  late final List _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeAdminPage(),
      const ExcursionsPage(),
      const EquipmentPage(),
      const ReservationsPage(),
      const RequestsPage(),
      const UsersPage()
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: _pages[_indiceActual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (int index) => setState(() => _indiceActual = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: cs.onPrimary,
        unselectedItemColor: cs.onSurfaceVariant,
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hiking_outlined),
            activeIcon: Icon(Icons.hiking),
            label: 'Excursiones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Equipamiento',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online_outlined),
            activeIcon: Icon(Icons.book_online),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Usuarios',
          ),
        ],
      ),
    );
  }
}