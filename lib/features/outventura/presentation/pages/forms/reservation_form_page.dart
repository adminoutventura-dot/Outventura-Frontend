import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_chip.dart';
import 'package:outventura/core/widgets/app_date_selector.dart';
import 'package:outventura/core/widgets/app_excursion_dropdown.dart';
import 'package:outventura/core/widgets/app_user_dropdown.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/domain/entities/equipment.dart';
import 'package:outventura/features/outventura/domain/entities/reservation.dart';
import 'package:outventura/features/outventura/presentation/controllers/reservation_form_controller.dart';
import 'package:outventura/features/outventura/presentation/providers/equipment_provider.dart';
import 'package:outventura/features/outventura/presentation/providers/excursions_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/reservation_line_dialog.dart';

// TODO: Arreglar el tema de los controllers, no es necesario que cada página tenga uno, 
// se pueden compartir y pasar la reserva a cargar como parámetro del método cargarReserva. 
// Revisar también el tema de los dispose, no es necesario que se llame en cada página, 
// con que se llame una vez al cerrar la app es suficiente. (Recordatorio)
class ReservationFormPage extends ConsumerStatefulWidget {
  final Reserva reserva;

  const ReservationFormPage({super.key, required this.reserva});

  @override
  ConsumerState<ReservationFormPage> createState() => _ReservationFormPageState();
}

class _ReservationFormPageState extends ConsumerState<ReservationFormPage> {
  late final ReservationFormController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ReservationFormController();
    _ctrl.cargarReserva(widget.reserva);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Abre un diálogo para anadir o editar una lí­nea de reserva.
  Future<void> _mostrarDialogoLinea({int? index}) async {
    final LineaReserva? linea = index != null ? _ctrl.lineas[index] : null;
    final LineaReserva? result = await mostrarDialogoLineaReserva(
      context: context,
      equipamientos: ref.read(equipamientosProvider),
      initialLinea: linea,
    );

    if (result == null) {
      return;
    }
    setState(() {
      if (index == null) {
        _ctrl.agregarLinea(result);
      } else {
        _ctrl.actualizarLinea(index, result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final List<Equipamiento> equipamientos = ref.watch(equipamientosProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.inverseSurface,
        foregroundColor: cs.onInverseSurface,
        title: Text(
          'Editar reserva #${widget.reserva.id}',
          style: tt.titleMedium?.copyWith(color: cs.onInverseSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _ctrl.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Usuario
              const SizedBox(height: 8),
              AppUserDropdown(
                value: _ctrl.idUsuario,
                users: ref.read(usuariosProvider),
                label: 'Usuario',
                hint: 'Selecciona un usuario',
                onChanged: (int? v) => setState(() => _ctrl.idUsuario = v),
                validator: (int? v) => v == null ? 'Selecciona un usuario' : null,
              ),
              const SizedBox(height: 20),

              //── Excursión (opcional) ──────────────────────────
              AppExcursionDropdown(
                value: _ctrl.idExcursion,
                excursiones: ref.read(excursionesProvider),
                onChanged: (int? v) => setState(() => _ctrl.idExcursion = v),
              ),
              const SizedBox(height: 20),

              // ── Fechas ────────────────────────────────────────
              Text('Fechas', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppDateSelector(
                      label: 'Desde',
                      date: _ctrl.fechaDesde ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      onDateSelected: (DateTime d) => setState(() => _ctrl.fechaDesde = d),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppDateSelector(
                      label: 'Hasta',
                      date: _ctrl.fechaHasta ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      onDateSelected: (DateTime d) => setState(() => _ctrl.fechaHasta = d),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Lienas de Reserva
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Líneas de reserva', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                  TextButton.icon(
                    onPressed: () => _mostrarDialogoLinea(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Añadir'),
                  ),
                ],
              ),
              if (_ctrl.lineas.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Sin materiales. Añade al menos uno.',
                    style: tt.bodySmall?.copyWith(color: cs.error),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ctrl.lineas.length,
                  itemBuilder: (_, int i) {
                    final LineaReserva linea = _ctrl.lineas[i];

                    // Buscar el equipamiento que corresponde a esta línea.
                    Equipamiento mat = equipamientos.first;
                    for (final Equipamiento m in equipamientos) {
                      if (m.id == linea.idEquipamiento) {
                        mat = m;
                        break;
                      }
                    }

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.inventory_2_outlined, color: cs.primary),
                      title: Text(mat.nombre, style: tt.bodyMedium),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('x${linea.cantidad}', style: tt.labelMedium?.copyWith(color: cs.onPrimaryContainer)),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_outlined, size: 18, color: cs.onSurfaceVariant),
                            onPressed: () => _mostrarDialogoLinea(index: i),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
                            onPressed: () => setState(() => _ctrl.eliminarLinea(i)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),

              // ── Estado ────────────────────────────────────────
              Text('Estado', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 8),
              AppChipWrap(
                children: EstadoReserva.values.map((EstadoReserva e) {
                  final bool seleccionado = _ctrl.estado == e;
                  return AppChoiceChip(
                    label: e.label,
                    seleccionado: seleccionado,
                    onSelected: (_) => setState(() => _ctrl.estado = e),
                    selectedColor: cs.secondaryContainer,
                    selectedBorderColor: cs.tertiary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // ── Daños por material ────────────────────────────
              if (_ctrl.lineas.isNotEmpty) ...[
                Text('Daños por material', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 4),
                ...List.generate(_ctrl.lineas.length, (int i) {
                  final LineaReserva linea = _ctrl.lineas[i];

                  // Buscar el equipamiento que corresponde a esta línea.
                  Equipamiento mat = equipamientos.first;
                  for (final Equipamiento m in equipamientos) {
                    if (m.id == linea.idEquipamiento) {
                      mat = m;
                      break;
                    }
                  }

                  final int daniadas = _ctrl.cantidadDaniada(linea.idEquipamiento);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mat.nombre, style: tt.bodyMedium),
                              Text(
                                '${mat.cargoPorDanio.toStringAsFixed(2)} €/ud.',
                                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: daniadas > 0
                              ? () => setState(() => _ctrl.establecerCantidadDaniada(linea.idEquipamiento, daniadas - 1))
                              : null,
                        ),
                        Text('$daniadas / ${linea.cantidad}', style: tt.bodyMedium),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: daniadas < linea.cantidad
                              ? () => setState(() => _ctrl.establecerCantidadDaniada(linea.idEquipamiento, daniadas + 1))
                              : null,
                        ),
                        SizedBox(
                          width: 64,
                          child: daniadas > 0
                              ? Text(
                                  '${(daniadas * mat.cargoPorDanio).toStringAsFixed(2)} €',
                                  style: tt.labelMedium?.copyWith(color: cs.error),
                                  textAlign: TextAlign.end,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  );
                }),
                if (_ctrl.totalCargoDanios > 0) ...[
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total daños', style: tt.labelMedium),
                      Text(
                        '${_ctrl.totalCargoDanios.toStringAsFixed(2)} €',
                        style: tt.labelMedium?.copyWith(color: cs.error, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: 32),

              // ── Botones ───────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancelar',
                      onPressed: () => Navigator.of(context).pop(),
                      backgroundColor: cs.onError,
                      borderColor: cs.error,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Guardar',
                      icon: Icons.save_outlined,
                      onPressed: () {
                        if (_ctrl.lineas.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('AÃ±ade al menos una lÃ­nea de reserva.')),
                          );
                          return;
                        }
                        final Reserva? reserva = _ctrl.crearReserva();
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

