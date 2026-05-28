import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_gradients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/app/theme/app_text_styles.dart';
import 'package:outventura/catalog/pages/catalog_page.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/pages/login_page.dart';
import 'package:outventura/features/auth/presentation/pages/profile_form_page.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/preferences/presentation/pages/preferences_page.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? usuario = ref.watch(currentUserProvider);
    final ColorScheme cs = Theme.of(context).colorScheme;
    final s = AppLocalizations.of(context)!;

    // 🌟 COMPROBAMOS SI ES INVITADO
    final bool isGuest = usuario == null || 
                         usuario.role.code == 'INVITADO' || 
                         usuario.role.code == 'GUEST';

    return Drawer(
      backgroundColor: cs.surface,
      child: Column(
        children: [
          // Header 
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppGradients.drawer(cs),
            ),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24, bottom: 24, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar con degradado de fondo
                CircleAvatar(
                  radius: 32,
                  backgroundColor: cs.onTertiary.withValues(alpha: 0.2),
                  backgroundImage: usuario?.photo != null && usuario!.photo!.isNotEmpty
                      ? (usuario.photo!.startsWith('http')
                          ? NetworkImage(usuario.photo!)
                          : (usuario.photo!.startsWith('assets/')
                              ? AssetImage(usuario.photo!)
                              : MemoryImage(base64Decode(usuario.photo!)) as ImageProvider))
                      : null,
                  child: (usuario?.photo == null || usuario!.photo!.isEmpty)
                      ? Text(
                          usuario?.name[0].toUpperCase() ?? '?',
                          style: AppTextStyles.headlineSmall.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w700),
                        )
                      : null,
                ),
                const SizedBox(height: 12),

                // Nombre de usuario 
                Text(
                  usuario?.name ?? s.user,
                  style: AppTextStyles.titleMedium.copyWith(color: cs.onPrimary),
                ),

                // Email del usuario (si existe)
                if (usuario?.email != null)
                  Text(
                    usuario!.email,
                    style: AppTextStyles.bodySmall.copyWith(color: cs.onPrimary.withValues(alpha: 0.75)),
                  ),
              ],
            ),
          ),

          // Items 
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Item - Perfil
                // 🌟 OCULTAMOS EL PERFIL SI ES INVITADO
                if (!isGuest)
                  ListTile(
                    horizontalTitleGap: 8,
                    leading: Icon(Icons.person_outline, color: cs.onSurface, size: 22),
                    title: Text(s.profile, style: AppTextStyles.labelLarge.copyWith(color: cs.onSurface)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onTap: () async {
                      if (usuario == null) return;

                      final result = await Navigator.push<Map<String, dynamic>>(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => ProfileFormPage(usuario: usuario),
                        )
                      );


                      if (result == null) {
                        // Si el usuario vuelve atrás sin guardar, cierra el drawer de forma segura
                        if (context.mounted) Navigator.pop(context);
                        return;
                      }

                      final User usuarioEditado = result['usuario'] as User;
                      final String? nuevaPassword = result['password'] as String?;

                      try {
                        await ref.read(currentUserProvider.notifier).actualizarPerfil(
                          usuarioEditado, 
                          nuevaPassword: nuevaPassword,
                        );
                        
                        if (context.mounted) {
                          showSuccessSnackBar(context, s.userUpdated);
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        
                        if (context.mounted) {
                          showErrorSnackBar(context, e.toString());
                        }
                      }
                    },
                  ),

                // Item - Catálogo de componentes
                ListTile(
                  horizontalTitleGap: 8,
                  leading: Icon(Icons.map_outlined, color: cs.onSurface, size: 22),
                  title: Text(s.componentCatalog, style: AppTextStyles.labelLarge.copyWith(color: cs.onSurface)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const CatalogPage(),
                    ));
                  },
                ),

                // Item - Preferencias
                ListTile(
                  horizontalTitleGap: 8,
                  leading: Icon(Icons.settings_outlined, color: cs.onSurface, size: 22),
                  title: Text(s.preferences, style: AppTextStyles.labelLarge.copyWith(color: cs.onSurface)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => const PreferencesPage(),
                    ));
                  },
                ),

                // Separador
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
                
                // Item - Cerrar sesión / Iniciar sesión
                // 🌟 DINÁMICO: CERRAR SESIÓN (ROJO) O INICIAR SESIÓN (PRIMARY)
                ListTile(
                  horizontalTitleGap: 8,
                  leading: Icon(isGuest ? Icons.login : Icons.logout, color: isGuest ? cs.primary : cs.error, size: 22),
                  title: Text(
                    isGuest ? 'Iniciar sesión' : s.logout, // TODO: Si tienes s.login en tu archivo de idiomas, ponlo aquí
                    style: AppTextStyles.labelLarge.copyWith(color: isGuest ? cs.primary : cs.error)
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  onTap: () async {
                    Navigator.pop(context);
                    
                    if (isGuest) {
                      // Si es invitado, navegamos directamente al Login
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ));
                    } else {
                      // Si es usuario, deslogueamos en el Provider y navegamos al Login
                      await ref.read(currentUserProvider.notifier).cerrarSesion();
                      if (context.mounted) {
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}