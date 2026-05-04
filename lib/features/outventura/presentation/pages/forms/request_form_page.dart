import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_dropdown_field.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/domain/entities/request.dart';
import 'package:outventura/features/outventura/presentation/controllers/request_form_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';

class SolicitudFormPage extends ConsumerStatefulWidget {
  final Solicitud? solicitud;
  final int? initialIdExcursion;
  final int? initialIdUsuario;

  const SolicitudFormPage({
    super.key,
    this.solicitud,
    this.initialIdExcursion,
    this.initialIdUsuario,
  });

  @override
  ConsumerState<SolicitudFormPage> createState() => _SolicitudFormPageState();
}

class _SolicitudFormPageState extends ConsumerState<SolicitudFormPage> {
  late final RequestFormController _controller;

  // Funcion para crear una reserva a partir de la solicitud actual. Si hay un error, muestra un mensaje y devuelve null.
  Reserva? _crearReservaDesdeSolicitud() {
    final String? error = _controller.mensajeErrorReserva;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return null;
    }
    final List<Excursion> excursiones = ref.read(excursionesProvider).value ?? [];
    final Reserva? reserva = _controller.crearReserva(excursiones);
    if (reserva != null) {
      ref.read(reservasProvider.notifier).agregar(reserva);
    }
    return reserva;
  }

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
        idExcursion: widget.initialIdExcursion,
        idUsuario: widget.initialIdUsuario,
      );
    }

    if (widget.solicitud == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() => _controller.recalcularMateriales(ref.read(excursionesProvider).value ?? []));
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
    final bool isEdit = _controller.editando;
    final List<Excursion> excursiones = ref.watch(excursionesProvider).value ?? [];
    final List<Equipamiento> equipamientos = ref.watch(equipamientosProvider).value ?? [];

    // Indica si estamos en modo cliente (se ha pasado un idUsuario fijo).
    final bool modoCliente = widget.initialIdUsuario != null;

    List<Usuario> usuariosDisponibles = ref.read(usuariosProvider).value ?? [];
    if (modoCliente && widget.initialIdUsuario != null) {
      usuariosDisponibles = usuariosDisponibles
          .where((Usuario u) => u.id == widget.initialIdUsuario)
          .toList();
    }

    final Excursion? excursionSeleccionada = _controller.buscarExcursionSeleccionada(
      excursiones,
    );

    // Mapa para mostrar el nombre del equipamiento a partir de su id.
    final Map<int, String> nombrePorId = {
      for (final Equipamiento e in equipamientos) e.id: e.nombre,
    };
    final Map<int, double> precioPorId = {
      for (final Equipamiento e in equipamientos) e.id: e.precioAlquilerDiario,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar solicitud' : 'Nueva solicitud'),
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
      body: Form(
        key: _controller.formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          children: [
            // Usuario (cliente)
            AppDropdownField<Usuario>(
              value: _controller.idUsuario,
              items: usuariosDisponibles,
              itemValue: (Usuario user) => user.id,
              itemLabel: (Usuario user) => '${user.nombre} ${user.apellidos}',
              prefixIcon: Icons.person_outlined,
              label: 'Cliente',
              hint: modoCliente ? 'Tu usuario' : 'Selecciona un cliente',
              enabled: !modoCliente,
              onChanged: (int? val) {
                setState(() => _controller.idUsuario = val);
              },
            ),

            const SizedBox(height: 20),
            // Excursión
            AppDropdownField<Excursion>(
              value: _controller.idExcursion,
              items: excursiones,
              itemValue: (e) => e.id,
              itemLabel: (e) => '${e.puntoInicio} → ${e.puntoFin}',
              prefixIcon: Icons.hiking_outlined,
              label: 'Excursión',
              hint: 'Selecciona una excursión',
              isRequired: true,
              enabled: !modoCliente,
              onChanged: (int? v) {
                setState(() => _controller.idExcursion = v);
                setState(() => _controller.recalcularMateriales(excursiones));
              },
            ),

            const SizedBox(height: 20),
            // Participantes
            CustomInputField(
              controller: _controller.participantesCtrl,
              labelText: 'Número de participantes',
              keyboardType: TextInputType.number,
              validator: ValidadoresFormulario.enteroMayorQueCero,
              onChanged: (_) => setState(() => _controller.recalcularMateriales(excursiones)),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Material recomendado',
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                // Botón para añadir todo el material recomendado.
                if (excursionSeleccionada != null && _controller.idReserva == null)
                  TertiaryButton(
                    label: 'Añadir todos',
                    icon: Icons.add,
                    onPressed: () {
                      final Map<int, int> plantilla = excursionSeleccionada.materialesPorParticipante;
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
            if (excursionSeleccionada == null)
              Text(
                'Selecciona una excursión para ver material recomendado.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              )
            else if (excursionSeleccionada.materialesPorParticipante.isEmpty)
              Text(
                'Esta excursión no requiere material recomendado.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              )
            else
              ..._controller.materialesSolicitados.entries.map((entry) {
                final int idEquipamiento = entry.key;
                final int cantidad = entry.value;
                final String nombre = nombrePorId[idEquipamiento] ?? 'Material #$idEquipamiento';
                final double? precioDiario = precioPorId[idEquipamiento];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      // Nombre del material y precio
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

                      // Si hay una reserva asociada, muestra el boton "-".
                      if (_controller.idReserva == null) ...[
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: cantidad > 0
                              ? () => setState(
                                  () => _controller.establecerCantidadMaterial(
                                    idEquipamiento,
                                    cantidad - 1,
                                  ),
                                )
                              : null,
                        ),
                      ],

                      // Cantidad solicitada
                      Text('$cantidad', style: tt.bodyMedium),

                      // Si hay una reserva asociada, muestra el boton "+".
                      if (_controller.idReserva == null) ...[
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () => setState(
                            () => _controller.establecerCantidadMaterial(
                              idEquipamiento,
                              cantidad + 1,
                            ),
                          ),
                        ),
                        // Botón eliminar material
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
                          onPressed: () => setState(
                            () => _controller.materialesSolicitados.remove(idEquipamiento),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            if (!modoCliente) ...[
              const SizedBox(height: 20),
              // Estado
              Text(
                'Estado',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              AppChipWrap(
                children: EstadoSolicitud.values.map((EstadoSolicitud est) {
                  final bool seleccionado = _controller.estado == est;
                  return AppChoiceChip(
                    label: est.label,
                    seleccionado: seleccionado,
                    onSelected: (_) => setState(() => _controller.estado = est),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              // Experto
              AppDropdownField<Usuario>(
                value: _controller.idExperto,
                items: ref.read(usuariosProvider).value ?? [],
                itemValue: (Usuario user) => user.id,
                itemLabel: (Usuario user) => '${user.nombre} ${user.apellidos}',
                prefixIcon: Icons.person_outline,
                label: 'Experto',
                hint: 'Selecciona un experto',
                onChanged: (int? val) =>
                    setState(() => _controller.idExperto = val),
              ),
            ],

            const SizedBox(height: 28),
            // Resumen de precio total
            if (excursionSeleccionada != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration( color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resumen de precio', style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer)),
                    const SizedBox(height: 6),
                    // Precio total de la excursión (precio por participante * número de participantes).
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Excursión (×${ _controller.numeroParticipantes})', style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
                        Text('€${(excursionSeleccionada.precio * _controller.numeroParticipantes).toStringAsFixed(2)}', style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
                      ],
                    ),

                    // Si hay materiales, mostrar el precio total de los materiales.
                    if (_controller.tieneMateriales) ...[
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Materiales (alquiler)', style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
                          Text(
                            () {
                              final double precioMateriales = _controller.calcularPrecioTotal(excursiones, equipamientos) - excursionSeleccionada.precio * _controller.numeroParticipantes;
                              return '€${precioMateriales.toStringAsFixed(2)}';
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
                        Text('Total', style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer)),
                        Text('€${_controller.calcularPrecioTotal(excursiones, equipamientos).toStringAsFixed(2)}', style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Guardar
            PrimaryButton(
              label: isEdit ? 'Guardar' : 'Crear',
              onPressed: () {

                // Si no hay reserva asociada pero se han seleccionado materiales, crear la reserva antes de guardar la solicitud.
                if (_controller.idReserva == null && _controller.tieneMateriales) {
                  final Reserva? reserva = _crearReservaDesdeSolicitud();
                  if (reserva == null) {
                    return;
                  }
                }

                //  Crear la solicitud a partir de los datos actuales del formulario y la guarda en variable.
                final Solicitud? solicitud = _controller.crearSolicitud(excursiones, equipamientos);
                if (solicitud == null) {
                  return;
                }

                // Sincroniza la reserva asociada a la solicitud con los datos actuales.
                final List<Reserva> reservasActuales = ref.read(reservasProvider).value ?? [];
                final Reserva? reservaActualizada = _controller.sincronizarReservaConSolicitud(solicitud, reservasActuales);
                if (reservaActualizada != null && solicitud.idReserva != null) {
                  final Reserva? original = _controller.buscarReserva(reservasActuales, solicitud.idReserva!);
                  if (original != null) {
                    ref.read(reservasProvider.notifier).actualizar(original, reservaActualizada);
                  }
                }

                // Cierra la página y devuelve el nuevo equipamiento a la página anterior
                Navigator.of(context).pop(solicitud);
              },
            ),
          ],
        ),
      ),
    );
  }
}
