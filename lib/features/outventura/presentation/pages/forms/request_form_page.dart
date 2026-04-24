import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_dropdown_field.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/controllers/request_form_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';

class SolicitudFormPage extends ConsumerStatefulWidget {

  final Solicitud? solicitud;

  const SolicitudFormPage({super.key, this.solicitud});

  @override
  ConsumerState<SolicitudFormPage> createState() => _SolicitudFormPageState();
}

class _SolicitudFormPageState extends ConsumerState<SolicitudFormPage> {
  late final SolicitudFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SolicitudFormController();
    if (widget.solicitud != null) {
      _controller.cargarSolicitud(widget.solicitud!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final bool isEdit = _controller.editando;

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
        key: _controller.formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 24),
          children: [
            // Usuario (cliente)
            AppDropdownField<Usuario>(
              value: _controller.idUsuario,
              items: ref.read(usuariosProvider),
              itemValue: (Usuario user) => user.id,
              itemLabel: (Usuario user) => '${user.nombre} ${user.apellidos}',
              prefixIcon: Icons.person_outlined,
              label: 'Cliente',
              hint: 'Selecciona un cliente',
              onChanged: (int? val) => setState(() => _controller.idUsuario = val),
            ),

            const SizedBox(height: 20),
            // Excursión
            AppDropdownField<Excursion>(
              value: _controller.idExcursion,
              items: ref.read(excursionesProvider),
              itemValue: (e) => e.id,
              itemLabel: (e) => '${e.puntoInicio} → ${e.puntoFin}',
              prefixIcon: Icons.hiking_outlined,
              label: 'Excursión',
              hint: 'Selecciona una excursión',
              isRequired: true,
              onChanged: (int? v) {
                setState(() => _controller.idExcursion = v);
              },
            ),

            const SizedBox(height: 20),
            // Participantes
            CustomInputField(
              controller: _controller.participantesCtrl,
              labelText: 'Número de participantes',
              keyboardType: TextInputType.number,
              validator: ValidadoresFormulario.enteroMayorQueCero,
            ),

            const SizedBox(height: 20),
            // Estado
            Text('Estado', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            AppChipWrap(
              children: EstadoSolicitud.values.map((EstadoSolicitud est) {
                final bool seleccionado = _controller.estado == est;
                return AppChoiceChip(
                  label: est.label,
                  seleccionado: seleccionado,
                  onSelected: (_) => setState(() => _controller.estado = est),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            // Experto
            AppDropdownField<Usuario>(
              value: _controller.idExperto,
              items: ref.read(usuariosProvider),
              itemValue: (Usuario user) => user.id,
              itemLabel: (Usuario user) => '${user.nombre} ${user.apellidos}',
              prefixIcon: Icons.person_outline,
              label: 'Experto',
              hint: 'Selecciona un experto',
              onChanged: (int? val) => setState(() => _controller.idExperto = val),
            ),

            const SizedBox(height: 28),
            // Guardar
            PrimaryButton(
              label: isEdit ? 'Guardar' : 'Crear',
              onPressed: () {
                final Solicitud? solicitud = _controller.crearSolicitud();
                if (solicitud == null) {
                  return;
                }
                // Cierra la página y devuelve el nuevo equipamiento a la página anterior
                Navigator.of(context).pop(solicitud);
              },
            ),
          ],
        ),
      ),
    );
  }
}
