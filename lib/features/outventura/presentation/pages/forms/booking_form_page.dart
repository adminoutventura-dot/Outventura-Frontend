import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/presentation/widgets/booking_line_dialog.dart';
import 'package:table_calendar/table_calendar.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/core/widgets/app_bar_forms.dart';
import 'package:outventura/core/widgets/app_dropdown_field.dart'; 
import 'package:outventura/core/widgets/app_date_selector.dart';    
import 'package:outventura/core/widgets/app_time_selector.dart';    
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/booking.dart';
import 'package:outventura/features/outventura/domain/entities/activity.dart'; 
import 'package:outventura/features/auth/domain/entities/guide.dart';
import 'package:outventura/features/auth/presentation/providers/guides_provider.dart';
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/presentation/controllers/booking_mat_form_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart'; 
import 'package:outventura/features/outventura/presentation/providers/booking_provider.dart';
import 'package:outventura/core/widgets/bottom_price_bar.dart';
import 'package:outventura/features/outventura/presentation/widgets/booking_line_card.dart';

class BookingFormPage extends ConsumerStatefulWidget {
  final Booking? booking;
  final int? initialIdUsuario;
  final int? initialIdEquipamiento;
  final int? initialIdActividad; 
  final int initialCantidadEquipamiento;

  const BookingFormPage({
    super.key,
    this.booking,
    this.initialIdUsuario,
    this.initialIdEquipamiento,
    this.initialIdActividad,
    this.initialCantidadEquipamiento = 1,
  });

