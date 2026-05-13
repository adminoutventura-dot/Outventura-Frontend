import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_date_selector.dart';
import 'package:outventura/core/widgets/app_dropdown_field.dart';
import 'package:outventura/core/widgets/app_time_selector.dart';
import 'package:outventura/core/widgets/detail_section.dart';
import 'package:outventura/core/widgets/filter_bottom_sheet.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/core/widgets/app_image_picker_field.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/auth/data/fakes/users_fake.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/data/fakes/activities_fake.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';

class InputsDemo extends StatefulWidget {
  const InputsDemo({super.key});

  @override
  State<InputsDemo> createState() => _InputsDemoState();
}

class _InputsDemoState extends State<InputsDemo> {
  // Chips
  final Set<ActivityCategory> _chips = {};

  // Dropdowns
  int? _idUsuario;
  int? _idActividad;

  // Date
  DateTime _fecha = DateTime(2026, 6, 15);

  // Time
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

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
          AppDropdownField<User>(
            value: _idUsuario,
            items: usersFake,
            itemValue: (User u) => u.id,
            itemLabel: (User u) => '${u.name} ${u.surname}',
            prefixIcon: Icons.person_outline,
            label: 'Experto asignado',
            hint: 'Sin asignar',
            onChanged: (int? v) => setState(() => _idUsuario = v),
          ),

          // AppDropdownField (Actividad)
          const SizedBox(height: 24),
          Text('AppDropdownField – Actividad', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          AppDropdownField<Activity>(
            value: _idActividad,
            items: activitiesFake,
            itemValue: (e) => e.id,
            itemLabel: (e) => '${e.startPoint} → ${e.endPoint}',
            prefixIcon: Icons.hiking_outlined,
            label: 'Actividad',
            hint: 'Selecciona una actividad',
            onChanged: (int? v) => setState(() => _idActividad = v),
          ),

          // AppDateSelector + AppTimeSelector
          const SizedBox(height: 24),
          Text('AppDateSelector', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          AppDateSelector(
            label: 'Fecha de inicio',
            date: _fecha,
            onDateSelected: (DateTime d) => setState(() => _fecha = d),
          ),

          const SizedBox(height: 16),
          Text('AppTimeSelector', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          AppTimeSelector(
            label: 'Hora de inicio',
            time: _time,
            onTimeSelected: (TimeOfDay t) => setState(() => _time = t),
          ),

          // AppChoiceChip
          const SizedBox(height: 24),
          Text('AppChoiceChip – Selección múltiple', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          AppChipWrap(
            children: ActivityCategory.values.map((ActivityCategory cat) => AppChoiceChip(
              label: cat.code,
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

          // DetailSection / DetailRow
          const SizedBox(height: 24),
          Text('DetailSection / DetailRow', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          const DetailSection(
            title: 'Datos de contacto',
            children: [
              DetailRow(Icons.person_outline, 'Nombre', 'Juan García'),
              DetailRow(Icons.email_outlined, 'Email', 'juan@example.com'),
              DetailRow(Icons.phone_outlined, 'Teléfono', '+34 600 123 456'),
            ],
          ),

          // FilterBottomSheetContent
          const SizedBox(height: 24),
          Text('FilterBottomSheetContent', style: tt.titleMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Abrir panel de filtros',
            icon: Icons.filter_list_outlined,
            borderColor: cs.primary,
            backgroundColor: cs.surface,
            onPressed: () {
              final Set<String> sel = {'Pendiente'};
              DateTime? desde;
              DateTime? hasta;
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext ctx) => StatefulBuilder(
                  builder: (BuildContext ctx2, StateSetter setS) => FilterBottomSheetContent(
                    grupos: [
                      FilterGrupo(
                        titulo: 'Estado',
                        chips: [
                          FilterChipSpec(
                            label: 'Pendiente',
                            seleccionado: sel.contains('Pendiente'),
                            onToggle: () => setS(() { sel.contains('Pendiente') ? sel.remove('Pendiente') : sel.add('Pendiente'); }),
                          ),
                          FilterChipSpec(
                            label: 'Confirmada',
                            seleccionado: sel.contains('Confirmada'),
                            onToggle: () => setS(() { sel.contains('Confirmada') ? sel.remove('Confirmada') : sel.add('Confirmada'); }),
                          ),
                          FilterChipSpec(
                            label: 'Cancelada',
                            seleccionado: sel.contains('Cancelada'),
                            onToggle: () => setS(() { sel.contains('Cancelada') ? sel.remove('Cancelada') : sel.add('Cancelada'); }),
                          ),
                        ],
                      ),
                    ],
                    mostrarFechas: true,
                    fechaDesde: desde,
                    fechaHasta: hasta,
                    onFechaDesdeChanged: (DateTime d) => setS(() => desde = d),
                    onFechaHastaChanged: (DateTime d) => setS(() => hasta = d),
                    onFechasClear: () => setS(() { desde = null; hasta = null; }),
                    onLimpiar: () {
                      setS(() { sel.clear(); desde = null; hasta = null; });
                      Navigator.pop(ctx2);
                    },
                    onApply: () => Navigator.pop(ctx2),
                  ),
                ),
              );
            },
          ),

        ],
      ),
    );
  }
}

