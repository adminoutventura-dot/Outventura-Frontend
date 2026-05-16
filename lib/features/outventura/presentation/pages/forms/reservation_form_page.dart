import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_bar_forms.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/core/widgets/app_date_selector.dart';
import 'package:outventura/core/widgets/app_time_selector.dart';
import 'package:outventura/core/widgets/app_dropdown_field.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/controllers/reservation_form_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_line_card.dart';
import 'package:outventura/core/widgets/bottom_price_bar.dart';

class ReservationFormPage extends ConsumerStatefulWidget {
  final Reservation? reserva;
  final int? initialIdUsuario;
  final int? initialIdActividad;
  final int? initialIdEquipamiento;
  final int initialCantidadEquipamiento;

  const ReservationFormPage({
    super.key,
    this.reserva,
    this.initialIdUsuario,
    this.initialIdActividad,
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
        idActividad: widget.initialIdActividad,
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
      equipamientos: ref.read(equipmentProvider).value ?? [],
      setState: setState,
      index: index,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final List<Equipment> equipamientos = ref.watch(equipmentProvider).value ?? [];
    final User? usuarioActual = ref.watch(currentUserProvider);
    final bool modoCliente = widget.initialIdUsuario != null;
    final int? idUsuarioFijado = widget.initialIdUsuario ?? usuarioActual?.id;
    final double totalPrice = _controller.totalAlquiler(equipamientos) + _controller.totalCargoDanios(equipamientos);

    List<User> usuariosDisponibles = ref.read(usuariosProvider).value ?? [];
    if (modoCliente && idUsuarioFijado != null) {
      usuariosDisponibles = usuariosDisponibles
          .where((User u) => u.id == idUsuarioFijado)
          .toList();
    }

    // --- CÁLCULO DE ALTURAS PARA EL TRASPASO DE BARS ---
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;
    // Estimación estándar para el BottomPriceBar (puedes ajustarlo si mide diferente)
    final double bottomBarHeight = MediaQuery.of(context).padding.bottom + 100;


    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: cs.surface,
      appBar: CustomAppBarForm(title: widget.reserva != null ? s.editReservation(widget.reserva!.id) : s.newReservation),
      bottomNavigationBar: BottomPriceBar(
        totalLabel: s.total,
        price: s.priceEur(totalPrice.toStringAsFixed(2)),
        actionLabel: s.save,
        onPressed: () {
          if (_controller.lineas.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(s.addAtLeastOneLine)),
            );
            return;
          }
          final Reservation? reserva = _controller.crearReserva(equipamientos);
          if (reserva == null) return;
          Navigator.of(context).pop(reserva);
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, bottomBarHeight + 24),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Usuario
              const SizedBox(height: 8),
              AppDropdownField<User>(
                value: _controller.idUsuario,
                items: usuariosDisponibles,
                itemValue: (User user) => user.id,
                itemLabel: (User user) => '${user.name} ${user.surname}',
                label: s.user,
                hint: modoCliente ? s.yourUser : s.selectUser,
                enabled: !modoCliente,
                onChanged: (int? v) {
                  if (modoCliente) return;
                  setState(() => _controller.idUsuario = v);
                },
                validator: (int? v) {
                  if (v == null) {
                    return s.selectUser;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Excursión (siempre visible; editable si no es modo cliente)
              AppDropdownField<Activity>(
                value: _controller.idActividad,
                items: ref.read(activitiesProvider).value ?? [],
                itemValue: (e) => e.id,
                itemLabel: (e) => '${e.startPoint} → ${e.endPoint}',
                prefixIcon: Icons.hiking_outlined,
                label: s.actividad,
                hint: s.none,
                enabled: !modoCliente,
                onChanged: (int? v) =>
                    setState(() => _controller.idActividad = v),
                validator: (int? v) {
                  if (v == null) return s.selectActividad;
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Fechas
              Text(
                s.dates,
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppDateSelector(
                      label: s.from,
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
                      label: s.to,
                      date: _controller.fechaHasta,
                      firstDate: _controller.fechaDesde,
                      lastDate: DateTime(2030),
                      onDateSelected: (DateTime d) =>
                          setState(() => _controller.fechaHasta = d),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Horas
              Row(
                children: [
                  Expanded(
                    child: AppTimeSelector(
                      label: s.startTime,
                      time: _controller.horaInicio,
                      onTimeSelected: (TimeOfDay t) =>
                          setState(() => _controller.horaInicio = t),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTimeSelector(
                      label: s.endTime,
                      time: _controller.horaFin,
                      onTimeSelected: (TimeOfDay t) =>
                          setState(() => _controller.horaFin = t),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Estado (solo visible para trabajadores)
              if (!modoCliente) ...[
                Text(
                s.status,
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
                const SizedBox(height: 8),
                AppChipWrap(
                  children: ReservationStatus.values.map((ReservationStatus e) {
                    final bool seleccionado = _controller.estado == e;
                    return AppChoiceChip(
                      label: e.localizedLabel(s),
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
                    s.reservationLines,
                    style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  TertiaryButton(
                    label: s.add,
                    icon: Icons.add,
                    onPressed: () => _mostrarDialogoLinea(),
                  ),
                ],
              ),
              if (_controller.lineas.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    s.noMaterials,
                    style: tt.bodySmall?.copyWith(color: cs.error),
                  ),
                )
              else
                for (int i = 0; i < _controller.lineas.length; i++) ...[
                  Builder(
                    builder: (_) {
                      final ReservationLine linea = _controller.lineas[i];

                      Equipment equip = equipamientos.first;
                      for (final Equipment eq in equipamientos) {
                        if (eq.id == linea.equipmentId) {
                          equip = eq;
                          break;
                        }
                      }

                      final int daniadas = _controller.cantidadDaniada(linea.equipmentId);
                      
                      return ReservationLineCard(
                        linea: linea,
                        equipamiento: equip,
                        cantidadDaniada: daniadas,
                        esCliente: modoCliente,
                        onEdit: () => _mostrarDialogoLinea(index: i),
                        onDelete: () => setState(() => _controller.eliminarLinea(i)),
                        menosCoste: daniadas > 0
                            ? () => setState(
                                  () => _controller.establecerCantidadDaniada(
                                    linea.equipmentId,
                                    daniadas - 1,
                                  ),
                                )
                            : null,
                        masCoste: daniadas < linea.quantity
                            ? () => setState(
                                  () => _controller.establecerCantidadDaniada(
                                    linea.equipmentId,
                                    daniadas + 1,
                                  ),
                                )
                            : null,
                      );
                    },
                  ),
                ],

              const Divider(),
              
              // Daños
              if (_controller.lineas.isNotEmpty) ...[
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.total, style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer)),
                      Text(
                        s.priceEur(
                          (_controller.totalAlquiler(equipamientos) + _controller.totalCargoDanios(equipamientos)).toStringAsFixed(2),
                        ),
                        style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer),
                      ),

                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),

              // Botón de borrar (solo en modo edición)
              if (widget.reserva != null) ...[
                const SizedBox(height: 20),
                SecondaryButton(
                  label: s.deleteReservation,
                  onPressed: () async {
                    final bool confirmar = await showConfirmDialog(
                      context: context,
                      title: s.deleteReservation,
                      content: s.deleteReservationConfirm,
                      confirmLabel: s.deleteReservation,
                    );
                    if (confirmar && context.mounted) {
                      ref.read(reservationsProvider.notifier).eliminar(widget.reserva!);
                      Navigator.of(context).pop();
                    }
                  },
                  borderColor: cs.error,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
