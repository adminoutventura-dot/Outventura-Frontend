import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_image_picker_field.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/l10n/app_localizations.dart';
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
    final AppLocalizations s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(_controller.editando ? s.editEquipment : s.newEquipment),
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
                s.equipmentSection,
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              // Nombre 
              CustomInputField(
                controller: _controller.nombreController,
                labelText: s.name,
                prefixIcon: Icons.inventory_2_outlined,
                validator: ValidadoresFormulario.campoObligatorio(s),
              ),
              const SizedBox(height: 14),

              // Descripción
              CustomInputField(
                controller: _controller.descripcionController,
                labelText: s.description,
                prefixIcon: Icons.notes_outlined,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),

              // Categorías
              Text(
                s.categories,
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              AppFilterChipFormField(
                seleccionados: _controller.categorias,
                onToggle: (CategoriaActividad cat) {
                  setState(() => _controller.alternarCategoria(cat));
                },
                validator: (List<CategoriaActividad>? v) {
                  return ValidadoresFormulario.listaRequerida(v, s.selectCategory);
                },
              ),
              const SizedBox(height: 20),

              // Estado
              Text(
                s.status,
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              AppChipWrap(
                children: EstadoEquipamiento.values.map((EstadoEquipamiento est) {
                  final bool seleccionado = _controller.estado == est;
                  return AppChoiceChip(
                    label: est.localizedLabel(s),
                    seleccionado: seleccionado,
                    onSelected: (_) {
                      setState(() => _controller.estado = est);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),


              // Stock
              Text(
                s.stockSection,
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 4),

              // Stock disponible y total
              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      controller: _controller.stockController,
                      labelText: s.availableStock,
                      prefixIcon: Icons.format_list_numbered,
                      keyboardType: TextInputType.number,
                      validator: ValidadoresFormulario.enteroPositivo(s),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomInputField(
                      controller: _controller.stockTotalController,
                      labelText: s.totalStock,
                      prefixIcon: Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
                      validator: ValidadoresFormulario.enteroPositivo(s),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Tarifas
              Text(
                s.rates,
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 4),

              // Precios
              Row(
                children: [
                  Expanded(
                    child: CustomInputField(
                      controller: _controller.precioController,
                      labelText: s.pricePerDay,
                      prefixIcon: Icons.euro_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: ValidadoresFormulario.decimalPositivo(s),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomInputField(
                      controller: _controller.tarifaController,
                      labelText: s.damageFee,
                      prefixIcon: Icons.warning_amber_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: ValidadoresFormulario.decimalPositivo(s),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Botón Guardar / Crear
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _controller.editando ? s.save : s.create,
                  onPressed: () {
                    final Equipamiento? equipamiento = _controller.crearEquipamiento();
                    if (equipamiento == null) {
                      return;
                    }
                    // Cierra la página y devuelve el nuevo equipamiento a la página anterior
                    Navigator.of(context).pop(equipamiento);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
