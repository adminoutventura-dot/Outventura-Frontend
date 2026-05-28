import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/core/widgets/app_bar_forms.dart';
import 'package:outventura/core/widgets/bottom_price_bar.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_dropdown_field.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/presentation/controllers/request_form_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/reservation_form_page.dart';

class SolicitudFormPage extends ConsumerStatefulWidget {
  final Request? solicitud;
  final int? initialIdActividad;
  final int? initialIdUsuario;

  const SolicitudFormPage({
    super.key,
    this.solicitud,
    this.initialIdActividad,
    this.initialIdUsuario,
  });

  @override
  ConsumerState<SolicitudFormPage> createState() => _SolicitudFormPageState();
}

class _SolicitudFormPageState extends ConsumerState<SolicitudFormPage> {
  late final RequestFormController _controller;
  bool _mostrarMateriales = false;

  @override
  void initState() {
    super.initState();
    _controller = RequestFormController();

    if (widget.solicitud != null) {
      // MODO EDICIÓN: viene una solicitud existente
      // Carga todos sus campos
      _controller.cargarSolicitud(widget.solicitud!);

      // Sobreescribe el usuario si el formulario se abrió desde el perfil de un cliente específico (modo cliente)
      // Si es admin editando una solicitud existente, no se pasa initialIdUsuario.
      if (widget.initialIdUsuario != null) {
        _controller.idUsuario = widget.initialIdUsuario;
      }

    } else {
      // MODO CREACIÓN: no hay solicitud previa
      _controller.aplicarValoresIniciales(
        idActividad: widget.initialIdActividad,
        idUsuario: widget.initialIdUsuario,
      );
    }

    // Calcular materiales recomendados solo en creación
    if (widget.solicitud == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // comprobación de seguridad por si el widget fue destruido antes de que el frame se pintara.
        if (!mounted) return;

        setState(() => _controller.recalcularMateriales(ref.read(activitiesProvider).value ?? []));
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
    final AppLocalizations s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    // Se pone a true dentro de cargarSolicitud()
    final bool isEdit = _controller.editando;
    final List<Activity> actividades = ref.watch(activitiesProvider).value ?? [];
    final List<Equipment> equipamientos = ref.watch(equipmentProvider).value ?? [];

    // Busca la reserva asociada usando el provider (si hay idReserva).
    final Booking? reservaAsociada = _controller.idReserva != null
        ? ref.watch(reservationByIdProvider(_controller.idReserva!))
        : null;

    // Detecta si la reserva fue eliminada externamente y limpia el estado.
    if (_controller.idReserva != null) {
      ref.listen(reservationByIdProvider(_controller.idReserva!), (prev, next) {
        if (prev != null && next == null && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(s.reservationNotFound)),
            );
            setState(() {
              _controller.idReserva = null;
              _controller.materialesSolicitados.clear();
            });
          });
        }
      });
    }

    final double cargoDanios = reservaAsociada?.damageFee ?? 0;

    final bool modoCliente = widget.initialIdUsuario != null;

    // En modo admin carga clientes desde el backend; en modo cliente usa el usuario actual.
    final List<User> usuariosDisponibles = !modoCliente
      ? ref.watch(clientesProvider).value ?? []
      : switch (ref.watch(currentUserProvider)) {
          final User u => [u],
          null => [],
        };

    // Carga solo actividades disponibles desde el backend
    final List<Activity> actividadesDisponibles = ref.watch(availableActivitiesProvider).value ?? [];

    final Activity? actividadSeleccionada = _controller.buscarActividadSeleccionada(actividades);

    final double totalPrice = _controller.calcularPrecioTotal(actividades, equipamientos);
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    final double bottomBarHeight = MediaQuery.of(context).padding.bottom + 100;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: CustomAppBarForm(title: isEdit ? s.editRequest : s.newRequest),
      bottomNavigationBar: BottomPriceBar(
        totalLabel: s.total,
        price: s.priceEur(totalPrice.toStringAsFixed(2)),
        actionLabel: isEdit ? s.save : s.create,
        onPressed: () async {
          // Validar formulario
          if (_controller.idReserva == null && _controller.tieneMateriales) {
            final Booking? reserva = await _controller.crearEditarReservaDesdeSolicitud(
              context: context,
              ref: ref,
            );
            if (reserva == null) return;
          }

          if (!context.mounted) return;

          // Crear o actualizar solicitud
          final Request? solicitud = _controller.crearEditarSolicitud(actividades, equipamientos);
          if (solicitud == null) {
            // TODO: HARDCODEADO, mejorar mensaje de error según validación que falle
            showErrorSnackBar(context, "s.fillRequiredFields");
            return;
          }

          // Lista de reservas
          final List<Booking> reservasActuales = ref.read(reservationsProvider).value ?? [];
          // Reserva actualizada o creada a partir de la solicitud
          final Booking? reservaActualizada = _controller.sincronizarReservaConSolicitud(solicitud, reservasActuales);
          
          try {
            // Si hay una reserva actualizada o creada, y la solicitud tiene un ID de reserva asociado
            if (reservaActualizada != null && solicitud.bookingId != null) {
              // Buscar la reserva original en la lista de reservas usando el ID de reserva de la solicitud
              final Booking? original = _controller.buscarReserva(reservasActuales, solicitud.bookingId!);
              // Si se encuentra la reserva original, actualizarla en el provider
              if (original != null) {
                await ref.read(reservationsProvider.notifier).actualizar(original, reservaActualizada);
              }
            }

            if (!context.mounted) return;

            // Devolver la solicitud creada o editada a la pantalla anterior
            Navigator.of(context).pop(solicitud);
          } catch (e) {
            if (!context.mounted) return;
            showErrorSnackBar(context, s.error(e.toString()));
          }
        },
      ),

      body: Form(
        key: _controller.formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, topPadding + 40, 20, bottomBarHeight + 24),
          children: [
            // Datos de la solicitud
            Text(
                s.requestDataSection.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              
            // Dropdown de usuarios (clientes)
            AppDropdownField<User>(
              value: _controller.idUsuario,
              items: usuariosDisponibles,
              itemValue: (User user) => user.id,
              itemLabel: (User user) => '${user.name} ${user.surname}',
              prefixIcon: Icons.person_outlined,
              label: s.client,
              hint: modoCliente ? s.client : s.selectClient,
              enabled: !modoCliente,
              onChanged: (int? val) {
                setState(() => _controller.idUsuario = val);
              },
            ),

            const SizedBox(height: 20),
            // Dropdown de actividades (solo disponibles, filtradas en backend)
            AppDropdownField<Activity>(
              value: _controller.idActividad,
              items: actividadesDisponibles,
              itemValue: (e) => e.id,
              itemLabel: (e) => '${e.startPoint} → ${e.endPoint}',
              prefixIcon: Icons.hiking_outlined,
              label: s.actividad,
              hint: s.selectActividad,
              isRequired: true,
              // Si no es edición o si es edición pero no es modo cliente, se puede cambiar la actividad.
              enabled: !isEdit || !modoCliente,
              onChanged: (int? v) {
                setState(() {
                  _controller.idActividad = v;
                  _controller.recalcularMateriales(actividadesDisponibles);
                });
              },
            ),

            const SizedBox(height: 20),
            // Campo de número de participantes
            CustomInputField(
              controller: _controller.participantesCtrl,
              labelText: s.numberOfParticipants,
              keyboardType: TextInputType.number,
              validator: (String? value) {
                // Validar que sea un entero > 0
                final validInt = ValidadoresFormulario.enteroMayorQueCero(s)(value);
                if (validInt != null) return validInt;
                
                // Validar que no exceda el máximo de la actividad
                if (actividadSeleccionada != null && value != null) {
                  final int? participants = int.tryParse(value);
                  if (participants != null && participants > actividadSeleccionada.maxParticipants) {
                    return s.maxParticipantsExceeded(actividadSeleccionada.maxParticipants);
                  }
                }
                return null;
              },
              onChanged: (_) => setState(() => _controller.recalcularMateriales(actividades)),
            ),

            const SizedBox(height: 20),
            // Si no es modo edición o si el usuario ha pulsado el botón para mostrar materiales recomendados
            if (!isEdit || _mostrarMateriales) ...[
              // Muestra la sección de materiales recomendados
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Título de la sección
                  Text(
                    s.recommendedMaterial.toUpperCase(),
                    style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),

                  // Si hay una actividad seleccionada 
                  if (actividadSeleccionada != null)
                    // Botón para añadir todos los materiales recomendados
                    TertiaryButton(
                      label: s.addAll,
                      icon: Icons.add,
                      onPressed: () {
                        final Map<int, int> plantilla = actividadSeleccionada.materialsPerParticipant;
                        setState(() {
                          for (final MapEntry<int, int> entry in plantilla.entries) {
                            _controller.establecerCantidadMaterial(entry.key, entry.value * _controller.numeroParticipantes);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Si no hay actividad seleccionada
              if (actividadSeleccionada == null)
                // Selecciona una actividad para ver material recomendado.
                Text(
                  s.selectActividadToSeeMaterial,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                )

              // Si la actividad seleccionada no tiene materiales recomendados
              else if (actividadSeleccionada.materialsPerParticipant.isEmpty)
                // No hay materiales recomendados para esta actividad.
                Text(
                  s.noRecommendedMaterial,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                )

              else
                // Recorre materiales recomendados 
                ..._controller.materialesSolicitados.entries.map((entry) {
                  final int idEquipamiento = entry.key;
                  final int cantidad = entry.value;
                  final String nombre = ref.watch(equipmentNameProvider(idEquipamiento));

                  // Usa el provider cacheado para buscar el equipamiento por ID.
                  final Equipment? item = ref.watch(equipmentByIdProvider(idEquipamiento));
                  
                  final double? precioDiario = item?.pricePerDay;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        // Nombre del material y precio diario si existe
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nombre, style: tt.bodyMedium),
                              if (precioDiario != null && precioDiario > 0)
                                Text(
                                  '  ${s.pricePerUnitDay(precioDiario.toStringAsFixed(2))}',
                                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                ),
                            ],
                          ),
                        ),

                        // Boton menos
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: cantidad > 0
                              ? () => setState(() => _controller.establecerCantidadMaterial(idEquipamiento, cantidad - 1))
                              : null,
                        ),

                        // Cantidad
                        Text('$cantidad', style: tt.bodyMedium),

                        // Boton más
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () {
                            Equipment? eq;
                            try {
                              eq = equipamientos.firstWhere((e) => e.id == idEquipamiento);
                            } catch (e) {
                              // TODO: HARDCODEADO, mejorar mensaje de error
                              showErrorSnackBar(context, "s.equipmentNotFound(idEquipamiento)");
                            }
                            if (eq != null && cantidad >= eq.units) {
                              showErrorSnackBar(context, s.insufficientStock(eq.units, idEquipamiento));
                              return;
                            }
                            setState(() => _controller.establecerCantidadMaterial(idEquipamiento, cantidad + 1));
                          },
                        ),

                        // Botón eliminar
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
                          onPressed: () => setState(() => _controller.materialesSolicitados.remove(idEquipamiento)),
                        ),
                      ],
                    ),
                  );
                }),

              // Si es modo edición, no hay reserva asociada y la actividad seleccionada tiene materiales recomendados
            ] else if (isEdit && _controller.idReserva == null && actividadSeleccionada != null && actividadSeleccionada.materialsPerParticipant.isNotEmpty) ...[
              // Botón para mostrar materiales recomendados
              TertiaryButton(
                label: s.addMaterials,
                icon: Icons.add,
                onPressed: () => setState(() {
                  _mostrarMateriales = true;
                  for (final MapEntry<int, int> entry in actividadSeleccionada.materialsPerParticipant.entries) {
                    _controller.establecerCantidadMaterial(entry.key, entry.value * _controller.numeroParticipantes);
                  }
                }),
              ),

              // Si es modo edición, no hay reserva asociada y el usuario ha pulsado el botón para mostrar materiales recomendados
            ] else if (_controller.idReserva != null && _controller.materialesSolicitados.isNotEmpty) ...[
              const SizedBox(height: 15),
              // Lista de materiales solicitados
              Text(
                s.reservedMaterialSection.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 10),

              // Recorre los materiales solicitados
              ..._controller.materialesSolicitados.entries.map((entry) {
                final int idEquipamiento = entry.key;
                final int cantidad = entry.value;
                
                final String nombre = ref.watch(equipmentNameProvider(idEquipamiento));
                // Usa el provider cacheado para buscar el equipamiento por ID.
                final Equipment? item = ref.watch(equipmentByIdProvider(idEquipamiento));
                final double? precioDiario = item?.pricePerDay;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      // Nombre del material y precio diario si existe
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nombre, style: tt.bodyMedium),
                            if (precioDiario != null && precioDiario > 0)
                              Text(
                                '  ${s.pricePerUnitDay(precioDiario.toStringAsFixed(2))}',
                                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                      // Cantidad (solo lectura)
                      Text('$cantidad', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 20),
            // Si no es modo cliente
            if (!modoCliente) ...[
              // Estado de la solicitud
              Text(
                s.status.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              // Chips de estado
              AppChipWrap(
                children: WorkflowStatus.values.map((WorkflowStatus est) {
                  final bool seleccionado = _controller.estado == est;
                  return AppChoiceChip(
                    label: est.localizedLabel(s),
                    seleccionado: seleccionado,
                    onSelected: (_) => setState(() => _controller.estado = est),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              // Dropdown de expertos
              AppDropdownField<User>(
                value: _controller.idExperto,
                items: ref.watch(expertsProvider).value ?? [],
                itemValue: (User user) => user.id,
                itemLabel: (User user) => '${user.name} ${user.surname}',
                prefixIcon: Icons.star_outline,
                label: s.expert,
                hint: s.selectExpert,
                onChanged: (int? val) => setState(() => _controller.idExperto = val),
              ),
            ],

            const SizedBox(height: 28),
            // Si hay una actividad seleccionada
            if (actividadSeleccionada != null) ...[
              // Resumen de precios
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.onTertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.onTertiary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la sección
                    Text(s.priceSummary, style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer)),
                    const SizedBox(height: 6),

                    // Precio de la actividad multiplicado por el número de participantes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Numero de participantes
                        Text(s.actividadPrice(_controller.numeroParticipantes), style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
                        // Precio total de la actividad
                        Text(s.priceEur((actividadSeleccionada.price * _controller.numeroParticipantes).toStringAsFixed(2)), style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
                      ],
                    ),

                    // Si hay materiales solicitados
                    if (_controller.tieneMateriales) ...[
                      const SizedBox(height: 2),
                      // Materiales y precio
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Etiqueta de materiales de alquiler
                          Text(s.materialsRental, style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
                          // Precio total de los materiales
                          Text(
                            () {
                              final double precioMateriales = _controller.calcularPrecioTotal(actividades, equipamientos) - actividadSeleccionada.price * _controller.numeroParticipantes;
                              return s.priceEur(precioMateriales.toStringAsFixed(2));
                            }(),
                            style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer),
                          ),
                        ],
                      ),
                    ],
                    const Divider(),
                    // Precio total (actividad + materiales)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Etiqueta de total
                        Text(s.total, style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer)),
                        // Precio total
                        Text(
                          s.priceEur(_controller.calcularPrecioTotal(actividades, equipamientos).toStringAsFixed(2)), 
                          style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer),
                        ),
                      ],
                    ),

                    // Si hay una reserva asociada con cargo por daños
                    if (cargoDanios > 0) ...[
                      const SizedBox(height: 6),
                      const Divider(),
                      // Cargo por daños
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s.damageCharge, style: tt.bodySmall?.copyWith(color: cs.error)),
                          Text('+ €${cargoDanios.toStringAsFixed(2)}', style: tt.bodySmall?.copyWith(color: cs.error)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Si es modo edición y hay una reserva asociada
            if (isEdit && _controller.idReserva != null) ...[
              const SizedBox(height: 12),
              // Botón para editar la reserva asociada
              SecondaryButton(
                label: s.editReservationBtn,
                icon: Icons.book_online_outlined,
                onPressed: () async {
                  // Lee la reserva asociada del provider cacheado.
                  final Booking? reservaAsociada = ref.read(reservationByIdProvider(_controller.idReserva!));

                  // Si no se encuentra la reserva asociada sale de la función
                  if (reservaAsociada == null) return;

                  // Navega a la página de edición de reserva, pasando la reserva asociada
                  final Booking? actualizada = await Navigator.of(context).push<Booking>(
                    MaterialPageRoute(
                      builder: (_) => ReservationFormPage(
                        reserva: reservaAsociada,
                        initialActivity: reservaAsociada.activityId != null 
                            ? ref.read(activityByIdProvider(reservaAsociada.activityId!)) 
                            : null,
                      ),
                    ),
                  );
                  // Si se devuelve una reserva actualizada, actualízala en el provider
                  if (actualizada == null) return;

                  try {
                    await ref.read(reservationsProvider.notifier).actualizar(reservaAsociada, actualizada);
                    
                    if (!context.mounted) return;
                    showSuccessSnackBar(context, s.actividadActualizada);
                  } catch (e) {
                    if (!context.mounted) return;
                    showErrorSnackBar(context, s.error(e.toString()));
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}