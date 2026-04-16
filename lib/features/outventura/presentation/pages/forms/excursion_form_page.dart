import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_date_selector.dart';
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.inverseSurface,
        foregroundColor: cs.onInverseSurface,
        title: Text(
          _controller.isEditing ? 'Editar excursión' : 'Nueva excursión',
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
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Campo obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              CustomInputField(
                controller: _controller.puntoFinController,
                labelText: 'Punto de llegada',
                prefixIcon: Icons.flag_outlined,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Campo obligatorio';
                  }
                  return null;
                },
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
                      onDateSelected: (picked) => setState(() => _controller.setDate(isStart: true, value: picked)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppDateSelector(
                      label: 'Fin',
                      date: _controller.fechaFin,
                      firstDate: _controller.fechaInicio,
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      onDateSelected: (picked) => setState(() => _controller.setDate(isStart: false, value: picked)),
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
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Introduce un número válido';
                  }
                  final numero = int.tryParse(v);
                  if (numero == null || numero < 1) {
                    return 'Introduce un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Categorías
              Text(
                'Categorías',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              AppChipWrap(
                children: CategoriaActividad.values.map((cat) {
                  final selected = _controller.categorias.contains(cat);
                  return AppFilterChip(
                    label: cat.nombre,
                    selected: selected,
                    onSelected: (_) => setState(() => _controller.toggleCategoria(cat)),
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
                children: EstadoExcursion.values.map((est) {
                  final selected = _controller.estado == est;
                  return AppChoiceChip(
                    label: est.nombre,
                    selected: selected,
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
                      label: _controller.isEditing ? 'Guardar' : 'Crear',
                      onPressed: () {
                        if (!_controller.submit()) {
                          return;
                        }
                        // TODO: enviar datos al repositorio
                        Navigator.of(context).pop();
                      },
                      icon: _controller.isEditing ? Icons.save_outlined : Icons.add,
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
