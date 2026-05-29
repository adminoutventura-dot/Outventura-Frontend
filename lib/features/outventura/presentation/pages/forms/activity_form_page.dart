import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart'; // 🌟 Importante para conectar con el BackEnd
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/core/utils/form_validators.dart';
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
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/controllers/activity_form_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_line_card.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_line_dialog.dart';

// 🌟 PROVIDER REAL: Obtiene los guías de la base de datos de forma dinámica
final guidesProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/guide');

  // Si tu backend devuelve la lista envuelta en { data: [...] } la extraemos, si no, la enviamos directa
  if (response.data is Map && response.data['data'] != null) {
    return response.data['data'] as List<dynamic>;
  }
  return response.data as List<dynamic>;
});

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
    } else {
      // Si estamos creando una nueva actividad, comprobamos si el usuario activo es guía
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

    final List<Equipment> equipamientos =
        ref.watch(equipmentProvider).value ?? [];

    // 🌟 LEEMOS LOS GUÍAS REALES DESDE EL PROVIDER ASÍNCRONO
    final AsyncValue<List<dynamic>> guidesAsync = ref.watch(guidesProvider);
    final List<dynamic> listaGuiasReales = guidesAsync.value ?? [];

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
                labelText: "s.title", // TODO: hardcodeado
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
              const SizedBox(height: 14),

              // 🌟 NUEVO: SELECTOR DE GUÍA ASIGNADO REAL DE BASE DE DATOS
              if (!isGuide) ...[
                DropdownButtonFormField<int>(
                  value: _controller.guideId,
                  dropdownColor: cs.surfaceContainerHighest,
                  style: tt.bodyLarge?.copyWith(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Guía Asignado *',
                    prefixIcon: Icon(Icons.person_outline, color: cs.primary),
                    filled: true,
                    fillColor: cs.surfaceVariant.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                  ),
                  // Mapeamos dinámicamente según la estructura relacional de Prisma (id_guide + user)
                  items: listaGuiasReales.map((dynamic guia) {
                    final int idGuide = guia['id_guide'] as int;
                    final Map<String, dynamic> user =
                        guia['user'] as Map<String, dynamic>;
                    final String nombreCompleto =
                        '${user['name']} ${user['surname']}';

                    return DropdownMenuItem<int>(
                      value: idGuide,
                      child: Text(nombreCompleto),
                    );
                  }).toList(),
                  onChanged: (int? nuevoId) {
                    setState(() {
                      _controller.guideId = nuevoId;
                    });
                  },
                  validator: (value) => value == null
                      ? 'Por favor, selecciona un guía obligatorio'
                      : null,
                ),
                const SizedBox(height: 20),
              ],

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

              // Chips de selección múltiple
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

              // Sección de inventario recomendado
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

              // Desglose de materiales recomendados
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

              // Botón de confirmación final
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
