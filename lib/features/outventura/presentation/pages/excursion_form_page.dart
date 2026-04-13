import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
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
    _controller = ExcursionFormController()..initialize(widget.excursion);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _controller.fechaInicio : _controller.fechaFin;
    final first = isStart ? DateTime.now() : _controller.fechaInicio;
    final picked  = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      _controller.setDate(isStart: isStart, value: picked);
    });
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
                    child: _DateSelector(
                      label: 'Inicio',
                      date: _controller.fechaInicio,
                      formatted: _controller.formatDate(_controller.fechaInicio),
                      cs: cs,
                      tt: tt,
                      onTap: () => _pickDate(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateSelector(
                      label: 'Fin',
                      date: _controller.fechaFin,
                      formatted: _controller.formatDate(_controller.fechaFin),
                      cs: cs,
                      tt: tt,
                      onTap: () => _pickDate(isStart: false),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CategoriaActividad.values.map((cat) {
                  final selected = _controller.categorias.contains(cat);
                  return FilterChip(
                    label: Text(cat.nombre),
                    selected: selected,
                    onSelected: (_) => setState(() => _controller.toggleCategoria(cat)),
                    selectedColor: cs.primaryContainer,
                    backgroundColor: cs.onPrimary,
                    labelStyle: tt.labelMedium?.copyWith(
                      color: selected
                          ? cs.onPrimaryContainer
                          : cs.onSurfaceVariant,
                    ),
                    side: BorderSide(
                      color: selected ? cs.primary : cs.onSurfaceVariant,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: EstadoExcursion.values.map((est) {
                  final selected = _controller.estado == est;
                  return ChoiceChip(
                    label: Text(est.nombre),
                    selected: selected,
                    onSelected: (_) => setState(() => _controller.estado = est),
                    selectedColor: cs.secondaryContainer,
                    backgroundColor: cs.onPrimary,
                    labelStyle: tt.labelMedium?.copyWith(
                      color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                    ),
                    side: BorderSide(
                      color: selected ? cs.tertiary : cs.onSurfaceVariant,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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

// ── Widget interno selector de fecha ─────────────────────────────

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime date;
  final String formatted;
  final ColorScheme cs;
  final TextTheme tt;
  final VoidCallback onTap;

  const _DateSelector({
    required this.label,
    required this.date,
    required this.formatted,
    required this.cs,
    required this.tt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.onSurfaceVariant.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: cs.primary.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                Text(
                  formatted,
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
