import 'package:flutter/material.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/presentation/pages/calendar_page_v2.dart';
import 'package:outventura/features/outventura/presentation/pages/equipment_page.dart';
import 'package:outventura/features/outventura/presentation/pages/excursions_page.dart';
import 'package:outventura/features/outventura/presentation/pages/home_admin_page.dart';
import 'package:outventura/features/outventura/presentation/pages/home_client_page.dart';

class MainScaffold extends StatefulWidget {
  final Usuario usuario;

  const MainScaffold({super.key, required this.usuario});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _indiceActual = 0;

  late final List<Widget> _pages;
  late final List<BottomNavigationBarItem> _items;

  @override
  void initState() {
    super.initState();
    final bool esCliente = widget.usuario.rol == TipoRol.usuario;

    _pages = [
      esCliente
          ? HomeClientePage(usuario: widget.usuario)
          : const HomeAdminPage(),
      ExcursionsPage(puedeGestionar: !esCliente, puedeSolicitar: esCliente),
      EquipmentPage(puedeGestionar: !esCliente, puedeSolicitar: esCliente),
      CalendarPageV2(usuario: widget.usuario, esAdmin: !esCliente),
    ];

    _items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Inicio',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.hiking_outlined),
        activeIcon: Icon(Icons.hiking),
        label: 'Excursiones',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.inventory_2_outlined),
        activeIcon: Icon(Icons.inventory_2),
        label: 'Equipamiento',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today_outlined),
        activeIcon: Icon(Icons.calendar_today),
        label: 'Calendario',
      ),
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
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurfaceVariant,
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: _items,
      ),
    );
  }
}
