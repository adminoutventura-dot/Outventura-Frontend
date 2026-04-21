import 'package:flutter/material.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_date_selector.dart';
import 'package:outventura/core/widgets/app_image_picker_field.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/presentation/controllers/excursion_form_controller.dart';

class ExcursionFormPage extends StatefulWidget {
  final Excursion? excursion;

  const ExcursionFormPage({super.key, this.excursion});

  @override
  State<ExcursionFormPage> createState() => _ExcursionFormPageState();
}

class _ExcursionFormPageState extends State<ExcursionFormPage> {
  late final ExcursionFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExcursionFormController();
    if (widget.excursion != null) {
      _controller.cargarExcursion(widget.excursion!);
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

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.inverseSurface,
        foregroundColor: cs.onInverseSurface,
        title: Text(
          _controller.editando ? 'Editar excursión' : 'Nueva excursión',
          style: tt.titleMedium?.copyWith(color: cs.onInverseSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              AppImagePickerField(
                imageUrl: _controller.imagenAsset,
                isAsset: true,
                placeholder: Icons.hiking_outlined,
              ),
              const SizedBox(height: 20),
              Text(
                'Excursión',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              // Puntos inicio / fin
              CustomInputField(
                controller: _controller.puntoInicioController,
                labelText: 'Punto de inicio',
                prefixIcon: Icons.place_outlined,
                validator: ValidadoresFormulario.campoObligatorio,
              ),
              const SizedBox(height: 14),
              CustomInputField(
                controller: _controller.puntoFinController,
                labelText: 'Punto de llegada',
                prefixIcon: Icons.flag_outlined,
                validator: ValidadoresFormulario.campoObligatorio,
              ),
              const SizedBox(height: 14),

              // Descripción
              CustomInputField(
                controller: _controller.descripcionController,
                labelText: 'Descripción (opcional)',
                prefixIcon: Icons.notes_outlined,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),

              // Fechas
              Text(
                'Fechas',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppDateSelector(
                      label: 'Inicio',
                      date: _controller.fechaInicio,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      onDateSelected: (DateTime picked) => setState(() => _controller.establecerFecha(isStart: true, value: picked)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppDateSelector(
                      label: 'Fin',
                      date: _controller.fechaFin,
                      firstDate: _controller.fechaInicio,
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      // TODO: Explicar que hace esto.
                      onDateSelected: (DateTime picked) => setState(() => _controller.establecerFecha(isStart: false, value: picked)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Participantes
              CustomInputField(
                controller: _controller.participantesController,
                labelText: 'Nº máximo de participantes',
                prefixIcon: Icons.group_outlined,
                keyboardType: TextInputType.number,
                validator: ValidadoresFormulario.enteroMayorQueCero,
              ),
              const SizedBox(height: 20),

              // Categorías
              Text(
                'Categorías',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              AppChipWrap(
                children: CategoriaActividad.values.map((CategoriaActividad cat) {
                  final bool seleccionado = _controller.categorias.contains(cat);
                  return AppFilterChip(
                    label: cat.label,
                    seleccionado: seleccionado,
                    // TODO: Explicar que hace esto.
                    onSelected: (_) => setState(() => _controller.alternarCategoria(cat)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Estado
              Text(
                'Estado',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              AppChipWrap(
                children: EstadoExcursion.values.map((EstadoExcursion est) {
                  final bool seleccionado = _controller.estado == est;
                  return AppChoiceChip(
                    label: est.label,
                    seleccionado: seleccionado,
                    onSelected: (_) => setState(() => _controller.estado = est),
                    selectedColor: cs.secondaryContainer,
                    selectedBorderColor: cs.tertiary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.of(context).pop(),
                      backgroundColor: cs.onError,
                      borderColor: cs.error,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: _controller.editando ? 'Guardar' : 'Crear',
                      onPressed: () {
                        if (!_controller.validar()) {
                          return;
                        }
                        // TODO: enviar datos al repositorio
                        Navigator.of(context).pop();
                      },
                      icon: _controller.editando ? Icons.save_outlined : Icons.add,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
