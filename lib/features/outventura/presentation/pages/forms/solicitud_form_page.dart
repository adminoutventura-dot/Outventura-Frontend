import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/enum_translations.dart';
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
import 'package:outventura/features/outventura/domain/entities/workflow_status.dart';
import 'package:outventura/features/outventura/presentation/controllers/request_form_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/activities_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/resolvers_provider.dart';

class SolicitudFormPage extends ConsumerStatefulWidget {
  final Booking? reserva;
  final int? initialIdActividad;
  final int? initialIdUsuario;

  const SolicitudFormPage({
    super.key,
    this.reserva,
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

    if (widget.reserva != null) {
      _controller.cargarReservaUnificada(widget.reserva!);
      if (widget.initialIdUsuario != null) {
        _controller.idUsuario = widget.initialIdUsuario;
      }
    } else {
      _controller.aplicarValoresIniciales(
        idActividad: widget.initialIdActividad,
        idUsuario: widget.initialIdUsuario,
      );
    }

    if (widget.reserva == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(
          () => _controller.recalcularMateriales(
            ref.read(activitiesProvider).value ?? [],
          ),
        );
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
    final bool isEdit = widget.reserva != null;
    final List<Activity> actividades =
        ref.watch(activitiesProvider).value ?? [];
    final List<Equipment> equipamientos =
        ref.watch(equipmentProvider).value ?? [];
    final bool modoCliente = widget.initialIdUsuario != null;

    final List<User> usuariosDisponibles = !modoCliente
        ? ref.watch(clientesProvider).value ?? []
        : switch (ref.watch(currentUserProvider)) {
            final User u => [u],
            null => [],
          };

    final List<Activity> actividadesDisponibles =
        ref.watch(availableActivitiesProvider).value ?? [];
    final Activity? actividadSeleccionada = _controller
        .buscarActividadSeleccionada(actividades);

    // Calcula el precio dinámico usando el método correcto de este controlador
    final double totalPrice = _controller.calcularPrecioTotal(
      actividades,
      equipamientos,
    );

    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight;
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
          final Booking? resultado = _controller.construirReservaDirecta(
            actividades,
          );
          if (resultado == null) {
            showErrorSnackBar(context, s.fieldRequired);
            return;
          }
          Navigator.of(context).pop(resultado);
        },
      ),
      body: Form(
        key: _controller.formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            topPadding + 40,
            20,
            bottomBarHeight + 24,
          ),
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
              items: actividadesDisponibles,
              itemValue: (e) => e.id,
              itemLabel: (e) => e.title,
              prefixIcon: Icons.hiking_outlined,
              label: s.actividad,
              hint: s.selectActividad,
              isRequired: true,
              enabled: !isEdit || !modoCliente,
              onChanged: (int? v) {
                setState(() {
                  _controller.idActividad = v;
                  _controller.recalcularMateriales(actividadesDisponibles);
                });
              },
            ),
            const SizedBox(height: 20),

            CustomInputField(
              controller: _controller.participantesCtrl,
              labelText: s.numberOfParticipants,
              keyboardType: TextInputType.number,
              onChanged: (_) =>
                  setState(() => _controller.recalcularMateriales(actividades)),
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
                        setState(() {
                          _controller.recalcularMateriales(actividades);
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
              else if (actividadSeleccionada.recommendedEquipmentIds.isEmpty)
                Text(
                  s.noRecommendedMaterial,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                )
              else
                ..._controller.materialesSolicitados.entries.map((entry) {
                  final int idEquipamiento = entry.key;
                  final int cantidad = entry.value;
                  final String nombre = ref.watch(
                    equipmentNameProvider(idEquipamiento),
                  );
                  final Equipment? item = ref.watch(
                    equipmentByIdProvider(idEquipamiento),
                  );
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
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
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
                          onPressed: () {
                            Equipment? eq;
                            try {
                              eq = equipamientos.firstWhere(
                                (e) => e.id == idEquipamiento,
                              );
                            } catch (_) {}
                            if (eq != null && cantidad >= eq.totalUnits) {
                              showErrorSnackBar(
                                context,
                                s.insufficientStock(
                                  eq.totalUnits,
                                  idEquipamiento,
                                ),
                              );
                              return;
                            }
                            setState(
                              () => _controller.establecerCantidadMaterial(
                                idEquipamiento,
                                cantidad + 1,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: cs.error,
                          ),
                          onPressed: () => setState(
                            () => _controller.materialesSolicitados.remove(
                              idEquipamiento,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ] else if (isEdit &&
                actividadSeleccionada != null &&
                actividadSeleccionada.recommendedEquipmentIds.isNotEmpty) ...[
              TertiaryButton(
                label: s.addMaterials,
                icon: Icons.add,
                onPressed: () => setState(() {
                  _mostrarMateriales = true;
                  _controller.recalcularMateriales(actividades);
                }),
              ),
            ],

            const SizedBox(height: 20),
            if (!modoCliente) ...[
              Text(
                s.status.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              AppChipWrap(
                children: WorkflowStatus.values.map((WorkflowStatus est) {
                  return AppChoiceChip(
                    label: est.localizedLabel(s),
                    seleccionado: _controller.estado == est,
                    onPressed: () => setState(() => _controller.estado = est),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
