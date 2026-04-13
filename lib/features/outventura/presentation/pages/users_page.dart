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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: cs.secondaryContainer,
        foregroundColor: cs.onSecondary,
        elevation: 2,
        shape: CircleBorder(
          side: BorderSide(color: cs.onSecondary, width: 3),
        ),
        child: const Icon(Icons.person_add_outlined),
      ),

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
