import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';

class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Botones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- PRIMARY BUTTON ----
          Text(
            'PrimaryButton – Botón principal',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Confirmar',
            onPressed: () {},
          ),

          const SizedBox(height: 16),
          Text(
            'PrimaryButton – Con icono',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Con icono',
            icon: Icons.check,
            onPressed: () {},
          ),

          const SizedBox(height: 16),
          Text(
            'PrimaryButton – Color personalizado',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Color personalizado',
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            onPressed: () {},
          ),

          const SizedBox(height: 16),
          Text(
            'PrimaryButton – Deshabilitado',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Deshabilitado',
            onPressed: null,
          ),

          // ---- SECONDARY BUTTON ----
          const SizedBox(height: 20),
          Text(
            'SecondaryButton – Con borde',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Cancelar',
            onPressed: () {},
            borderColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),

          const SizedBox(height: 16),
          Text(
            'SecondaryButton – Borde azul oscuro',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Borde azul oscuro',
            onPressed: () {},
            borderColor: Theme.of(context).colorScheme.tertiary,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),

          const SizedBox(height: 16),
          Text(
            'SecondaryButton – Deshabilitado',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Deshabilitado',
            onPressed: null,
            borderColor: Theme.of(context).colorScheme.onSurfaceVariant,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),

          // ---- TERTIARY BUTTON ----
          const SizedBox(height: 20),
          Text(
            'TertiaryButton – Texto plano',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          TertiaryButton(
            label: 'Ver más',
            onPressed: () {},
          ),

          const SizedBox(height: 16),
          Text(
            'TertiaryButton – Color personalizado',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          TertiaryButton(
            label: 'Color personalizado',
            textColor: Theme.of(context).colorScheme.error,
            onPressed: () {},
          ),

          const SizedBox(height: 16),
          Text(
            'TertiaryButton – Deshabilitado',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          TertiaryButton(
            label: 'Deshabilitado',
            onPressed: null,
          ),
        ],
      ),
    );
  }
}
