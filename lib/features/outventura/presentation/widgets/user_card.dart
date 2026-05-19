import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

class UserCard extends StatelessWidget {
  final User usuario;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  const UserCard({
    super.key,
    required this.usuario,
    this.onEditar,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final s = AppLocalizations.of(context)!;

    // Colores según el rol
    final Color roleColor = switch (usuario.role) {
      UserRole.superadmin => cs.error,
      UserRole.admin      => cs.tertiary,
      UserRole.usuario    => cs.primary,
      UserRole _          => cs.onSurfaceVariant,
    };

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: roleColor.withValues(alpha: 0.18), width: 1.5)
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
                      colors: [roleColor.withValues(alpha: 0.2), roleColor.withValues(alpha: 0.08)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: roleColor.withValues(alpha: 0.25), width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: usuario.photo != null ? NetworkImage(usuario.photo!) : null,
                    child: usuario.photo == null
                        ? Text(
                            usuario.name[0].toUpperCase(),
                            style: tt.headlineSmall?.copyWith(color: roleColor, fontWeight: FontWeight.w700),
                          )
                        : null,
                  ),
                ),

                const SizedBox(width: 14),

                // Información del usuario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre + Badge de rol en la misma línea
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '${usuario.name} ${usuario.surname}',
                              style: tt.titleMedium?.copyWith(
                                color: cs.onSurface,
                                letterSpacing: 0.2,
                              ),
                              softWrap: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TagWidget(
                            text: usuario.role.localizedLabel(s),
                            backgroundColor: roleColor.withValues(alpha: 0.14),
                            textColor: roleColor,
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
                              usuario.email,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              softWrap: true,
                            ),
                          ),
                        
                        ],
                      ),

                      // Teléfono con icono
                      if (usuario.phone != null) ...[
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
                              usuario.phone!,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],

                      

                      // Botones de acción
                      if (onEditar != null || onEliminar != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Badge de inactivo
                            if (!usuario.active) ...[
                              TagWidget(
                                text: s.inactiveAccount,
                                backgroundColor: cs.error.withValues(alpha: 0.12),
                                textColor: cs.error,
                              ),
                            ],

                            const Spacer(),

                            if (onEditar != null)
                              ActionIcon(
                                icon: Icons.edit_outlined,
                                color: cs.tertiary,
                                onTap: onEditar!
                              ),
                              
                            if (onEditar != null && onEliminar != null)
                              const SizedBox(width: 4),

                            if (onEliminar != null)
                              ActionIcon(
                                icon: Icons.delete_outline,
                                color: cs.error,
                                onTap: onEliminar!,
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
