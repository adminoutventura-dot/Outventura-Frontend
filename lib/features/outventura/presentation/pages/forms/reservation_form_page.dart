import 'package:flutter/material.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_bar_forms.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/core/widgets/app_date_selector.dart';
import 'package:outventura/core/widgets/app_time_selector.dart';
import 'package:outventura/core/widgets/app_dropdown_field.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/presentation/controllers/reservation_form_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/reservations_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_line_card.dart';
import 'package:outventura/core/widgets/bottom_price_bar.dart';

class ReservationFormPage extends ConsumerStatefulWidget {
  final Booking? reserva;
  final int? initialIdUsuario;
  final int? initialIdEquipamiento;
  final int initialCantidadEquipamiento;

  const ReservationFormPage({
    super.key,
    this.reserva,
    this.initialIdUsuario,
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

    if (widget.reserva != null) {
      _controller.cargarReserva(widget.reserva!);
      if (widget.initialIdUsuario != null) {
        _controller.idUsuario = widget.initialIdUsuario;
      }
    } else {
      _controller.aplicarValoresIniciales(
        idUsuario: widget.initialIdUsuario,
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
    final bool isEdit = widget.reserva != null;
    final List<Equipment> equipamientos =
        ref.watch(equipmentProvider).value ?? [];
    final bool modoCliente = widget.initialIdUsuario != null;

    final double totalPrice = _controller.totalAlquiler(equipamientos);
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight;
    final double bottomBarHeight = MediaQuery.of(context).padding.bottom + 100;

    final List<User> usuariosDisponibles = modoCliente
        ? switch (ref.watch(currentUserProvider)) {
            final User u => [u],
            null => [],
          }
        : ref.watch(clientesProvider).value ?? [];

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: cs.surface,
      appBar: CustomAppBarForm(
        title: isEdit ? s.editReservation : s.newReservation,
      ),
      bottomNavigationBar: BottomPriceBar(
        totalLabel: s.total,
        price: s.priceEur(totalPrice.toStringAsFixed(2)),
        actionLabel: isEdit ? s.save : s.create,
        onPressed: () {
          if (_controller.lineas.isEmpty) {
            showErrorSnackBar(context, s.addAtLeastOneLine);
            return;
          }
          final Booking? reserva = _controller.crearEditarReserva(
            equipamientos,
          );
          if (reserva == null) {
            showErrorSnackBar(context, s.fieldRequired);
            return;
          }
          Navigator.of(context).pop(reserva);
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          topPadding + 40,
          20,
          bottomBarHeight + 24,
        ),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.reservationDataSection.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
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
                validator: modoCliente
                    ? null
                    : (int? v) {
                        if (v == null) return s.selectUser;
                        return null;
                      },
              ),
              const SizedBox(height: 20),

              Text(
                s.dates.toUpperCase(),
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

              if (!modoCliente) ...[
                Text(
                  s.status.toUpperCase(),
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                AppChipWrap(
                  children: WorkflowStatus.values.map((WorkflowStatus e) {
                    final bool seleccionado = _controller.estado == e;
                    return AppChoiceChip(
                      label: e.localizedLabel(s),
                      seleccionado: seleccionado,
                      onPressed: () => setState(() => _controller.estado = e),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.reservationLines.toUpperCase(),
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
                      final BookingLine linea = _controller.lineas[i];
                      if (linea.equipmentId == null) {
                        return const SizedBox.shrink();
                      }

                      final Equipment equip =
                          ref.watch(
                            equipmentByIdProvider(linea.equipmentId!),
                          ) ??
                          equipamientos.first;

                      return ReservationLineCard(
                        linea: linea,
                        equipamiento: equip,
                        cantidadDaniada: 0,
                        esCliente: modoCliente,
                        onEdit: () => _mostrarDialogoLinea(index: i),
                        onDelete: () =>
                            setState(() => _controller.eliminarLinea(i)),
                        menosCoste: null,
                        masCoste: null,
                      );
                    },
                  ),
                ],

              const Divider(),
              if (_controller.lineas.isNotEmpty) ...[
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.total,
                        style: tt.labelMedium?.copyWith(
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        s.priceEur(
                          _controller
                              .totalAlquiler(equipamientos)
                              .toStringAsFixed(2),
                        ),
                        style: tt.labelMedium?.copyWith(
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              if (isEdit && !modoCliente) ...[
                const SizedBox(height: 20),
                SecondaryButton(
                  label: s.deleteReservation,
                  onPressed: () async {
                    final bool confirmar = await showConfirmDialog(
                      context: context,
                      title: s.deleteReservation,
                      content:
                          '${s.deleteReservationConfirm}\n\n'
                          '⚠️ ¡Atención! Al eliminar esta reserva se borrarán permanentemente todas sus líneas de materiales asociadas.',
                      confirmLabel: s.deleteReservation,
                    );
                    if (confirmar && context.mounted) {
                      ref
                          .read(reservationsProvider.notifier)
                          .eliminar(widget.reserva!);
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