  @override
  ConsumerState<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends ConsumerState<BookingFormPage> {
  late final BookingMatFormController _controller;
  late final TextEditingController _participantsController; // Controlador para los participantes
  
  int? _selectedActivityId;
  bool _syncedInitialActivity = false;
  final Map<int, int> _cantidadesDaniadas = {};

  @override
  void initState() {
    super.initState();
    _controller = BookingMatFormController();
    _participantsController = TextEditingController(text: '1'); // 1 participante por defecto

    if (widget.booking != null) {
      _controller.cargarReserva(widget.booking!);
      if (widget.initialIdUsuario != null) {
        _controller.idUsuario = widget.initialIdUsuario;
      }
      
      final actLine = widget.booking!.lines.where((l) => l.activityId != null).firstOrNull;
      if (actLine != null) {
        _selectedActivityId = actLine.activityId;
        _participantsController.text = actLine.quantity.toString(); // Cargar los participantes de la BD
      }
    } else {
      _controller.aplicarValoresIniciales(
        idUsuario: widget.initialIdUsuario,
        idEquipamiento: widget.initialIdEquipamiento,
        cantidadEquipamiento: widget.initialCantidadEquipamiento,
      );
      
      if (widget.initialIdActividad != null) {
        _selectedActivityId = widget.initialIdActividad;
      }
    }
  }

  @override
  void dispose() {
    _participantsController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _mostrarDialogoLinea({int? index}) async {
    final BookingLine? lineaActual = index != null ? _controller.lineas[index] : null;

    final BookingLine? resultadoLinea = await mostrarDialogoLineaReserva(
      context: context,
      equipamientos: ref.read(allEquipmentProvider),
      initialLinea: lineaActual,
    );

    if (resultadoLinea == null) return;

    setState(() {
      if (index != null) {
        _controller.lineas[index] = resultadoLinea;
      } else {
        _controller.lineas.add(resultadoLinea);
      }
    });
  }

  // Actualiza la cantidad en la línea de reserva cuando el usuario escribe
  void _onParticipantsChanged(String val) {
    int qty = int.tryParse(val) ?? 1;
    if (qty < 1) qty = 1; // Para evitar que pongan 0 o negativos
    
    setState(() {
      final index = _controller.lineas.indexWhere((l) => l.activityId != null);
      if (index != -1) {
        final oldLine = _controller.lineas[index];
        // Usamos tu método copyWith para actualizar solo la cantidad de forma limpia
        _controller.lineas[index] = oldLine.copyWith(quantity: qty);
      }
    });
  }

  void _onActivityChanged(int? newActivityId, List<Activity> actividades) {
    setState(() {
      _selectedActivityId = newActivityId;
      _controller.lineas.removeWhere((l) => l.activityId != null);

      if (newActivityId != null) {
        final act = actividades.where((a) => a.id == newActivityId).firstOrNull;
        if (act != null) {
          _controller.fechaDesde = act.initDate.toLocal();
          _controller.fechaHasta = act.endDate.toLocal();
          _controller.horaInicio = TimeOfDay.fromDateTime(act.initDate.toLocal());
          _controller.horaFin = TimeOfDay.fromDateTime(act.endDate.toLocal());

          // Recuperamos lo que haya en el input para crear la línea inicial
          int qty = int.tryParse(_participantsController.text) ?? 1;
          if (qty < 1) qty = 1;

          _controller.lineas.add(BookingLine(activityId: newActivityId, quantity: qty, priceAtMoment: 0));
        }
      }
    });
  }

  void _incrementarDanio(int lineId, int maxCantidad) {
    setState(() {
      final actual = _cantidadesDaniadas[lineId] ?? 0;
      if (actual < maxCantidad) {
        _cantidadesDaniadas[lineId] = actual + 1;
      }
    });
  }

  void _decrementarDanio(int lineId) {
    setState(() {
      final actual = _cantidadesDaniadas[lineId] ?? 0;
      if (actual > 0) {
        _cantidadesDaniadas[lineId] = actual - 1;
      }
    });
  }

  double _calcularTotalDanios(List<Equipment> equipamientos) {
    double total = 0;
    for (final linea in _controller.lineas) {
      if (linea.equipmentId == null) continue;
      final cantidadDaniada = _cantidadesDaniadas[linea.id ?? _controller.lineas.indexOf(linea)] ?? 0;
      if (cantidadDaniada > 0) {
        final equip = equipamientos.where((e) => e.id == linea.equipmentId).firstOrNull;
        if (equip != null) {
          total += cantidadDaniada * equip.damageFee;
        }
      }
    }
    return total;
  }

  bool _esHoraInvalida() {
    if (isSameDay(_controller.fechaDesde, _controller.fechaHasta)) {
      final inicioMinutos = _controller.horaInicio.hour * 60 + _controller.horaInicio.minute;
      final finMinutos = _controller.horaFin.hour * 60 + _controller.horaFin.minute;
      return finMinutos <= inicioMinutos;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    
    final bool isEdit = widget.booking != null;
    final bool modoCliente = widget.initialIdUsuario != null;
    final User? usuarioActual = ref.watch(currentUserProvider);
    final bool esAdminOSuper = usuarioActual?.role.code == 'ADMIN' || usuarioActual?.role.code == 'SUPER';
    final bool esGuia = usuarioActual?.role.code == 'GUIDE';
    final bool mostrarSelectorEstado = (esAdminOSuper || esGuia) && !modoCliente;
    final bool hasActivity = _selectedActivityId != null;

    final bool fechasSoloLectura = isEdit || hasActivity;

    final List<Equipment> equipamientos = ref.watch(allEquipmentProvider);
    final List<Activity> todasLasActividades = ref.watch(activitiesProvider).value ?? [];
    final List<Activity> actividadesDisponibles = ref.watch(availableActivitiesProvider);
    final List<Guide> guias = ref.watch(guidesProvider).value ?? [];
    
    if (_selectedActivityId != null && !isEdit && !_syncedInitialActivity && todasLasActividades.isNotEmpty) {
      final act = todasLasActividades.where((a) => a.id == _selectedActivityId).firstOrNull;
      if (act != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _onActivityChanged(_selectedActivityId, todasLasActividades);
        });
        _syncedInitialActivity = true;
      }
    }

    final double totalPrice = _controller.totalAlquiler(equipamientos) + _calcularTotalDanios(equipamientos);
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;
    final double bottomBarHeight = MediaQuery.of(context).padding.bottom + 100;

    final List<User> todosLosUsuarios = ref.watch(usuariosProvider).value ?? [];
    final List<User> usuariosDisponibles = modoCliente
        ? switch (ref.watch(currentUserProvider)) {
            final User u => [u],
            null => [],
          }
        : todosLosUsuarios.where((u) => u.active == true).toList();

    final Activity? actividadSeleccionada = todasLasActividades.where((a) => a.id == _selectedActivityId).firstOrNull;

    final List<Activity> itemsDropdownActividades = [...actividadesDisponibles];
    if (actividadSeleccionada != null && !itemsDropdownActividades.any((a) => a.id == actividadSeleccionada.id)) {
      itemsDropdownActividades.add(actividadSeleccionada);
    }

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
          if (_esHoraInvalida()) {
            showErrorSnackBar(context, s.endTimeMustBeAfterStart);
            return;
          }

          if (_controller.lineas.isEmpty) {
            showErrorSnackBar(context, s.addAtLeastOneLine);
            return;
          }
          final Booking? bookingModel = _controller.crearEditarReserva(equipamientos);
          if (bookingModel == null) {
            showErrorSnackBar(context, s.fieldRequired);
            return;
          }
          Navigator.of(context).pop(bookingModel);
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, topPadding + 40, 20, bottomBarHeight + 45),
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
                itemValue: (User u) => u.id,
                itemLabel: (User u) => '${u.name} ${u.surname}',
                label: s.user,
                hint: modoCliente ? s.yourUser : s.selectUser,
                enabled: !modoCliente,
                onChanged: (dynamic v) {
                  if (modoCliente) return;
                  setState(() => _controller.idUsuario = v as int?);
                },
                validator: modoCliente
                    ? null
                    : (dynamic v) {
                        if (v == null) return s.selectUser;
                        return null;
                      },
              ),
              const SizedBox(height: 14),

