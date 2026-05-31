import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:outventura/core/widgets/app_bar_forms.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_image_picker_field.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/presentation/controllers/equipment_form_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart'; 

final guidesProvider = FutureProvider<List<dynamic>>((ref) async {
  // Nota: Este provider venía del form anterior por si hiciese falta.
  return [];
});

class EquipmentFormPage extends ConsumerStatefulWidget { 
  final Equipment? equipamiento;

  const EquipmentFormPage({super.key, this.equipamiento});

  @override
  ConsumerState<EquipmentFormPage> createState() => _EquipmentFormPageState();
}

class _EquipmentFormPageState extends ConsumerState<EquipmentFormPage> {
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

    // Obtiene la lista de estados dinámicos de la base de datos
    final listaEstados = ref.watch(equipmentStatusesProvider).value ?? [];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: CustomAppBarForm(title: _controller.editando ? s.editEquipment : s.newEquipment),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 24),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: AppImagePickerField(
                  imageUrl: _controller.imagenAsset,
                  isAsset: true,  
                  size: 120,                
                  placeholder: Icons.inventory_2_outlined,
                  onChanged: (String? nuevaRuta) {
                    setState(() {
                      _controller.imagenAsset = nuevaRuta;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                s.equipmentSection.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              CustomInputField(
                controller: _controller.nombreController,
                labelText: s.name,
                prefixIcon: Icons.inventory_2_outlined,
                validator: ValidadoresFormulario.campoObligatorio(s),
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.descripcionController,
                labelText: s.description,
                prefixIcon: Icons.notes_outlined,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),

              Text(
                s.categories.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),

              AppFilterChipFormField(
                seleccionados: _controller.categorias,
                onToggle: (Category cat) {
                  setState(() => _controller.alternarCategoria(cat));
                },
                validator: (List<Category>? v) {
                  return ValidadoresFormulario.listaRequerida(v, s.selectCategory);
                },
              ),
              const SizedBox(height: 20),

              Text(
                s.status.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              
              AppChipWrap(
                children: listaEstados.map((dynamic est) {
                  final int? idEstado = est['id_status'] as int?; // Cambiado 'id' por 'id_status'
                  final String codeEstado = (est['code'] ?? '') as String; // Cambiado 'name' por 'code'
                  
                  String labelTraducido = codeEstado;
                  if (codeEstado == 'AVAILABLE') labelTraducido = s.statusAvailable;
                  if (codeEstado == 'OUT_OF_STOCK') labelTraducido = s.statusOutOfStock;
                  if (codeEstado == 'MAINTENANCE') labelTraducido = s.statusMaintenance;
                  if (codeEstado == 'OUT_OF_SERVICE') labelTraducido = s.statusOutOfService;
                  if (codeEstado == 'DISCONTINUED') labelTraducido = s.discontinued;

                  final bool seleccionado = _controller.statusId == idEstado;
                  
                  return AppChoiceChip(
                    label: labelTraducido,
                    seleccionado: seleccionado,
                    onPressed: () {
                      if (idEstado != null) {
                        setState(() => _controller.statusId = idEstado);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              Text(
                s.stockSection.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              CustomInputField(
                controller: _controller.stockTotalController,
                labelText: s.totalStock,
                prefixIcon: Icons.inventory_2_outlined,
                keyboardType: TextInputType.number,
                validator: ValidadoresFormulario.enteroPositivo(s),
              ),
              const SizedBox(height: 14),

              Text(
                s.rates.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 4),

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

              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _controller.editando ? s.save : s.create,
                  onPressed: () {
                    final Equipment? equipamiento = _controller.crearEquipamiento();
                    if (equipamiento == null) return;
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