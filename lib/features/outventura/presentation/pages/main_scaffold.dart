import 'package:flutter/material.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/presentation/pages/calendar_page.dart';
import 'package:outventura/features/outventura/presentation/pages/equipment_page.dart';
import 'package:outventura/features/outventura/presentation/pages/excursions_page.dart';
import 'package:outventura/features/outventura/presentation/pages/home_admin_page.dart';
import 'package:outventura/features/outventura/presentation/pages/home_client_page.dart';
import 'package:outventura/l10n/app_localizations.dart';

class MainScaffold extends StatefulWidget {
  final Usuario usuario;

  const MainScaffold({super.key, required this.usuario});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _indiceActual = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final bool esCliente = widget.usuario.role == TipoRol.usuario;

    _pages = [
      esCliente
          ? HomeClientePage(usuario: widget.usuario)
          : const HomeAdminPage(),
      ExcursionsPage(puedeGestionar: !esCliente, puedeSolicitar: esCliente),
      EquipmentPage(puedeGestionar: !esCliente, puedeSolicitar: esCliente),
      CalendarPage(usuario: widget.usuario, esAdmin: !esCliente),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final AppLocalizations s = AppLocalizations.of(context)!;

    return Scaffold(
      body: _pages[_indiceActual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (int index) => setState(() => _indiceActual = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurfaceVariant,
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: s.tabHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.hiking_outlined),
            activeIcon: const Icon(Icons.hiking),
            label: s.tabExcursions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_outlined),
            activeIcon: const Icon(Icons.inventory_2),
            label: s.tabEquipment,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today),
            label: s.tabCalendar,
          ),
        ],
      ),
    );
  }
}
