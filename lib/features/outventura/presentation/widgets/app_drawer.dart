import 'package:flutter/material.dart';
import 'package:outventura/app/theme/app_gradients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: cs.onTertiary.withValues(alpha: 0.2),
                  child: Icon(Icons.person, size: 36, color: cs.onPrimary),
                ),
                const SizedBox(height: 12),
                Text(
                  usuario?.name ?? s.user,
                  style: AppTextStyles.titleMedium.copyWith(color: cs.onPrimary),
                ),
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
                ListTile(
                  horizontalTitleGap: 8,
                  leading: Icon(Icons.person_outline, color: cs.onSurface, size: 22),
                  title: Text(s.profile, style: AppTextStyles.labelLarge.copyWith(color: cs.onSurface)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  onTap: () {
                    if (usuario == null) return;
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ProfileFormPage(usuario: usuario),
                    ));
                  },
                ),
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

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),

                ListTile(
                  horizontalTitleGap: 8,
                  leading: Icon(Icons.logout, color: cs.error, size: 22),
                  title: Text(s.logout, style: AppTextStyles.labelLarge.copyWith(color: cs.error)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ));
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

