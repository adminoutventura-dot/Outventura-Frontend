import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/id_generator.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_dropdown_field.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
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
  late final SolicitudFormController _controller;

  Map<int, int> _materialesDesdeLineas(List<LineaReserva> lineas) {
    final Map<int, int> materiales = {};
    for (final LineaReserva linea in lineas) {
      materiales[linea.idEquipamiento] = linea.cantidad;
    }
    return materiales;
  }

  List<LineaReserva> _lineasDesdeMateriales(Map<int, int> materiales) {
    return materiales.entries
        .where((entry) => entry.value > 0)
        .map(
          (entry) =>
              LineaReserva(idEquipamiento: entry.key, cantidad: entry.value),
        )
        .toList();
  }

  void _sincronizarReservaConSolicitud(Solicitud solicitud) {
    final int? idReserva = solicitud.idReserva;
    if (idReserva == null) {
      return;
    }

    final ReservasNotifier reservasNotifier = ref.read(
      reservasProvider.notifier,
    );
    final List<Reserva> reservas = ref.read(reservasProvider);

    Reserva? reserva;
    for (final Reserva r in reservas) {
      if (r.id == idReserva) {
        reserva = r;
        break;
      }
    }
    if (reserva == null) {
      return;
    }

    final List<LineaReserva> lineas = _lineasDesdeMateriales(
      solicitud.materialesSolicitados,
    );
    if (lineas.isEmpty) {
      return;
    }

    final Reserva actualizada = reserva.copyWith(
      idUsuario: solicitud.idUsuario ?? reserva.idUsuario,
      idExcursion: solicitud.idExcursion,
      lineas: lineas,
    );
    reservasNotifier.actualizar(reserva, actualizada);
  }

  Reserva? _crearReservaDesdeSolicitud() {
    final int? idUsuario = _controller.idUsuario;
    if (idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un cliente para reservar materiales.'),
        ),
      );
      return null;
    }

    final List<LineaReserva> lineas = _controller.materialesSolicitados.entries
        .where((entry) => entry.value > 0)
        .map(
          (entry) =>
              LineaReserva(idEquipamiento: entry.key, cantidad: entry.value),
        )
        .toList();

    if (lineas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Añade al menos un material para crear la reserva.'),
        ),
      );
      return null;
    }

    final Excursion? excursion = _buscarExcursionSeleccionada(
      ref.read(excursionesProvider),
    );
    final DateTime inicio = excursion?.fechaInicio ?? DateTime.now();
    final DateTime fin =
        excursion?.fechaFin ?? inicio.add(const Duration(days: 1));

    final Reserva reserva = Reserva(
      id: GeneradorId.idEntero(),
      idUsuario: idUsuario,
      lineas: lineas,
      idExcursion: _controller.idExcursion,
      fechaInicio: inicio,
      fechaFin: fin,
      estado: EstadoReserva.pendiente,
    );

    ref.read(reservasProvider.notifier).agregar(reserva);
    _controller.idReserva = reserva.id;
    return reserva;
  }

  Future<void> _editarReservaAsociada() async {
    final int? idReserva = _controller.idReserva;
    if (idReserva == null) {
      return;
    }

    final List<Reserva> reservas = ref.read(reservasProvider);
    Reserva? reserva;
    for (final Reserva r in reservas) {
      if (r.id == idReserva) {
        reserva = r;
        break;
      }
    }
    if (reserva == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró la reserva asociada.')),
      );
      return;
    }

    final Reserva? actualizada = await Navigator.of(context).push<Reserva>(
      MaterialPageRoute(
        builder: (_) => ReservationFormPage(
          reserva: reserva,
          initialIdUsuario: widget.initialIdUsuario,
        ),
      ),
    );

    if (actualizada != null) {
      ref.read(reservasProvider.notifier).actualizar(reserva, actualizada);
      setState(() {
        _controller.materialesSolicitados = _materialesDesdeLineas(
          actualizada.lineas,
        );
      });
    }
  }

  Excursion? _buscarExcursionSeleccionada(List<Excursion> excursiones) {
    final int? idExcursion = _controller.idExcursion;
    if (idExcursion == null) {
      return null;
    }
    for (final Excursion e in excursiones) {
      if (e.id == idExcursion) {
        return e;
      }
    }
    return null;
  }

  void _recalcularMateriales(List<Excursion> excursiones) {
    final Excursion? excursion = _buscarExcursionSeleccionada(excursiones);
    if (excursion == null) {
      setState(() => _controller.materialesSolicitados = {});
      return;
    }
    setState(() {
      _controller.recalcularMaterialesDesdePlantilla(
        excursion.materialesPorParticipante,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = SolicitudFormController();
    if (widget.solicitud != null) {
      _controller.cargarSolicitud(widget.solicitud!);
      if (widget.initialIdUsuario != null) {
        _controller.idUsuario = widget.initialIdUsuario;
      }
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
        _recalcularMateriales(ref.read(excursionesProvider));
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
    final List<Excursion> excursiones = ref.watch(excursionesProvider);
    final List<Equipamiento> equipamientos = ref.watch(equipamientosProvider);
    final Usuario? usuarioActual = ref.watch(currentUserProvider);

    final bool modoCliente = widget.initialIdUsuario != null;
    final int? idUsuarioFijado = widget.initialIdUsuario ?? usuarioActual?.id;

    List<Usuario> usuariosDisponibles = ref.read(usuariosProvider);
    if (modoCliente && idUsuarioFijado != null) {
      usuariosDisponibles = usuariosDisponibles
          .where((Usuario u) => u.id == idUsuarioFijado)
          .toList();
    }

    final Excursion? excursionSeleccionada = _buscarExcursionSeleccionada(
      excursiones,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar solicitud' : 'Nueva solicitud'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.inverseSurface, cs.primary],
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
              onChanged: (int? val) {
                if (modoCliente) {
                  return;
                }
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
              onChanged: (int? v) {
                setState(() => _controller.idExcursion = v);
                _recalcularMateriales(excursiones);
              },
            ),

            const SizedBox(height: 20),
            // Participantes
            CustomInputField(
              controller: _controller.participantesCtrl,
              labelText: 'Número de participantes',
              keyboardType: TextInputType.number,
              validator: ValidadoresFormulario.enteroMayorQueCero,
              onChanged: (_) => _recalcularMateriales(excursiones),
            ),

            const SizedBox(height: 20),
            Text(
              'Material recomendado (autocalculado)',
              style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
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

                String nombre = 'Material #$idEquipamiento';
                for (final Equipamiento e in equipamientos) {
                  if (e.id == idEquipamiento) {
                    nombre = e.nombre;
                    break;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(nombre, style: tt.bodyMedium)),
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
                      Text('$cantidad', style: tt.bodyMedium),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () => setState(
                          () => _controller.establecerCantidadMaterial(
                            idEquipamiento,
                            cantidad + 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            if (excursionSeleccionada != null) ...[
              const SizedBox(height: 12),
              if (_controller.idReserva == null)
                SecondaryButton(
                  label: 'Reservar materiales',
                  onPressed: () {
                    final Reserva? reserva = _crearReservaDesdeSolicitud();
                    if (reserva == null) {
                      return;
                    }
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reserva creada correctamente.'),
                      ),
                    );
                  },
                  backgroundColor: cs.secondaryContainer,
                  borderColor: cs.secondary,
                )
              else
                SecondaryButton(
                  label: 'Editar reserva asociada',
                  onPressed: _editarReservaAsociada,
                  backgroundColor: cs.secondaryContainer,
                  borderColor: cs.secondary,
                ),
            ],

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
                items: ref.read(usuariosProvider),
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
            // Guardar
            PrimaryButton(
              label: isEdit ? 'Guardar' : 'Crear',
              onPressed: () {
                // Si hay materiales definidos y no existe reserva asociada, se crea automáticamente.
                final bool tieneMateriales = _controller
                    .materialesSolicitados
                    .values
                    .any((v) => v > 0);
                if (_controller.idReserva == null && tieneMateriales) {
                  final Reserva? reserva = _crearReservaDesdeSolicitud();
                  if (reserva == null) {
                    return;
                  }
                }

                final Solicitud? solicitud = _controller.crearSolicitud();
                if (solicitud == null) {
                  return;
                }
                _sincronizarReservaConSolicitud(solicitud);
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
