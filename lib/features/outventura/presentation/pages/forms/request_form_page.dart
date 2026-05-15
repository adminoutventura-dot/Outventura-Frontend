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
  // Al editar sin reserva, los materiales se ocultan hasta que el usuario pulse "Añadir materiales".
  bool _mostrarMateriales = false;

  @override
  void initState() {
    super.initState();
    _controller = RequestFormController();
    // Si se ha pasado una solicitud, cargar sus datos en el controlador. 
    if (widget.solicitud != null) {
      _controller.cargarSolicitud(widget.solicitud!);
      if (widget.initialIdUsuario != null) {
        _controller.idUsuario = widget.initialIdUsuario;
      }
      // Si no, aplicar valores iniciales.
    } else {
      _controller.aplicarValoresIniciales(
        idActividad: widget.initialIdActividad,
        idUsuario: widget.initialIdUsuario,
      );
    }

    if (widget.solicitud == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
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
    final bool isEdit = _controller.editando;
    final List<Activity> actividades = ref.watch(activitiesProvider).value ?? [];
    final List<Equipment> equipamientos = ref.watch(equipmentProvider).value ?? [];

    // Si la reserva vinculada fue borrada desde otra pantalla, limpiar el controller.
    if (_controller.idReserva != null) {
      final List<Reservation> reservas = ref.watch(reservationsProvider).value ?? [];
      final bool reservaAunExiste = reservas.any((Reservation r) => r.id == _controller.idReserva);
      if (!reservaAunExiste) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _controller.idReserva = null;
              _controller.materialesSolicitados.clear();
            });
          }
        });
      }
    }

    // Indica si estamos en modo cliente (se ha pasado un idUsuario fijo).
    final bool modoCliente = widget.initialIdUsuario != null;

    List<User> usuariosDisponibles = ref.watch(usuariosProvider).value ?? [];
    if (modoCliente) {
      usuariosDisponibles = usuariosDisponibles
          .where((User u) => u.id == widget.initialIdUsuario)
          .toList();
    }

    final Activity? actividadSeleccionada = _controller.buscarActividadSeleccionada( actividades );

    // Cargo por daños de la reserva asociada (si existe y tiene daños registrados).
    final List<Reservation> todasReservas = ref.watch(reservationsProvider).value ?? [];
    final Reservation? reservaAsociada = _controller.idReserva != null
        ? todasReservas.where((Reservation r) => r.id == _controller.idReserva).firstOrNull
        : null;
    final double cargoDanios = reservaAsociada?.damageFee ?? 0;

    // Mapa para mostrar el nombre del equipamiento a partir de su id.
    final Map<int, String> nombrePorId = {};
    final Map<int, double> precioPorId = {};
    for (final Equipment e in equipamientos) {
      nombrePorId[e.id] = e.title;
      precioPorId[e.id] = e.pricePerDay;
    }

    final double totalPrice = _controller.calcularPrecioTotal(actividades, equipamientos);

    return Scaffold(
      appBar: CustomAppBarForm(title: isEdit ? s.editRequest : s.newRequest),
      bottomNavigationBar: BottomPriceBar(
        totalLabel: s.total,
        price: s.priceEur(totalPrice.toStringAsFixed(2)),
        actionLabel: isEdit ? s.save : s.create,
        onPressed: () {
          // Si no hay reserva asociada pero se han seleccionado materiales, crear la reserva antes de guardar.
          if (_controller.idReserva == null && _controller.tieneMateriales) {
            final Reservation? reserva = _controller.crearReservaDesdeSolicitud(
              context: context,
              ref: ref,
            );
            if (reserva == null) return;
          }

          // Crear la solicitud a partir de los datos del formulario.
          final Request? solicitud = _controller.crearSolicitud(actividades, equipamientos);
          if (solicitud == null) return;

          // Sincronizar la reserva asociada si existe.
          final List<Reservation> reservasActuales = ref.read(reservationsProvider).value ?? [];
          final Reservation? reservaActualizada = _controller.sincronizarReservaConSolicitud(solicitud, reservasActuales);
          if (reservaActualizada != null && solicitud.reservationId != null) {
            final Reservation? original = _controller.buscarReserva(reservasActuales, solicitud.reservationId!);
            if (original != null) {
              ref.read(reservationsProvider.notifier).actualizar(original, reservaActualizada);
            }
          }

          // Cerrar la página y devolver la solicitud.
          Navigator.of(context).pop(solicitud);
        },
      ),
      body: Form(
        key: _controller.formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB( 16, 16, 16, MediaQuery.of(context).padding.bottom + 24 ),
          children: [
            // Usuario (cliente)
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
            // Excursión
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
                setState(() => _controller.idActividad = v);
                setState(() => _controller.recalcularMateriales(actividades));
              },
            ),

            const SizedBox(height: 20),
            // Participantes
            CustomInputField(
              controller: _controller.participantesCtrl,
              labelText: s.numberOfParticipants,
              keyboardType: TextInputType.number,
              validator: ValidadoresFormulario.enteroMayorQueCero(s),
              onChanged: (_) => setState(() => _controller.recalcularMateriales(actividades)),
            ),

            // Material recomendado y selección de materiales (solo si se ha seleccionado una excursión)
            const SizedBox(height: 20),
            // Al crear: materiales con controles desde el inicio.
            // Al editar sin reserva: botón para mostrar materiales, ocultos por defecto.
            // Al editar con reserva: materiales en solo lectura.
            if (!isEdit || _mostrarMateriales) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.recommendedMaterial,
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

              // Si no hay excursión seleccionada, mostrar mensaje. 
              // Si la excursión no requiere material, mostrar otro mensaje. 
              // Si hay materiales, mostrarlos con controles para modificar las cantidades.
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
                  final String nombre = nombrePorId[idEquipamiento] ?? s.materialId(idEquipamiento);
                  final double? precioDiario = precioPorId[idEquipamiento];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        // Nombre del material y precio diario 
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nombre, style: tt.bodyMedium),
                              if (precioDiario != null && precioDiario > 0)
                                Text(
                                  '  €${precioDiario.toStringAsFixed(2)}/ud·día',
                                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                ),
                            ],
                          ),
                        ),

                        // Botones: - (cantidad) + 
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

            // Si estamos editando una solicitud sin reserva, mostrar botón para añadir materiales recomendados.
            ] else if (isEdit && _controller.idReserva == null && actividadSeleccionada != null && actividadSeleccionada.materialsPerParticipant.isNotEmpty) ...[
              // Editando sin reserva: botón para añadir materiales
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

            // Si estamos editando una solicitud con reserva, mostrar materiales en solo lectura (sin controles).
            ] else if (_controller.idReserva != null && _controller.materialesSolicitados.isNotEmpty) ...[
              Text(
                s.reservedMaterialSection,
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),

              // .entries — convierte el Map<int, int> en un iterable de pares MapEntry<int, int> (clave=idEquipamiento, valor=cantidad)
              // .map((entry) { ... }) — transforma cada entrada en un widget Padding con la fila de ese material
              // ... (spread operator) — "despliega" la lista resultante dentro del array de widgets
              ..._controller.materialesSolicitados.entries.map((entry) {
                final int idEquipamiento = entry.key;
                final int cantidad = entry.value;
                final String nombre = nombrePorId[idEquipamiento] ?? s.materialId(idEquipamiento);
                final double? precioDiario = precioPorId[idEquipamiento];
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
                                '  €${precioDiario.toStringAsFixed(2)}/ud·día',
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
            // Si está en modo cliente, mostrar campos adicionales para estado y experto (solo lectura para el cliente, editable para el gestor).
            if (!modoCliente) ...[
              const SizedBox(height: 20),
              // Estado
              Text(
                s.status,
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
              // Experto
              AppDropdownField<User>(
                value: _controller.idExperto,
                items: ref.watch(usuariosProvider).value ?? [],
                itemValue: (User user) => user.id,
                itemLabel: (User user) => '${user.name} ${user.surname}',
                prefixIcon: Icons.star_outline,
                label: s.expert,
                hint: s.selectExpert,
                onChanged: (int? val) =>
                    setState(() => _controller.idExperto = val),
              ),
            ],

            const SizedBox(height: 28),
            // Resumen de precio total
            if (actividadSeleccionada != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration( color: cs.onTertiary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.onTertiary) ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.priceSummary, style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer)),
                    const SizedBox(height: 6),
                    // Precio total de la excursión (precio por participante * número de participantes).
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.actividadPrice(_controller.numeroParticipantes), style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
                        Text(s.priceEur((actividadSeleccionada.price * _controller.numeroParticipantes).toStringAsFixed(2)), style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
                      ],
                    ),

                    // Si hay materiales, mostrar el precio total de los materiales.
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

                    // Precio total (excursión + materiales).
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.total, style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer)),
                        Text(
                          s.priceEur(_controller.calcularPrecioTotal(actividades, equipamientos).toStringAsFixed(2)), 
                          style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer)
                        ),
                      ],
                    ),

                    // Cargo por daños (separado del total, solo si hay daños registrados)
                    if (cargoDanios > 0) ...[
                      const SizedBox(height: 6),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cargo por daños', style: tt.bodySmall?.copyWith(color: cs.error)),
                          Text('+ €${cargoDanios.toStringAsFixed(2)}', style: tt.bodySmall?.copyWith(color: cs.error)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Botón: Editar reserva (solo si existe reserva asociada)
            if (isEdit && _controller.idReserva != null) ...[
              const SizedBox(height: 12),
              SecondaryButton(
                label: s.editReservationBtn,
                icon: Icons.book_online_outlined,
                onPressed: () async {
                  final List<Reservation> reservas = ref.read(reservationsProvider).value ?? [];
                  final Reservation? reservaAsociada = _controller.buscarReserva(reservas, _controller.idReserva!);
                  if (reservaAsociada == null) return;
                  final Reservation? actualizada = await Navigator.of(context).push<Reservation>(
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
