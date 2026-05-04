import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_image_picker_field.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/features/outventura/domain/entities/activity_category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/presentation/controllers/equipment_form_controller.dart';

class EquipmentFormPage extends StatefulWidget {
  final Equipamiento? equipamiento;

  const EquipmentFormPage({super.key, this.equipamiento});

  @override
  State<EquipmentFormPage> createState() => _EquipmentFormPageState();
}

class _EquipmentFormPageState extends State<EquipmentFormPage> {
  late final EquipmentFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EquipmentFormController();
    if (widget.equipamiento != null) {
      _controller.cargarEquipo(widget.equipamiento!);
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
        title: Text(_controller.editando ? 'Editar equipamiento' : 'Nuevo equipamiento'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.surfaceContainer, cs.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      // SingleChildScrollView permite que un solo hijo sea scrollable. 
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 24),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              Center(
                child: AppImagePickerField(
                  imageUrl: _controller.imagenAsset,
                  isAsset: true,  
                  size: 120,                
                  placeholder: Icons.inventory_2_outlined,
                ),
              ),
              const SizedBox(height: 20),
              
              // Categoría
              Text(
                'Equipamiento',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              // Nombre 
              CustomInputField(
                controller: _controller.nombreController,
                labelText: 'Nombre',
                prefixIcon: Icons.inventory_2_outlined,
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

              // Categorías
              Text(
                'Categorías',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              AppFilterChipFormField(
                seleccionados: _controller.categorias,
                onToggle: (CategoriaActividad cat) {
                  setState(() => _controller.alternarCategoria(cat));
                },
                validator: (List<CategoriaActividad>? v) {
                  return ValidadoresFormulario.listaRequerida(v, 'Selecciona una ctegoría');
                },
              ),
              const SizedBox(height: 20),

              // Estado
              Text(
                'Estado',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              AppChipWrap(
                children: EstadoEquipamiento.values.map((EstadoEquipamiento est) {
                  final bool seleccionado = _controller.estado == est;
                  return AppChoiceChip(
                    label: est.label,
                    seleccionado: seleccionado,
                    onSelected: (_) {
                      setState(() => _controller.estado = est);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Stock disponible y total
              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      controller: _controller.stockController,
                      labelText: 'Stock disponible',
                      prefixIcon: Icons.format_list_numbered,
                      keyboardType: TextInputType.number,
                      validator: ValidadoresFormulario.enteroPositivo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomInputField(
                      controller: _controller.stockTotalController,
                      labelText: 'Stock total',
                      prefixIcon: Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
                      validator: ValidadoresFormulario.enteroPositivo,
                    ),
                  ),
                ],
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
                      validator: ValidadoresFormulario.decimalPositivo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomInputField(
                      controller: _controller.tarifaController,
                      labelText: 'Tarifa daños (€)',
                      prefixIcon: Icons.warning_amber_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: ValidadoresFormulario.decimalPositivo,
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
                      label: _controller.editando ? 'Guardar' : 'Crear',
                      onPressed: () {
                        final Equipamiento? equipamiento = _controller.crearEquipamiento();
                        if (equipamiento == null) {
                          return;
                        }
                        // Cierra la página y devuelve el nuevo equipamiento a la página anterior
                        Navigator.of(context).pop(equipamiento);
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
