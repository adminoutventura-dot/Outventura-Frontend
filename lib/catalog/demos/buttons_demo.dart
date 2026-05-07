import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_buttons.dart';

class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Botones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- PRIMARY BUTTON ----
          const Text('PrimaryButton – Botón principal'),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Confirmar',
            onPressed: () {},
          ),

          const SizedBox(height: 16),
          const Text('PrimaryButton – Con icono'),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Con icono',
            icon: Icons.check,
            onPressed: () {},
          ),

          const SizedBox(height: 16),
          const Text('PrimaryButton – Color personalizado'),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Color personalizado',
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            onPressed: () {},
          ),

          const SizedBox(height: 16),
          const Text('PrimaryButton – Deshabilitado'),
          const SizedBox(height: 8),
          const PrimaryButton(
            label: 'Deshabilitado',
            onPressed: null,
          ),

          // ---- SECONDARY BUTTON ----
          const SizedBox(height: 20),
          const Text('SecondaryButton – Con borde'),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Cancelar',
            onPressed: () {},
            borderColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),

          const SizedBox(height: 16),
          const Text('SecondaryButton – Borde azul oscuro'),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Borde azul oscuro',
            onPressed: () {},
            borderColor: Theme.of(context).colorScheme.tertiary,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),

          const SizedBox(height: 16),
          const Text('SecondaryButton – Deshabilitado'),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Deshabilitado',
            onPressed: null,
            borderColor: Theme.of(context).colorScheme.onSurfaceVariant,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),

          // ---- TERTIARY BUTTON ----
          const SizedBox(height: 20),
          const Text('TertiaryButton – Texto plano'),
          const SizedBox(height: 8),
          TertiaryButton(
            label: 'Ver más',
            onPressed: () {},
          ),

          const SizedBox(height: 16),
          const Text('TertiaryButton – Color personalizado'),
          const SizedBox(height: 8),
          TertiaryButton(
            label: 'Color personalizado',
            textColor: Theme.of(context).colorScheme.error,
            onPressed: () {},
          ),

          const SizedBox(height: 16),
          const Text('TertiaryButton – Deshabilitado'),
          const SizedBox(height: 8),
          const TertiaryButton(
            label: 'Deshabilitado',
            onPressed: null,
          ),

          // ---- MINI BUTTON ----
          const SizedBox(height: 20),
          const Text('MiniButton – Texto plano'),
          const SizedBox(height: 8),
          MiniButton(
            label: 'Mini',
            onPressed: () {},
          ),

          // ---- ADD FAB ----
          const SizedBox(height: 20),
          const Text('AddFab – Por defecto'),
          const SizedBox(height: 8),
          Center(
            child: AddFab(onPressed: () async {}),
          ),

          const SizedBox(height: 16),
          const Text('AddFab – Icono personalizado'),
          const SizedBox(height: 8),
          Center(
            child: AddFab(
              icon: Icons.upload_outlined,
              onPressed: () async {},
            ),
          ),
        ],
      ),
    );
  }
}
