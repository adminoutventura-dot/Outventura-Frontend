import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/core/utils/enum_translations.dart';

class UserCard extends StatelessWidget {
  final Usuario usuario;
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
    Color badgeBg;
    Color badgeFg;
    Color bordeColor;

    if (usuario.role == TipoRol.superadmin) {
      badgeBg = cs.error;
      badgeFg = cs.onError;
      bordeColor = cs.error;
    } else if (usuario.role == TipoRol.admin) {
      badgeBg = cs.tertiary;
      badgeFg = cs.onPrimary;
      bordeColor = cs.tertiary;
    } else if (usuario.role == TipoRol.usuario) {
      badgeBg = cs.secondary;
      badgeFg = cs.onPrimary;
      bordeColor = cs.secondary;
    } else {
      badgeBg = cs.onSurfaceVariant.withValues(alpha: 0.15);
      badgeFg = cs.onSurfaceVariant;
      bordeColor = cs.onSurfaceVariant;
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurfaceVariant.withValues(alpha: 0.2))
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Barra de color lateral según rol
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: bordeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
          ),

          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Coloca el avatar sobre un contenedor circular con borde del color del rol
                Stack(
                  // Avatar con borde de color según rol
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: bordeColor.withAlpha(80),
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: cs.onPrimary,
                        backgroundImage: usuario.photo != null ? NetworkImage(usuario.photo!) : null,
                        child: usuario.photo == null
                            ? Text(
                                usuario.name[0].toUpperCase(),
                                style: tt.titleLarge?.copyWith(
                                  color: bordeColor,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

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
                            backgroundColor: badgeBg,
                            textColor: badgeFg,
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
                              const SizedBox(height: 8),
                              TagWidget(
                                text: s.inactiveAccount,
                                backgroundColor: cs.error.withValues(alpha: 0.3),
                                textColor: cs.error,
                                icon: Icons.block_outlined,
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