// import 'package:flutter/material.dart';
// import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
// import 'package:outventura/features/outventura/presentation/widgets/solicitud_card.dart';
// import 'package:outventura/features/outventura/presentation/widgets/excursion_card.dart';
// import 'package:outventura/features/outventura/data/fakes/solicitudes_fake.dart';
// import 'package:outventura/features/outventura/data/fakes/excursiones_fake.dart';
// import 'package:outventura/features/outventura/data/fakes/materiales_fake.dart';

// class HomeClientePage extends StatelessWidget {
//   const HomeClientePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//     final tt = Theme.of(context).textTheme;

//     final confirmadas = solicitudesFake
//         .where((s) => s.estado.name == 'confirmada')
//         .length;
//     final pendientes = solicitudesFake
//         .where((s) => s.estado.name == 'pendiente')
//         .length;
//     final materialesDisponibles = materialesFake
//         .where((m) => m.estado.name == 'disponible')
//         .length;

//     return Scaffold(
//       backgroundColor: cs.surface,
//       drawer: const AppDrawer(),
//       body: CustomScrollView(
//         slivers: [
//           // ── Header ───────────────────────────────────────────
//           SliverAppBar(
//             expandedHeight: 170,
//             pinned: true,
//             automaticallyImplyLeading: true,
//             backgroundColor: cs.inverseSurface,
//             surfaceTintColor: Colors.transparent,
//             flexibleSpace: FlexibleSpaceBar(
//               collapseMode: CollapseMode.pin,
//               background: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [cs.inverseSurface, cs.primary],
//                   ),
//                 ),
//                 padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Bienvenida de nuevo,',
//                       style: tt.labelMedium?.copyWith(
//                         color: cs.onPrimary.withValues(alpha: 0.6),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Laura',
//                       style: tt.titleLarge?.copyWith(color: cs.onPrimary),
//                     ),
//                     const SizedBox(height: 16),
//                     // Resumen de actividad
//                     Row(
//                       children: [
//                         _StatPill(
//                           value: '${solicitudesFake.length}',
//                           label: 'Solicitudes',
//                           cs: cs,
//                           tt: tt,
//                         ),
//                         const SizedBox(width: 8),
//                         _StatPill(
//                           value: '$confirmadas',
//                           label: 'Confirmadas',
//                           cs: cs,
//                           tt: tt,
//                         ),
//                         const SizedBox(width: 8),
//                         _StatPill(
//                           value: '$pendientes',
//                           label: 'Pendientes',
//                           cs: cs,
//                           tt: tt,
//                           highlight: pendientes > 0,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             title: Text(
//               'Outventura',
//               style: tt.titleMedium?.copyWith(color: cs.onPrimary),
//             ),
//           ),

//           // ── Acciones rápidas ──────────────────────────────────
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
//               child: Row(
//                 children: [
//                   _ActionCard(
//                     icon: Icons.add_location_alt_outlined,
//                     label: 'Solicitar\nexcursión',
//                     cs: cs,
//                     tt: tt,
//                     onTap: () {},
//                     primary: true,
//                   ),
//                   const SizedBox(width: 10),
//                   _ActionCard(
//                     icon: Icons.backpack_outlined,
//                     label: 'Alquilar\nmaterial',
//                     cs: cs,
//                     tt: tt,
//                     onTap: () {},
//                   ),
//                   const SizedBox(width: 10),
//                   _ActionCard(
//                     icon: Icons.inventory_2_outlined,
//                     label: '$materialesDisponibles disponibles',
//                     cs: cs,
//                     tt: tt,
//                     onTap: () {},
//                     sublabel: true,
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // ── Excursiones disponibles ───────────────────────────
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Excursiones disponibles',
//                     style: tt.labelMedium?.copyWith(
//                       color: cs.onSurfaceVariant,
//                       letterSpacing: 0.8,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     style: TextButton.styleFrom(
//                       padding: EdgeInsets.zero,
//                       minimumSize: Size.zero,
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     child: Text(
//                       'Ver todas',
//                       style: tt.labelMedium?.copyWith(color: cs.secondary),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: 230,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
//                 itemCount: catalogoExcursiones.length.clamp(0, 4),
//                 separatorBuilder: (_, __) => const SizedBox(width: 10),
//                 itemBuilder: (context, index) {
//                   final exc = catalogoExcursiones[index];
//                   return SizedBox(
//                     width: 220,
//                     child: ExcursionCard(
//                       excursion: exc,
//                       onSolicitar: () {},
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),

//           // ── Mis solicitudes ───────────────────────────────────
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Mis solicitudes',
//                     style: tt.labelMedium?.copyWith(
//                       color: cs.onSurfaceVariant,
//                       letterSpacing: 0.8,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     style: TextButton.styleFrom(
//                       padding: EdgeInsets.zero,
//                       minimumSize: Size.zero,
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     child: Text(
//                       'Ver todas',
//                       style: tt.labelMedium?.copyWith(color: cs.secondary),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           SliverPadding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             sliver: SliverList(
//               delegate: SliverChildBuilderDelegate(
//                 (context, index) {
//                   final sol = solicitudesFake[index];
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 10),
//                     child: SolicitudCard(
//                       solicitud: sol,
//                       onVerDetalle: () {},
//                     ),
//                   );
//                 },
//                 childCount: solicitudesFake.length.clamp(0, 3),
//               ),
//             ),
//           ),

//           const SliverToBoxAdapter(child: SizedBox(height: 32)),
//         ],
//       ),

//       floatingActionButton: FloatingActionButton(
//         onPressed: () {},
//         backgroundColor: cs.primary,
//         foregroundColor: cs.onPrimary,
//         tooltip: 'Nueva solicitud',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// // ── Widgets internos ──────────────────────────────────────────

// class _StatPill extends StatelessWidget {
//   final String value;
//   final String label;
//   final ColorScheme cs;
//   final TextTheme tt;
//   final bool highlight;

//   const _StatPill({
//     required this.value,
//     required this.label,
//     required this.cs,
//     required this.tt,
//     this.highlight = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//       decoration: BoxDecoration(
//         color: highlight
//             ? cs.secondary.withValues(alpha: 0.25)
//             : cs.onPrimary.withValues(alpha: 0.12),
//         borderRadius: BorderRadius.circular(12),
//         border: highlight
//             ? Border.all(color: cs.secondary.withValues(alpha: 0.5))
//             : null,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             value,
//             style: tt.titleMedium?.copyWith(
//               color: cs.onPrimary,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           Text(
//             label,
//             style: tt.labelSmall?.copyWith(
//               color: cs.onPrimary.withValues(alpha: 0.65),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ActionCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final ColorScheme cs;
//   final TextTheme tt;
//   final VoidCallback onTap;
//   final bool primary;
//   final bool sublabel;

//   const _ActionCard({
//     required this.icon,
//     required this.label,
//     required this.cs,
//     required this.tt,
//     required this.onTap,
//     this.primary = false,
//     this.sublabel = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bg = primary ? cs.primary : cs.primaryContainer;
//     final fg = primary ? cs.onPrimary : cs.onPrimaryContainer;

//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(14),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
//           decoration: BoxDecoration(
//             color: bg,
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Column(
//             children: [
//               Icon(icon, size: 24, color: fg),
//               const SizedBox(height: 8),
//               Text(
//                 label,
//                 style: tt.labelSmall?.copyWith(
//                   color: sublabel
//                       ? fg.withValues(alpha: 0.7)
//                       : fg,
//                   fontWeight: primary ? FontWeight.w600 : FontWeight.w500,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }