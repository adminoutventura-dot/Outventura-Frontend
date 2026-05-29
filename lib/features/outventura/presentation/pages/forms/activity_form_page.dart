import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_date_selector.dart';
import 'package:outventura/core/widgets/app_time_selector.dart';
import 'package:outventura/core/widgets/app_image_picker_field.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/controllers/activity_form_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_line_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_line_dialog.dart';

class ActivityFormPage extends ConsumerStatefulWidget {
  final Activity? actividad;

  const ActivityFormPage({super.key, this.actividad});

  @override
  ConsumerState<ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends ConsumerState<ActivityFormPage> {
  late final ActivityFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ActivityFormController();
    if (widget.actividad != null) {
      _controller.cargarActividad(widget.actividad!);
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
    final AppLocalizations s = AppLocalizations.of(context)!;
    final List<Equipment> equipamientos =
        ref.watch(equipmentProvider).value ?? [];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: CustomAppBar(
        title: _controller.editando ? s.editActividad : s.nuevaActividad,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen selector
              AppImagePickerField(
                imageUrl: _controller.imagenAsset,
                isAsset: true,
                placeholder: Icons.hiking_outlined,
                onChanged: (String? nuevaRuta) {
                  setState(() {
                    _controller.imagenAsset = nuevaRuta;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Datos descriptivos de la actividad
              Text(
                s.actividadSection.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),

              // Título
              CustomInputField(
                controller: _controller.tituloController,
                labelText:
                    "s.title", // Arreglado el literal string que causaba problemas
                prefixIcon: Icons.title,
                validator: ValidadoresFormulario.campoObligatorio(s),
              ),
              const SizedBox(height: 14),

              // Punto de encuentro o ruta fusionada
              CustomInputField(
                controller: _controller.puntoInicioFinController,
                labelText: s.startPoint,
                prefixIcon: Icons.place_outlined,
              ),
              const SizedBox(height: 14),

              // Detalles descriptivos adicionales
              CustomInputField(
                controller: _controller.descripcionController,
                labelText: s.descriptionOptional,
                prefixIcon: Icons.notes_outlined,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),

              // Gestión de fechas de realización
              Text(
                s.datesSection.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Selector de inicio
                  Expanded(
                    child: AppDateSelector(
                      label: s.start,
                      date: _controller.fechaInicio,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 2),
                      ),
                      onDateSelected: (DateTime picked) {
                        setState(
                          () => _controller.establecerFecha(
                            isStart: true,
                            value: picked,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Selector de finalización
                  Expanded(
                    child: AppDateSelector(
                      label: s.end,
                      date: _controller.fechaFin,
                      firstDate: _controller.fechaInicio,
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 2),
                      ),
                      onDateSelected: (DateTime picked) {
                        setState(
                          () => _controller.establecerFecha(
                            isStart: false,
                            value: picked,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Gestión de franjas horarias
              Row(
                children: [
                  // Hora de salida
                  Expanded(
                    child: AppTimeSelector(
                      label: s.startTime,
                      time: _controller.horaInicio,
                      onTimeSelected: (TimeOfDay picked) {
                        setState(() => _controller.horaInicio = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Hora de regreso
                  Expanded(
                    child: AppTimeSelector(
                      label: s.endTime,
                      time: _controller.horaFin,
                      onTimeSelected: (TimeOfDay picked) {
                        setState(() => _controller.horaFin = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Aforo de la excursión
              CustomInputField(
                controller: _controller.participantesController,
                labelText: s.maxParticipants,
                prefixIcon: Icons.group_outlined,
                keyboardType: TextInputType.number,
                validator: ValidadoresFormulario.enteroMayorQueCero(s),
              ),
              const SizedBox(height: 20),

              // Categorías temáticas asociadas
              Text(
                s.categories.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),

              // Despliega chips de selección múltiple
              AppFilterChipFormField(
                seleccionados: _controller.categorias,
                onToggle: (Category cat) {
                  setState(() => _controller.alternarCategoria(cat));
                },
                validator: (List<Category>? v) {
                  return ValidadoresFormulario.listaRequerida(
                    v,
                    s.selectCategory,
                  );
                },
              ),
              const SizedBox(height: 32),

              // Sección de inventario recomendado para el trayecto
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.recommendedMaterial.toUpperCase(),
                    style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  TertiaryButton(
                    label: s.addLine,
                    icon: Icons.add,
                    onPressed: () async {
                      final result = await mostrarDialogoLineaReserva(
                        context: context,
                        equipamientos: equipamientos,
                        validateStock: false,
                      );
                      if (result == null) return;
                      setState(() {
                        // Forzamos aserción porque en este formulario el diálogo sólo devuelve materiales con ID válido
                        _controller.materialesRecomendados[result
                                .equipmentId!] =
                            (_controller.materialesRecomendados[result
                                    .equipmentId!] ??
                                0) +
                            result.quantity;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Renderiza el desglose de materiales inyectados a la plantilla
              if (_controller.materialesRecomendados.isNotEmpty)
                ..._controller.materialesRecomendados.entries.map((entry) {
                  final int idEquip = entry.key;
                  final int cantidad = entry.value;
                  Equipment? equip;
                  try {
                    equip = equipamientos.firstWhere((e) => e.id == idEquip);
                  } catch (_) {}
                  if (equip == null) return const SizedBox.shrink();

                  return ReservationLineCard(
                    linea: BookingLine(
                      equipmentId: idEquip,
                      quantity: cantidad,
                    ),
                    equipamiento: equip,
                    cantidadDaniada: 0,
                    esCliente: true,
                    onEdit: () async {
                      final result = await mostrarDialogoLineaReserva(
                        context: context,
                        equipamientos: equipamientos,
                        initialLinea: BookingLine(
                          equipmentId: idEquip,
                          quantity: cantidad,
                        ),
                        validateStock: false,
                      );
                      if (result == null) return;
                      setState(() {
                        _controller.materialesRecomendados.remove(idEquip);
                        // Forzamos aserción para registrar de forma segura el stock modificado
                        _controller.materialesRecomendados[result
                                .equipmentId!] =
                            result.quantity;
                      });
                    },
                    onDelete: () => setState(
                      () => _controller.materialesRecomendados.remove(idEquip),
                    ),
                  );
                }),

              const SizedBox(height: 32),

              // Botón de confirmación e inserción general
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _controller.editando ? s.save : s.create,
                  onPressed: () {
                    if (!_controller.validar()) {
                      return;
                    }
                    final Activity actividad = _controller.construirActividad();
                    Navigator.of(context).pop(actividad);
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
