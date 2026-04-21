// import 'package:flutter/material.dart';
// import 'package:outventura/features/outventura/domain/entities/request.dart';

// void showSolicitudDetailSheet({
//   required BuildContext context,
//   required Solicitud solicitud,
//   required VoidCallback onAceptar,
//   required VoidCallback onRechazar,
// }) {
//   final cs = Theme.of(context).colorScheme;
//   final tt = Theme.of(context).textTheme;

//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (_) => DraggableScrollableSheet(
//       expand: false,
//       initialChildSize: 0.55,
//       maxChildSize: 0.9,
//       builder: (_, scrollCtrl) => ListView(
//         controller: scrollCtrl,
//         padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
//         children: [
//           Center(
//             child: Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: cs.onSurfaceVariant.withValues(alpha: 0.3),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Solicitud #${solicitud.id}',
//             style: tt.titleMedium?.copyWith(color: cs.onSurface),
//           ),
//           const SizedBox(height: 12),
//           _DetailRow(
//             icon: Icons.place_outlined,
//             label: 'Ruta',
//             value: '${solicitud.puntoInicio} → ${solicitud.puntoFin}',
//             cs: cs,
//             tt: tt,
//           ),
//           _DetailRow(
//             icon: Icons.calendar_today_outlined,
//             label: 'Inicio',
//             value: _fmt(solicitud.fechaInicio),
//             cs: cs,
//             tt: tt,
//           ),
//           _DetailRow(
//             icon: Icons.event_outlined,
//             label: 'Fin',
//             value: _fmt(solicitud.fechaFin),
//             cs: cs,
//             tt: tt,
//           ),
//           _DetailRow(
//             icon: Icons.group_outlined,
//             label: 'Participantes',
//             value: '${solicitud.numeroParticipantes}',
//             cs: cs,
//             tt: tt,
//           ),
//           if (solicitud.descripcion != null)
//             _DetailRow(
//               icon: Icons.notes_outlined,
//               label: 'Descripción',
//               value: solicitud.descripcion!,
//               cs: cs,
//               tt: tt,
//             ),
//           _DetailRow(
//             icon: Icons.label_outline,
//             label: 'Categorías',
//             value: solicitud.categorias.map((c) => c.nombre).join(', '),
//             cs: cs,
//             tt: tt,
//           ),
//           const SizedBox(height: 20),
//           if (solicitud.estado == EstadoSolicitud.pendiente)
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       onRechazar();
//                     },
//                     icon: Icon(Icons.close, color: cs.error),
//                     label: Text(
//                       'Rechazar',
//                       style: TextStyle(color: cs.error),
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(color: cs.error),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: FilledButton.icon(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       onAceptar();
//                     },
//                     icon: const Icon(Icons.check),
//                     label: const Text('Aceptar'),
//                     style: FilledButton.styleFrom(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     ),
//   );
// }

// String _fmt(DateTime dt) {
//   const m = [
//     'ene',
//     'feb',
//     'mar',
//     'abr',
//     'may',
//     'jun',
//     'jul',
//     'ago',
//     'sep',
//     'oct',
//     'nov',
//     'dic',
//   ];
//   return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
// }

// class _DetailRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final ColorScheme cs;
//   final TextTheme tt;

//   const _DetailRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.cs,
//     required this.tt,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 18, color: cs.primary.withValues(alpha: 0.7)),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
//                 ),
//                 Text(
//                   value,
//                   style: tt.bodyMedium?.copyWith(color: cs.onSurface),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }