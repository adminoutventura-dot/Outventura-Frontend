import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/user_form_page.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/user_card.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final List<Usuario> usuarios = ref.watch(usuariosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.surfaceContainer,
                cs.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: AddFab(
        onPressed: () async {
          final Usuario? nuevo = await Navigator.push<Usuario>(
            context,
            MaterialPageRoute(builder: (_) => const UserFormPage()),
          );
          if (nuevo == null) {
            return;
          }
          ref.read(usuariosProvider.notifier).agregar(nuevo);
          if (!context.mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario creado correctamente.')),
          );
        },
        icon: Icons.person_add_outlined,
      ),

      body: Padding(
        padding: const EdgeInsetsGeometry.only(bottom: 50),
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(12, 12, 12, MediaQuery.of(context).padding.bottom + 80),
          itemCount: usuarios.isEmpty ? 1 : usuarios.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int index) {
            if (usuarios.isEmpty) {
              return Center(
                child: Text(
                  'No hay usuarios',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              );
            }

            return UserCard(
              usuario: usuarios[index],
              onEditar: () async {
                final Usuario? actualizado = await Navigator.push<Usuario>(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext _) => UserFormPage(usuario: usuarios[index]),
                  ),
                );
                if (actualizado == null) {
                  return;
                }
                ref.read(usuariosProvider.notifier).actualizar(usuarios[index], actualizado);
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuario actualizado correctamente.')),
                );
              },
              onEliminar: () {},
            );
          },
        ),
      ),
    );
  }
}
