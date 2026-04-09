import 'package:flutter/material.dart';
import 'package:outventura/features/auth/data/fakes/usuarios_fake.dart';
import 'package:outventura/features/outventura/presentation/widgets/app_drawer.dart';
import 'package:outventura/features/outventura/presentation/widgets/user_card.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: usuariosFake.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index < usuariosFake.length) {
            return UserCard(
              usuario: usuariosFake[index],
              onEditar: () {},
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
