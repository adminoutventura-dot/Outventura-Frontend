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
                cs.inverseSurface,
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserFormPage()),
        ),
        icon: Icons.person_add_outlined,
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: usuarios.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          if (index < usuarios.length) {
            return UserCard(
              usuario: usuarios[index],
              onEditar: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext _) => UserFormPage(usuario: usuarios[index]),
                ),
              ),
              onEliminar: () {},
            );
          }

          return Center(
            child: Text(
              'No hay usuarios',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          );
          
        },
      ),
    );
  }
}
