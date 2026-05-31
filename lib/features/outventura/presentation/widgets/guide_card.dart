import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/auth/domain/entities/guide.dart';
import 'package:outventura/l10n/app_localizations.dart';

class GuideCard extends StatelessWidget {
  final Guide guide;
  final VoidCallback? onVerDetalle;

  const GuideCard({
    super.key,
    required this.guide,
    this.onVerDetalle,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;

    final user = guide.user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.tertiary.withValues(alpha: 0.18), width: 1.5)
      ),
      child: Stack(
        children: [
          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar con degradado
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [cs.tertiary.withValues(alpha: 0.2), cs.tertiary.withValues(alpha: 0.08)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: cs.tertiary.withValues(alpha: 0.25), width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: user.photo != null && user.photo!.isNotEmpty
                        ? (user.photo!.startsWith('http')
                            ? NetworkImage(user.photo!)
                            : (user.photo!.startsWith('assets/')
                                ? AssetImage(user.photo!)
                                : MemoryImage(base64Decode(user.photo!)) as ImageProvider))
                        : null,
                    child: (user.photo == null || user.photo!.isEmpty)
                        ? Text(
                            user.name[0].toUpperCase(),
                            style: tt.headlineSmall?.copyWith(color: cs.tertiary, fontWeight: FontWeight.w700),
                          )
                        : null,
                  ),
                ),

                const SizedBox(width: 14),

                // Información del guía
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre + Badge de guía
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '${user.name} ${user.surname}',
                              style: tt.titleMedium?.copyWith(
                                color: cs.onSurface,
                                letterSpacing: 0.2,
                              ),
                              softWrap: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TagWidget(
                            text: s.guide,
                            backgroundColor: cs.tertiary.withValues(alpha: 0.14),
                            textColor: cs.tertiary,
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Email con icono
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          
                          Expanded(
                            child: Text(
                              user.email,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              softWrap: true,
                            ),
                          ),
                        
                        ],
                      ),

                      // Teléfono con icono
                      if (user.phone != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user.phone!,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Botón de detalle
                      if (onVerDetalle != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Spacer(),
                            ActionIcon(
                              icon: Icons.chevron_right_rounded,
                              color: cs.onSurfaceVariant,
                              onTap: onVerDetalle!,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
