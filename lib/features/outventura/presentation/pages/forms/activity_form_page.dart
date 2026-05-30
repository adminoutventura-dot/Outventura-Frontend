import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/widgets/app_dropdown_field.dart';
import 'package:outventura/features/outventura/presentation/widgets/equipment_search_modal.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_date_selector.dart';
import 'package:outventura/core/widgets/app_time_selector.dart';
import 'package:outventura/core/widgets/app_image_picker_field.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/presentation/controllers/activity_form_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';

// 🌟 IMPORTAMOS EL MODELO GUIDE Y SU PROVEEDOR (Verifica si la ruta es exacta)
import 'package:outventura/features/auth/domain/entities/guide.dart';
import 'package:outventura/features/auth/presentation/providers/guides_provider.dart';

class ActivityFormPage extends ConsumerStatefulWidget {
  final Activity? actividad;

  const ActivityFormPage({super.key, this.actividad});

  @override
  ConsumerState<ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends ConsumerState<ActivityFormPage> {
  late final ActivityFormController _controller;

  // Variable local para gestionar el mensaje de error debajo del selector
  String? _errorTiempo;

  @override
  void initState() {
    super.initState();
    _controller = ActivityFormController();
    if (widget.actividad != null) {
      _controller.cargarActividad(widget.actividad!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final usuarioLogueado = ref.read(currentUserProvider);
        if (usuarioLogueado?.role.code == 'GUIDE') {
          setState(() {
            final dynamic user = usuarioLogueado;
            _controller.guideId = user.id_guide ?? user.guideId;
          });
        }
      });
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

    final usuarioActual = ref.watch(currentUserProvider);
    final bool isGuide = usuarioActual?.role.code == 'GUIDE';

    final List<Equipment> equipamientos = ref.watch(equipmentProvider).value ?? [];
    
    // 🌟 LEEMOS LA LISTA TIPADA DESDE EL BACKEND
    final AsyncValue<List<Guide>> guidesAsync = ref.watch(guidesProvider);
    final List<Guide> todosLosGuias = guidesAsync.value ?? [];

    // 🌟 FILTRAMOS GUÍAS ACTIVOS (Aquí desaparecen los inactivos como Carlos)
    final List<Guide> guiasActivos = todosLosGuias.where((g) => g.user?.active == true).toList();

    // 🌟 INYECCIÓN HISTÓRICA: Si el guía original ya está inactivo, lo inyectamos igual para no romper la vista al editar
    final List<Guide> itemsDropdownGuias = [...guiasActivos];
    if (_controller.editando && _controller.guideId != null) {
      final Guide? guiaSeleccionado = todosLosGuias.where((g) => g.id == _controller.guideId).firstOrNull;
      if (guiaSeleccionado != null && !itemsDropdownGuias.any((g) => g.id == guiaSeleccionado.id)) {
        itemsDropdownGuias.add(guiaSeleccionado);
      }
    }

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

              Text(
                s.actividadSection.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),

              CustomInputField(
                controller: _controller.tituloController,
                labelText: "s.title", // TODO: hardcodeado
                prefixIcon: Icons.title,
                validator: ValidadoresFormulario.campoObligatorio(s),
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.puntoInicioFinController,
                labelText: s.startPoint,
                prefixIcon: Icons.place_outlined,
              ),
              const SizedBox(height: 14),

              CustomInputField(
                controller: _controller.descripcionController,
                labelText: s.descriptionOptional,
                prefixIcon: Icons.notes_outlined,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 14),

              if (!isGuide) ...[
                // 🌟 DROPDOWN LIMPIO Y SEGURO TIPADO A <Guide>
                AppDropdownField<Guide>(
                // 🌟 DROPDOWN LIMPIO Y SEGURO TIPADO A <Guide>
                AppDropdownField<Guide>(
                  value: _controller.guideId,
                  items: itemsDropdownGuias,
                  itemValue: (Guide guia) => guia.id!,
                  itemLabel: (Guide guia) => '${guia.user?.name} ${guia.user?.surname}',
                  prefixIcon: Icons.person_outline,
                  label: 'Guía Asignado', // TODO: hardcodeado
                  hint: 'Selecciona un guía obligatorio', // TODO: hardcodeado
                  onChanged: (dynamic nuevoId) {
                    setState(() {
                      _controller.guideId = nuevoId as int?;
                    });
                  },
                  validator: (dynamic value) => value == null
                  validator: (dynamic value) => value == null
                      ? 'Por favor, selecciona un guía obligatorio' // TODO: hardcodeado
                      : null,
                ),
                const SizedBox(height: 20),
              ],

              Text(
                s.datesSection.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppDateSelector(
                      label: s.start,
                      date: _controller.fechaInicio,
                      firstDate:
                          _controller.editando &&
                              _controller.fechaInicio.isBefore(DateTime.now())
                          ? DateTime(
                              _controller.fechaInicio.year,
                              _controller.fechaInicio.month,
                              _controller.fechaInicio.day,
                            )
                          : DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 2),
                      ),
                      onDateSelected: (DateTime picked) {
                        setState(() {
                          _controller.establecerFecha(
                            isStart: true,
                            value: picked,
                          );
                          _errorTiempo =
                              null; // Limpia el error al cambiar datos
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppDateSelector(
                      label: s.end,
                      date: _controller.fechaFin,
                      firstDate: _controller.fechaInicio,
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 2),
                      ),
                      onDateSelected: (DateTime picked) {
                        setState(() {
                          _controller.establecerFecha(
                            isStart: false,
                            value: picked,
                          );
                          _errorTiempo =
                              null; // Limpia el error al cambiar datos
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: AppTimeSelector(
                      label: s.startTime,
                      time: _controller.horaInicio,
                      onTimeSelected: (TimeOfDay picked) {
                        setState(() {
                          _controller.horaInicio = picked;
                          _errorTiempo = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTimeSelector(
                      label: s.endTime,
                      time: _controller.horaFin,
                      onTimeSelected: (TimeOfDay picked) {
                        setState(() {
                          _controller.horaFin = picked;
                          _errorTiempo = null;
                        });
                      },
                    ),
                  ),
                ],
              ),

              if (_errorTiempo != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 14),
                  child: Text(
                    _errorTiempo!,
                    style: tt.bodySmall?.copyWith(
                      color: cs.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              CustomInputField(
                controller: _controller.participantesController,
                labelText: s.maxParticipants,
                prefixIcon: Icons.group_outlined,
                keyboardType: TextInputType.number,
                validator: ValidadoresFormulario.enteroMayorQueCero(s),
              ),
              const SizedBox(height: 20),

              Text(
                s.categories.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),

              AppFilterChipFormField(
                seleccionados: _controller.categories,
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
                      final Map<int, int>? resultadoModal =
                          await showEquipmentSearchModal(
                            context: context,
                            equipments: equipamientos,
                            initialSelected: _controller.materialesRecomendados,
                          );

                      if (resultadoModal != null) {
                        setState(() {
                          _controller.materialesRecomendados = resultadoModal;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_controller.materialesRecomendados.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: cs.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'No hay material recomendado seleccionado', // TODO: hardcodeado
                        style: tt.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _controller.materialesRecomendados.keys.map((
                    idEquip,
                  ) {
                    final Equipment? item = equipamientos
                        .where((e) => e.id == idEquip)
                        .firstOrNull;
                    if (item == null) return const SizedBox.shrink();

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.title,
                            style: tt.labelMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() {
                              _controller.materialesRecomendados.remove(
                                idEquip,
                              );
                            }),
                            child: Icon(
                              Icons.cancel_rounded,
                              size: 16,
                              color: cs.error.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _controller.editando ? s.save : s.create,
                  onPressed: () {
                    if (!_controller.validar()) {
                      return;
                    }

                    // Fusión cronológica estricta (Fecha + Hora)
                    final DateTime inicioCompleto = DateTime(
                      _controller.fechaInicio.year,
                      _controller.fechaInicio.month,
                      _controller.fechaInicio.day,
                      _controller.horaInicio.hour,
                      _controller.horaInicio.minute,
                    );

                    final DateTime finCompleto = DateTime(
                      _controller.fechaFin.year,
                      _controller.fechaFin.month,
                      _controller.fechaFin.day,
                      _controller.horaFin.hour,
                      _controller.horaFin.minute,
                    );

                    if (finCompleto.isBefore(inicioCompleto)) {
                      setState(() {
                        _errorTiempo =
                            'La hora de fin no puede ser anterior a la de inicio'; // TODO: hardcodeado
                      });
                      return;
                    }

                    setState(() => _errorTiempo = null);

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