              AppDropdownField<Activity>(
                value: _selectedActivityId,
                items: itemsDropdownActividades, 
                itemValue: (Activity a) => a.id,
                itemLabel: (Activity a) => a.title,
                prefixIcon: Icons.hiking_outlined,
                label: s.linkedActivity,
                hint: s.noneMaterialOnly, 
                enabled: !isEdit,
                onChanged: (dynamic val) => _onActivityChanged(val as int?, todasLasActividades),
              ),

              if (actividadSeleccionada != null) ...[
                Builder(builder: (context) {
                  final guide = guias.where((g) => g.id == actividadSeleccionada.guideId).firstOrNull;
                  if (guide != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: CustomInputField(
                        controller: TextEditingController(text: '${guide.user?.name} ${guide.user?.surname}'),
                        labelText: s.assignedGuide,
                        prefixIcon: Icons.person_outline,
                        enabled: false,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                
                // INPUT DE PARTICIPANTES USANDO TU WIDGET
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: CustomInputField(
                    controller: _participantsController,
                    labelText: 'Participantes', // Si tienes traducción, puedes usar s.participants
                    prefixIcon: Icons.group_outlined,
                    keyboardType: TextInputType.number,
                    onChanged: _onParticipantsChanged,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              Text(
                s.dates.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              
              IgnorePointer(
                ignoring: fechasSoloLectura, 
                child: Opacity(
                  opacity: fechasSoloLectura ? 0.6 : 1.0, 
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppDateSelector(
                              label: s.from,
                              date: _controller.fechaDesde,
                              firstDate: isEdit ? _controller.fechaDesde : DateTime.now().subtract(const Duration(minutes: 5)),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (actividadSeleccionada != null) ...[
                Text(
                  s.recommendedMaterial.toUpperCase(),
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                if (actividadSeleccionada.recommendedEquipmentIds.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      s.noRecommendedMaterial,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  )
                else
                  ...actividadSeleccionada.recommendedEquipmentIds.map((idEq) {
                    final eq = ref.watch(equipmentByIdProvider(idEq));
                    if (eq == null) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: cs.surface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        leading: Icon(Icons.inventory_2_outlined, color: cs.primaryContainer),
                        title: Text(eq.title, style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
                      ),
                    );
                  }),
                const SizedBox(height: 16),
              ],

              if (mostrarSelectorEstado) ...[
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
              
              if (_controller.lineas.where((l) => l.equipmentId != null).isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    s.noMaterials,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
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

                      final int cantidadDaniada = _cantidadesDaniadas[linea.id ?? i] ?? 0;
                      return BookingLineCard(
                        linea: linea,
                        equipamiento: equip,
                        cantidadDaniada: cantidadDaniada,
                        esCliente: modoCliente,
                        onEdit: () => _mostrarDialogoLinea(index: i),
                        onDelete: () => setState(() => _controller.eliminarLinea(i)),
                        menosCoste: () => _decrementarDanio(linea.id ?? i),
                        masCoste: () => _incrementarDanio(linea.id ?? i, linea.quantity),
                      );
                    },
                  ),
                ],

              const Divider(),
              if (_controller.lineas.where((l) => l.equipmentId != null).isNotEmpty) ...[
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
                          (_controller.totalAlquiler(equipamientos) + _calcularTotalDanios(equipamientos))
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
                          '${s.deleteReservationWarning}',
                      confirmLabel: s.deleteReservation,
                    );
                    if (confirmar && context.mounted) {
                      ref
                          .read(reservationsProvider.notifier)
                          .eliminar(widget.booking!);
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