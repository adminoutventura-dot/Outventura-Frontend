import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_date_selector.dart';
import 'package:outventura/core/widgets/app_dropdown_field.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/core/widgets/app_image_picker_field.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/auth/data/fakes/users_fake.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/data/fakes/excursions_fake.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

class InputsDemo extends StatefulWidget {
  const InputsDemo({super.key});

  @override
  State<InputsDemo> createState() => _InputsDemoState();
}

class _InputsDemoState extends State<InputsDemo> {
  // Chips
  final Set<CategoriaActividad> _chips = {};

  // Dropdowns
  int? _idUsuario;
  int? _idExcursion;

  // Date
  DateTime _fecha = DateTime(2026, 6, 15);

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Inputs & Widgets')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // CustomInputField
          Text('CustomInputField – Básico', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          CustomInputField(controller: TextEditingController(), labelText: 'Nombre'),

          const SizedBox(height: 16),
          Text('CustomInputField – Con icono', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          CustomInputField(
            controller: TextEditingController(),
            labelText: 'Correo electrónico',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),
          Text('CustomInputField – Contraseña', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          CustomInputField(
            controller: TextEditingController(),
            labelText: 'Contraseña',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            suffixIcon: const Icon(Icons.visibility_off_outlined),
          ),

          // AppDropdownField (Usuario)
          const SizedBox(height: 24),
          Text('AppDropdownField – Usuario', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          AppDropdownField<Usuario>(
            value: _idUsuario,
            items: usuariosFake,
            itemValue: (Usuario u) => u.id,
            itemLabel: (Usuario u) => '${u.nombre} ${u.apellidos}',
            prefixIcon: Icons.person_outline,
            label: 'Experto asignado',
            hint: 'Sin asignar',
            onChanged: (int? v) => setState(() => _idUsuario = v),
          ),

          // AppExcursionDropdown 
          const SizedBox(height: 24),
          Text('AppExcursionDropdown', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          AppDropdownField<Excursion>(
            value: _idExcursion,
            items: catalogoExcursiones,
            itemValue: (e) => e.id,
            itemLabel: (e) => '${e.puntoInicio} → ${e.puntoFin}',
            prefixIcon: Icons.hiking_outlined,
            label: 'Excursión',
            hint: 'Selecciona una excursión',
            onChanged: (int? v) => setState(() => _idExcursion = v),
          ),

          // AppDateSelector
          const SizedBox(height: 24),
          Text('AppDateSelector', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          AppDateSelector(
            label: 'Fecha de inicio',
            date: _fecha,
            onDateSelected: (DateTime d) => setState(() => _fecha = d),
          ),

          // TagWidget
          const SizedBox(height: 24),
          Text('TagWidget', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              TagWidget(text: 'Pendiente',    backgroundColor: cs.tertiary,  textColor: cs.onPrimary),
              TagWidget(text: 'Confirmada',   backgroundColor: cs.secondary, textColor: cs.onPrimary),
              TagWidget(text: 'Finalizada',   backgroundColor: cs.primaryContainer,   textColor: cs.onPrimaryContainer),
              TagWidget(text: 'Cancelada',    backgroundColor: cs.error,              textColor: cs.onError),
              TagWidget(text: 'Acuático',     backgroundColor: cs.onPrimary,          textColor: cs.onPrimaryContainer),
            ],
          ),

          // AppChipWrap + AppChoiceChip           
          const SizedBox(height: 24),
          Text('AppChoiceChip – Selección múltiple', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          AppChipWrap(
            children: CategoriaActividad.values.map((CategoriaActividad cat) => AppChoiceChip(
              label: cat.label,
              seleccionado: _chips.contains(cat),
              onSelected: (_) => setState(() {
                if (_chips.contains(cat)) {
                  _chips.remove(cat);
                } else {
                  _chips.add(cat);
                }
              }),
            )).toList(),
          ),

          // AppImagePickerField           
          const SizedBox(height: 24),
          Text('AppImagePickerField – Sin imagen', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          const AppImagePickerField(),

          const SizedBox(height: 16),
          Text('AppImagePickerField – Con imagen (asset)', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          const AppImagePickerField(imageUrl: 'assets/images/Camino.jpg'),

          const SizedBox(height: 16),
          Text('AppImagePickerField – Circular', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          const AppImagePickerField(
            imageUrl: 'assets/images/Camino.jpg',
            isCircular: true,
            placeholder: Icons.person_outline,
          ),

          
        ],
      ),
    );
  }
}

