import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/widgets/app_bar_forms.dart';
import 'package:outventura/core/widgets/bottom_price_bar.dart';
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

    // Si la solicitud ya tenía una reserva asociada
    if (_controller.idReserva != null) {

      // Busca esa reserva en el provider
      final List<Booking> reservas = ref.watch(reservationsProvider).value ?? [];
      final bool reservaAunExiste = reservas.any((Booking r) => r.id == _controller.idReserva);

      // Si ya no existe en la lista
      if (!reservaAunExiste) {
        // Mecanismo de Flutter que programa una función para que se ejecute justo después de que el frame actual termine de pintarse.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Si el widget sigue montado, actualiza el estado para eliminar la referencia a la reserva y limpiar los materiales asociados.
            setState(() {
              _controller.idReserva = null;
              _controller.materialesSolicitados.clear();
            });
          }
        });
      }
    }

    final bool modoCliente = widget.initialIdUsuario != null;

    // Lista de usuarios
    List<User> usuariosDisponibles = ref.watch(usuariosProvider).value ?? [];
    // Si es modo cliente
    if (modoCliente) {
      // Filtra la lista de usuarios para que solo contenga al cliente específico
      usuariosDisponibles = usuariosDisponibles
          .where((User u) => u.id == widget.initialIdUsuario)
          .toList();
    }

    final Activity? actividadSeleccionada = _controller.buscarActividadSeleccionada(actividades);

    final List<Booking> todasReservas = ref.watch(reservationsProvider).value ?? [];
    final Booking? reservaAsociada = _controller.idReserva != null
        ? todasReservas.where((Booking r) => r.id == _controller.idReserva).firstOrNull
        : null;
    final double cargoDanios = reservaAsociada?.damageFee ?? 0;

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
        onPressed: () {
          // Validar formulario
          if (_controller.idReserva == null && _controller.tieneMateriales) {
            final Booking? reserva = _controller.crearReservaDesdeSolicitud(
              context: context,
              ref: ref,
            );
            if (reserva == null) return;
          }

          // Crear o actualizar solicitud
          final Request? solicitud = _controller.crearEditarSolicitud(actividades, equipamientos);
          if (solicitud == null) return;

          // Lista de reservas
          final List<Booking> reservasActuales = ref.read(reservationsProvider).value ?? [];
          // Reserva actualizada o creada a partir de la solicitud
          final Booking? reservaActualizada = _controller.sincronizarReservaConSolicitud(solicitud, reservasActuales);

          // Si hay una reserva actualizada o creada, y la solicitud tiene un ID de reserva asociado
          if (reservaActualizada != null && solicitud.reservationId != null) {
            // Buscar la reserva original en la lista de reservas usando el ID de reserva de la solicitud
            final Booking? original = _controller.buscarReserva(reservasActuales, solicitud.reservationId!);
            // Si se encuentra la reserva original, actualizarla en el provider
            if (original != null) {
              ref.read(reservationsProvider.notifier).actualizar(original, reservaActualizada);
            }
          }

          // Devolver la solicitud creada o editada a la pantalla anterior
          Navigator.of(context).pop(solicitud);
        },
      ),
      
      body: Form(
        key: _controller.formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, topPadding + 40, 20, bottomBarHeight + 24),
          children: [
            Text(
                s.requestDataSection.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
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
            AppDropdownField<Activity>(
              value: _controller.idActividad,
              items: actividades,
              itemValue: (e) => e.id,
              itemLabel: (e) => '${e.startPoint} → ${e.endPoint}',
              prefixIcon: Icons.hiking_outlined,
              label: s.actividad,
              hint: s.selectActividad,
              isRequired: true,
              enabled: !modoCliente,
              onChanged: (int? v) {
                setState(() {
                  _controller.idActividad = v;
                  _controller.recalcularMateriales(actividades);
                });
              },
            ),

            const SizedBox(height: 20),
            CustomInputField(
              controller: _controller.participantesCtrl,
              labelText: s.numberOfParticipants,
              keyboardType: TextInputType.number,
              validator: ValidadoresFormulario.enteroMayorQueCero(s),
              onChanged: (_) => setState(() => _controller.recalcularMateriales(actividades)),
            ),

            const SizedBox(height: 20),
            if (!isEdit || _mostrarMateriales) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.recommendedMaterial.toUpperCase(),
                    style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  if (actividadSeleccionada != null)
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

              if (actividadSeleccionada == null)
                Text(
                  s.selectActividadToSeeMaterial,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                )
              else if (actividadSeleccionada.materialsPerParticipant.isEmpty)
                Text(
                  s.noRecommendedMaterial,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                )
              else
                ..._controller.materialesSolicitados.entries.map((entry) {
                  final int idEquipamiento = entry.key;
                  final int cantidad = entry.value;
                  
                  final String nombre = ref.watch(equipmentNameProvider(idEquipamiento));
                  final Equipment? item = equipamientos.cast<Equipment?>().firstWhere((e) => e?.id == idEquipamiento, orElse: () => null);
                  final double? precioDiario = item?.pricePerDay;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
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
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: cantidad > 0
                              ? () => setState(() => _controller.establecerCantidadMaterial(idEquipamiento, cantidad - 1))
                              : null,
                        ),
                        Text('$cantidad', style: tt.bodyMedium),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () => setState(() => _controller.establecerCantidadMaterial(idEquipamiento, cantidad + 1)),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
                          onPressed: () => setState(() => _controller.materialesSolicitados.remove(idEquipamiento)),
                        ),
                      ],
                    ),
                  );
                }),
            ] else if (isEdit && _controller.idReserva == null && actividadSeleccionada != null && actividadSeleccionada.materialsPerParticipant.isNotEmpty) ...[
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
            ] else if (_controller.idReserva != null && _controller.materialesSolicitados.isNotEmpty) ...[
              const SizedBox(height: 15),
              Text(
                s.reservedMaterialSection.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              ..._controller.materialesSolicitados.entries.map((entry) {
                final int idEquipamiento = entry.key;
                final int cantidad = entry.value;
                
                final String nombre = ref.watch(equipmentNameProvider(idEquipamiento));
                final Equipment? item = equipamientos.cast<Equipment?>().firstWhere((e) => e?.id == idEquipamiento, orElse: () => null);
                final double? precioDiario = item?.pricePerDay;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
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
                      Text('$cantidad', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 20),
            if (!modoCliente) ...[
              Text(
                s.status.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              AppChipWrap(
                children: RequestStatus.values.map((RequestStatus est) {
                  final bool seleccionado = _controller.estado == est;
                  return AppChoiceChip(
                    label: est.localizedLabel(s),
                    seleccionado: seleccionado,
                    onSelected: (_) => setState(() => _controller.estado = est),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              AppDropdownField<User>(
                value: _controller.idExperto,
                items: ref.watch(usuariosProvider).value ?? [],
                itemValue: (User user) => user.id,
                itemLabel: (User user) => '${user.name} ${user.surname}',
                prefixIcon: Icons.star_outline,
                label: s.expert,
                hint: s.selectExpert,
                onChanged: (int? val) => setState(() => _controller.idExperto = val),
              ),
            ],

            const SizedBox(height: 28),
            if (actividadSeleccionada != null) ...[
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
                    Text(s.priceSummary, style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.actividadPrice(_controller.numeroParticipantes), style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
                        Text(s.priceEur((actividadSeleccionada.price * _controller.numeroParticipantes).toStringAsFixed(2)), style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
                      ],
                    ),
                    if (_controller.tieneMateriales) ...[
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s.materialsRental, style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.total, style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer)),
                        Text(
                          s.priceEur(_controller.calcularPrecioTotal(actividades, equipamientos).toStringAsFixed(2)), 
                          style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer),
                        ),
                      ],
                    ),
                    if (cargoDanios > 0) ...[
                      const SizedBox(height: 6),
                      const Divider(),
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
            if (isEdit && _controller.idReserva != null) ...[
              const SizedBox(height: 12),
              SecondaryButton(
                label: s.editReservationBtn,
                icon: Icons.book_online_outlined,
                onPressed: () async {
                  final List<Booking> reservas = ref.read(reservationsProvider).value ?? [];
                  final Booking? reservaAsociada = _controller.buscarReserva(reservas, _controller.idReserva!);
                  if (reservaAsociada == null) return;
                  final Booking? actualizada = await Navigator.of(context).push<Booking>(
                    MaterialPageRoute(
                      builder: (_) => ReservationFormPage(reserva: reservaAsociada),
                    ),
                  );
                  if (actualizada != null) {
                    ref.read(reservationsProvider.notifier).actualizar(reservaAsociada, actualizada);
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