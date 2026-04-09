import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_tag.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';

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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Color badgeBg;
    Color badgeFg;

    if (usuario.rol == TipoRol.superadmin) {
      badgeBg = cs.errorContainer;
      badgeFg = cs.onErrorContainer;
    } else if (usuario.rol == TipoRol.admin) {
      badgeBg = cs.secondaryContainer;
      badgeFg = cs.onSecondaryContainer;
    } else if (usuario.rol == TipoRol.experto) {
      badgeBg = cs.tertiaryContainer;
      badgeFg = cs.onTertiary;
    } else if (usuario.rol == TipoRol.usuario) {
      badgeBg = cs.primaryContainer;
      badgeFg = cs.onPrimaryContainer;
    } else {
      badgeBg = cs.onSurfaceVariant.withValues(alpha: 0.15);
      badgeFg = cs.onSurfaceVariant;
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurfaceVariant.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.fromLTRB(13, 11, 12, 10),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.primaryContainer,
            backgroundImage:
                usuario.foto != null ? NetworkImage(usuario.foto!) : null,
            child: usuario.foto == null
                ? Text(
                    usuario.nombre[0].toUpperCase(),
                    style: tt.titleMedium
                        ?.copyWith(color: cs.onPrimaryContainer),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${usuario.nombre} ${usuario.apellidos}',
                  style: tt.labelLarge?.copyWith(color: cs.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  usuario.email,
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                if (usuario.telefono != null) 
                  Text(
                    usuario.telefono!,
                    style: tt.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Badge rol + estado
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TagWidget(
                text: usuario.rol.nombre,
                backgroundColor: badgeBg,
                textColor: badgeFg,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (!usuario.activo)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: TagWidget(
                        text: 'Inactivo',
                        backgroundColor:
                            cs.errorContainer.withValues(alpha: 0.4),
                        textColor: cs.onErrorContainer,
                      ),
                    ),
                    
                  if (onEditar != null)
                    IconButton(
                      onPressed: onEditar,
                      icon: Icon(Icons.edit_outlined, color: cs.onPrimaryContainer),
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                  const SizedBox(width: 8),

                  if (onEliminar != null)
                    IconButton(
                      onPressed: onEliminar,
                      icon: Icon(Icons.delete_outline, color: cs.error),
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
