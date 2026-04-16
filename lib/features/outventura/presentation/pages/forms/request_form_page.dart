import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_date_selector.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/core/widgets/app_user_dropdown.dart';
import 'package:outventura/features/auth/data/fakes/usuarios_fake.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/controllers/request_form_controller.dart';

class SolicitudFormPage extends StatefulWidget {
  final Solicitud? solicitud;

  const SolicitudFormPage({super.key, this.solicitud});

  @override
  State<SolicitudFormPage> createState() => _SolicitudFormPageState();
}

class _SolicitudFormPageState extends State<SolicitudFormPage> {
  late final SolicitudFormController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = SolicitudFormController();
    if (widget.solicitud != null) {
      _ctrl.cargarRequest(widget.solicitud!);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_ctrl.submit()) return;

    final updated = Solicitud(
      id: _ctrl.selected?.id ?? widget.solicitud?.id ?? 0,
      puntoInicio: _ctrl.puntoInicioCtrl.text.trim(),
      puntoFin: _ctrl.puntoFinCtrl.text.trim(),
      fechaInicio: _ctrl.fechaInicio,
      fechaFin: _ctrl.fechaFin,
      categorias: List.from(_ctrl.categorias),
      numeroParticipantes: int.tryParse(_ctrl.participantesCtrl.text) ?? 1,
      descripcion: _ctrl.descripcionCtrl.text.trim().isEmpty ? null : _ctrl.descripcionCtrl.text.trim(),
      estado: _ctrl.estado,
      idExperto: _ctrl.idExperto,
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isEdit = _ctrl.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar solicitud' : 'Nueva solicitud'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.inverseSurface, cs.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Form(
        key: _ctrl.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Ruta
            CustomInputField(
              controller: _ctrl.puntoInicioCtrl,
              labelText: 'Punto de inicio',
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Campo obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            CustomInputField(
              controller: _ctrl.puntoFinCtrl,
              labelText: 'Punto de fin',
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Campo obligatorio';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),
            // Fechas
            Text('Fechas', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppDateSelector(
                    label: 'Inicio',
                    date: _ctrl.fechaInicio,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    onDateSelected: (picked) => setState(() => _ctrl.setDate(isStart: true, value: picked)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppDateSelector(
                    label: 'Fin',
                    date: _ctrl.fechaFin,
                    firstDate: _ctrl.fechaInicio,
                    lastDate: DateTime(2100),
                    onDateSelected: (picked) => setState(() => _ctrl.setDate(isStart: false, value: picked)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Participantes
            CustomInputField(
              controller: _ctrl.participantesCtrl,
              labelText: 'Número de participantes',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Campo obligatorio';
                }
                if (int.tryParse(v) == null || int.parse(v) < 1) {
                  return 'Debe ser un número mayor que 0';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),
            // Categorías
            Text('Categorías', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            AppChipWrap(
              children: CategoriaActividad.values.map((cat) {
                final isSelected = _ctrl.categorias.contains(cat);
                return AppChoiceChip(
                  label: cat.nombre,
                  selected: isSelected,
                  onSelected: (_) => setState(() => _ctrl.toggleCategoria(cat)),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            // Estado
            Text('Estado', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            AppChipWrap(
              children: EstadoSolicitud.values.map((est) {
                final selected = _ctrl.estado == est;
                return AppChoiceChip(
                  label: est.nombre,
                  selected: selected,
                  onSelected: (_) => setState(() => _ctrl.estado = est),
                  selectedColor: cs.secondaryContainer,
                  selectedBorderColor: cs.tertiary,
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            // Experto
            AppUserDropdown(
              value: _ctrl.idExperto,
              users: usuariosFake,
              onChanged: (val) => setState(() => _ctrl.idExperto = val),
            ),

            const SizedBox(height: 20),
            // Descripción
            CustomInputField(
              controller: _ctrl.descripcionCtrl,
              labelText: 'Descripción (opcional)',
              maxLines: null,
              minLines: 3,
            ),

            const SizedBox(height: 28),
            // Guardar
            PrimaryButton(
              label: isEdit ? 'Guardar cambios' : 'Crear solicitud',
              onPressed: _guardar,
            ),
          ],
        ),
      ),
    );
  }
}
