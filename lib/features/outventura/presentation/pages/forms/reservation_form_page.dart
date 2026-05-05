import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/core/widgets/app_date_selector.dart';
import 'package:outventura/core/widgets/app_dropdown_field.dart';
import 'package:outventura/features/outventura/domain/entities/excursion.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/controllers/reservation_form_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_line_card.dart';

class ReservationFormPage extends ConsumerStatefulWidget {
  final Reserva? reserva;
  final int? initialIdUsuario;
  final int? initialIdExcursion;
  final int? initialIdEquipamiento;
  final int initialCantidadEquipamiento;

  const ReservationFormPage({
    super.key,
    this.reserva,
    this.initialIdUsuario,
    this.initialIdExcursion,
    this.initialIdEquipamiento,
    this.initialCantidadEquipamiento = 1,
  });

  @override
  ConsumerState<ReservationFormPage> createState() =>
      _ReservationFormPageState();
}

class _ReservationFormPageState extends ConsumerState<ReservationFormPage> {
  late final ReservationFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReservationFormController();
    // Si se ha pasado una reserva, cargar sus datos en el controlador.
    if (widget.reserva != null) {
      _controller.cargarReserva(widget.reserva!);
      if (widget.initialIdUsuario != null) {
        _controller.idUsuario = widget.initialIdUsuario;
      }

      // Si no, aplicar valores iniciales (como el idUsuario).
    } else {
      _controller.aplicarValoresIniciales(
        idUsuario: widget.initialIdUsuario,
        idExcursion: widget.initialIdExcursion,
        idEquipamiento: widget.initialIdEquipamiento,
        cantidadEquipamiento: widget.initialCantidadEquipamiento,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Abre un diálogo para anadir o editar una lí­nea de reserva.
  Future<void> _mostrarDialogoLinea({int? index}) async {
    await _controller.mostrarDialogoLinea(
      context: context,
      equipamientos: ref.read(equipamientosProvider).value ?? [],
      setState: setState,
      index: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final List<Equipamiento> equipamientos = ref.watch(equipamientosProvider).value ?? [];
    final Usuario? usuarioActual = ref.watch(currentUserProvider);
    final bool modoCliente = widget.initialIdUsuario != null;
    final int? idUsuarioFijado = widget.initialIdUsuario ?? usuarioActual?.id;

    List<Usuario> usuariosDisponibles = ref.read(usuariosProvider).value ?? [];
    if (modoCliente && idUsuarioFijado != null) {
      usuariosDisponibles = usuariosDisponibles
          .where((Usuario u) => u.id == idUsuarioFijado)
          .toList();
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(widget.reserva != null ? 'Editar reserva #${widget.reserva!.id}' : 'Nueva reserva'),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB( 20, 20, 20, MediaQuery.of(context).padding.bottom + 24),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Usuario
              const SizedBox(height: 8),
              AppDropdownField<Usuario>(
                value: _controller.idUsuario,
                items: usuariosDisponibles,
                itemValue: (Usuario user) => user.id,
                itemLabel: (Usuario user) => '${user.nombre} ${user.apellidos}',
                label: 'Usuario',
                hint: modoCliente ? 'Tu usuario' : 'Selecciona un usuario',
                enabled: !modoCliente && widget.reserva == null,

                // id usuario es = v, significa que se ha seleccionado un usuario, si es null, no se ha seleccionado ninguno.
                // v es el id del usuario seleccionado.
                onChanged: (int? v) {
                  if (modoCliente) {
                    return;
                  }
                  setState(() => _controller.idUsuario = v);
                },
                validator: (int? v) {
                  if (v == null) {
                    return 'Selecciona un usuario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Excursión (solo editable para administradores; visible en modo edición)
              if (!modoCliente || widget.reserva != null) ...[
                AppDropdownField<Excursion>(
                  value: _controller.idExcursion,
                  items: ref.read(excursionesProvider).value ?? [],
                  itemValue: (e) => e.id,
                  itemLabel: (e) => '${e.puntoInicio} → ${e.puntoFin}',
                  prefixIcon: Icons.hiking_outlined,
                  label: 'Excursión',
                  hint: 'Ninguna',
                  enabled: !modoCliente && widget.reserva == null,
                  onChanged: (int? v) =>
                      setState(() => _controller.idExcursion = v),
                  validator: (int? v) {
                    if (v == null) {
                      return 'Selecciona una Excursión';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Fechas
              Text(
                'Fechas',
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppDateSelector(
                      label: 'Desde',
                      date: _controller.fechaDesde,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      onDateSelected: (DateTime d) => setState(() {
                        _controller.fechaDesde = d;
                        if (_controller.fechaHasta.isBefore(d)) {
                          _controller.fechaHasta = d;
                        }
                      }),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppDateSelector(
                      label: 'Hasta',
                      date: _controller.fechaHasta,
                      firstDate: _controller.fechaDesde,
                      lastDate: DateTime(2030),
                      onDateSelected: (DateTime d) =>
                          setState(() => _controller.fechaHasta = d),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Estado (solo visible para trabajadores)
              if (!modoCliente) ...[
                Text(
                  'Estado',
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                AppChipWrap(
                  children: EstadoReserva.values.map((EstadoReserva e) {
                    final bool seleccionado = _controller.estado == e;
                    return AppChoiceChip(
                      label: e.label,
                      seleccionado: seleccionado,
                      onSelected: (_) => setState(() => _controller.estado = e),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Lineas de Reserva
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Líneas de reserva',
                    style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  TertiaryButton(
                    label: 'Añadir',
                    icon: Icons.add,
                    onPressed: () => _mostrarDialogoLinea(),
                  ),
                ],
              ),
              if (_controller.lineas.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Sin materiales.',
                    style: tt.bodySmall?.copyWith(color: cs.error),
                  ),
                )
              else
                ListView.builder(
                  // Hace que el ListView solo ocupe el espacio necesario para mostrar sus hijos.
                  shrinkWrap: true,
                  // Desactiva el scroll del ListView, para que el scroll lo maneje el SingleChildScrollView.
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _controller.lineas.length,
                  itemBuilder: (_, int i) {
                    final LineaReserva linea = _controller.lineas[i];

                    // Buscar el equipamiento que corresponde a esta línea.
                    Equipamiento equip = equipamientos.first;
                    for (final Equipamiento eq in equipamientos) {
                      if (eq.id == linea.idEquipamiento) {
                        equip = eq;
                        break;
                      }
                    }

                    final int daniadas = _controller.cantidadDaniada(
                      linea.idEquipamiento,
                    );
                    // Card de la línea de reserva
                    return ReservationLineCard(
                      linea: linea,
                      equipamiento: equip,
                      cantidadDaniada: daniadas,
                      onEdit: () => _mostrarDialogoLinea(index: i),
                      onDelete: () =>
                          setState(() => _controller.eliminarLinea(i)),
                      menosCoste: daniadas > 0
                          ? () => setState(
                              () => _controller.establecerCantidadDaniada(
                                linea.idEquipamiento,
                                daniadas - 1,
                              ),
                            )
                          : null,
                      masCoste: daniadas < linea.cantidad
                          ? () => setState(
                              () => _controller.establecerCantidadDaniada(
                                linea.idEquipamiento,
                                daniadas + 1,
                              ),
                            )
                          : null,
                    );
                  },
                ),

              // Total cargos por daños
              if (_controller.totalCargoDanios(equipamientos) > 0) ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total daños', style: tt.labelMedium),
                    Text(
                      '${_controller.totalCargoDanios(equipamientos).toStringAsFixed(2)} €',
                      style: tt.labelMedium?.copyWith(color: cs.error),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 32),

              // Botones: Borrar reserva (si edición) + Guardar en la misma fila
              Row(
                children: [
                  if (widget.reserva != null) ...[
                    Expanded(
                      child: SecondaryButton(
                        label: 'Borrar reserva',
                        onPressed: () async {
                          final bool confirmar = await showConfirmDialog(
                            context: context,
                            title: 'Borrar reserva',
                            content: '¿Estás seguro de que quieres borrar esta reserva? Esta acción no se puede deshacer.',
                            confirmLabel: 'Borrar',
                          );
                          if (confirmar && context.mounted) {
                            ref.read(reservasProvider.notifier).eliminar(widget.reserva!);
                            Navigator.of(context).pop();
                          }
                        },
                        borderColor: cs.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: PrimaryButton(
                      label: 'Guardar',
                      icon: Icons.save_outlined,
                      onPressed: () {
                        if (_controller.lineas.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Añade al menos una línea de reserva.',
                              ),
                            ),
                          );
                          return;
                        }
                        final Reserva? reserva = _controller.crearReserva(equipamientos);
                        if (reserva == null) {
                          return;
                        }
                        Navigator.of(context).pop(reserva);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
