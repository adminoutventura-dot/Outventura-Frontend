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
import 'package:outventura/features/outventura/presentation/pages/forms/reservation_form_page.dart';

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

    // Si la reserva vinculada fue borrada desde otra pantalla, limpiar el controller.
    if (_controller.idReserva != null) {
      final List<Reserva> reservas = ref.watch(reservasProvider).value ?? [];
      final bool reservaAunExiste = reservas.any((Reserva r) => r.id == _controller.idReserva);
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

    List<Usuario> usuariosDisponibles = ref.watch(usuariosProvider).value ?? [];
    if (modoCliente) {
      usuariosDisponibles = usuariosDisponibles
          .where((Usuario u) => u.id == widget.initialIdUsuario)
          .toList();
    }

    final Excursion? excursionSeleccionada = _controller.buscarExcursionSeleccionada( excursiones );

    // Cargo por daños de la reserva asociada (si existe y tiene daños registrados).
    final List<Reserva> todasReservas = ref.watch(reservasProvider).value ?? [];
    final Reserva? reservaAsociada = _controller.idReserva != null
        ? todasReservas.where((Reserva r) => r.id == _controller.idReserva).firstOrNull
        : null;
    final double cargoDanios = reservaAsociada?.cargoDanios ?? 0;

    // Mapa para mostrar el nombre del equipamiento a partir de su id.
    final Map<int, String> nombrePorId = {};
    final Map<int, double> precioPorId = {};
    for (final Equipamiento e in equipamientos) {
      nombrePorId[e.id] = e.nombre;
      precioPorId[e.id] = e.precioAlquilerDiario;
    }

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
          padding: EdgeInsets.fromLTRB( 16, 16, 16, MediaQuery.of(context).padding.bottom + 24 ),
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
                    'Material recomendado',
                    style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  if (excursionSeleccionada != null)
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

              // Si no hay excursión seleccionada, mostrar mensaje. 
              // Si la excursión no requiere material, mostrar otro mensaje. 
              // Si hay materiales, mostrarlos con controles para modificar las cantidades.
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
            ] else if (isEdit && _controller.idReserva == null && excursionSeleccionada != null && excursionSeleccionada.materialesPorParticipante.isNotEmpty) ...[  
              // Editando sin reserva: botón para añadir materiales
              TertiaryButton(
                label: 'Añadir materiales',
                icon: Icons.add,
                onPressed: () => setState(() {
                  _mostrarMateriales = true;
                  for (final MapEntry<int, int> entry in excursionSeleccionada.materialesPorParticipante.entries) {
                    _controller.establecerCantidadMaterial(entry.key, entry.value * _controller.numeroParticipantes);
                  }
                }),
              ),

            // Si estamos editando una solicitud con reserva, mostrar materiales en solo lectura (sin controles).
            ] else if (_controller.idReserva != null && _controller.materialesSolicitados.isNotEmpty) ...[
              Text(
                'Material reservado',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),

              // .entries — convierte el Map<int, int> en un iterable de pares MapEntry<int, int> (clave=idEquipamiento, valor=cantidad)
              // .map((entry) { ... }) — transforma cada entrada en un widget Padding con la fila de ese material
              // ... (spread operator) — "despliega" la lista resultante dentro del array de widgets
              ..._controller.materialesSolicitados.entries.map((entry) {
                final int idEquipamiento = entry.key;
                final int cantidad = entry.value;
                final String nombre = nombrePorId[idEquipamiento] ?? 'Material #$idEquipamiento';
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
                items: ref.watch(usuariosProvider).value ?? [],
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

                    // Precio total (excursión + materiales).
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer)),
                        Text('€${_controller.calcularPrecioTotal(excursiones, equipamientos).toStringAsFixed(2)}', style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold)),
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
                          Text('+ €${cargoDanios.toStringAsFixed(2)}', style: tt.bodySmall?.copyWith(color: cs.error, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 12),
            // Botones: Editar reserva (si existe) + Guardar/Crear en la misma fila
            Row(
              children: [
                if (isEdit && _controller.idReserva != null) ...[
                  Expanded(
                    child: SecondaryButton(
                      label: 'Editar reserva',
                      icon: Icons.book_online_outlined,
                      onPressed: () async {
                        final List<Reserva> reservas = ref.read(reservasProvider).value ?? [];
                        final Reserva? reservaAsociada = _controller.buscarReserva(reservas, _controller.idReserva!);
                        if (reservaAsociada == null) return;
                        final Reserva? actualizada = await Navigator.of(context).push<Reserva>(
                          MaterialPageRoute(
                            builder: (_) => ReservationFormPage(reserva: reservaAsociada),
                          ),
                        );
                        if (actualizada != null) {
                          ref.read(reservasProvider.notifier).actualizar(reservaAsociada, actualizada);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: PrimaryButton(
                    label: isEdit ? 'Guardar' : 'Crear',
                    onPressed: () {

                      // Si no hay reserva asociada pero se han seleccionado materiales, crear la reserva antes de guardar la solicitud.
                      if (_controller.idReserva == null && _controller.tieneMateriales) {
                        final Reserva? reserva = _controller.crearReservaDesdeSolicitud(
                          context: context,
                          ref: ref,
                        );
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

                      // Cierra la página y devuelve la solicitud a la página anterior
                      Navigator.of(context).pop(solicitud);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
