import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/material.dart' as mat;
import 'package:outventura/features/outventura/presentation/controllers/material_form_controller.dart';

class MaterialFormPage extends StatefulWidget {
  /// Si se pasa un material el formulario pasa a edición.
  final mat.Material? material;

  const MaterialFormPage({super.key, this.material});

  @override
  State<MaterialFormPage> createState() => _MaterialFormPageState();
}

class _MaterialFormPageState extends State<MaterialFormPage> {
  late final MaterialFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MaterialFormController()..initialize(widget.material);
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
          _controller.isEditing ? 'Editar material' : 'Nuevo material',
          style: tt.titleMedium?.copyWith(color: cs.onInverseSurface),
        ),
      ),

      // SingleChildScrollView permite que un solo hijo sea scrollable. 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categoría
              Text(
                'Material',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              // Nombre 
              CustomInputField(
                controller: _controller.nombreController,
                labelText: 'Nombre',
                prefixIcon: Icons.inventory_2_outlined,
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

              // Categoría
              Text(
                'Categoría',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CategoriaActividad.values.map((cat) {
                  final selected = _controller.categoria == cat;
                  return ChoiceChip(
                    label: Text(cat.nombre),
                    selected: selected,
                    onSelected: (_) => setState(() => _controller.categoria = cat),
                    selectedColor: cs.primaryContainer,
                    backgroundColor: cs.onPrimary,
                    labelStyle: tt.labelMedium?.copyWith(
                      color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
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
                children: mat.EstadoMaterial.values.map((est) {
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
              const SizedBox(height: 20),

              // Stock
              CustomInputField(
                controller: _controller.stockController,
                labelText: 'Stock (unidades)',
                prefixIcon: Icons.format_list_numbered,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Introduce un número válido';
                  }
                  final numero = int.tryParse(v);
                  if (numero == null || numero < 0) {
                    return 'Introduce un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),


              // Tarifas
              Text(
                'Tarifas',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),

              // Precios
              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      controller: _controller.precioController,
                      labelText: 'Precio/día (€)',
                      prefixIcon: Icons.euro_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        // Si el campo está vacío o no es un número válido muestra error
                        if (v == null || v.isEmpty) {
                          return 'Valor inválido';
                        }
                        final numero = double.tryParse(v);
                        if (numero == null || numero < 0) {
                          return 'Valor inválido';
                        }
                        // Si todo está bien, no hay error
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomInputField(
                      controller: _controller.tarifaController,
                      labelText: 'Tarifa daños (€)',
                      prefixIcon: Icons.warning_amber_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Valor inválido';
                        }
                        final numero = double.tryParse(v);
                        if (numero == null || numero < 0) {
                          return 'Valor inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
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
