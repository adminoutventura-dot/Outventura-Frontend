import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_input_field.dart';

class InputsDemo extends StatelessWidget {
  const InputsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Inputs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- INPUT BÁSICO ----
          Text(
            'CustomInputField – Campo básico',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          CustomInputField(
            controller: TextEditingController(),
            labelText: 'Nombre',
          ),

          const SizedBox(height: 20),

          // ---- INPUT CON ICONO ----
          Text(
            'CustomInputField – Con icono prefix',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          CustomInputField(
            controller: TextEditingController(),
            labelText: 'Correo electrónico',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 20),

          // ---- INPUT CONTRASEÑA ----
          Text(
            'CustomInputField – Contraseña',
            style: tt.titleMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 8),
          CustomInputField(
            controller: TextEditingController(),
            labelText: 'Contraseña',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            suffixIcon: const Icon(Icons.visibility_off_outlined),
          ),
        ],
      ),
    );
  }
}
