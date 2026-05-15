import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/outventura_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/outventura/presentation/controllers/users_page_controller.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/user_form_page.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/search_controller.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/presentation/widgets/user_card.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  final SearchFieldController _search = SearchFieldController();
  final UsersPageController _controller = UsersPageController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final AppLocalizations s = AppLocalizations.of(context)!;
    final AsyncValue<List<User>> filtrados = ref.watch(usuariosFiltradosProvider((
      query: _search.query,
      rol: _controller.rolFiltro,
      activo: _controller.activoFiltro,
    )));

    return Scaffold(
      appBar: OutventuraAppBar(
        title: s.usersTitle,
        actions: [
          Badge(
            isLabelVisible: _controller.hayFiltros,
            alignment: const AlignmentDirectional(0.5, -0.5),
            smallSize: 7,
            child: IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: s.filtersTitle,
              padding: EdgeInsets.zero,
              onPressed: () => _controller.mostrarFiltros(context, setState),
            ),
          ),
        ],
      ),
      floatingActionButton: AddFab(
        onPressed: () async {
          final User? nuevo = await Navigator.push<User>(
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
            SnackBar(content: Text(s.userCreated)),
          );
        },
        icon: Icons.person_add_outlined,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: CustomInputField(
              controller: _search.controller,
              labelText: s.searchByNameEmailPhone,
              prefixIcon: Icons.search,
              suffixIcon: _search.query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(_search.clear),
                    )
                  : null,
              onChanged: (String v) => setState(() => _search.query = v),
            ),
          ),
          // Lista
          Expanded(
            child: filtrados.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (List<User> usuarios) => ListView.separated(
                padding: EdgeInsets.fromLTRB(12, 12, 12, MediaQuery.of(context).padding.bottom + 80),
                itemCount: usuarios.isEmpty ? 1 : usuarios.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (BuildContext context, int index) {
                  if (usuarios.isEmpty) {
                    return Center(
                      child: Text(
                        s.noUsers,
                        style:
                            tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    );
                  }

                  return UserCard(
                    usuario: usuarios[index],
                    onEditar: () async {
                      final User? actualizado = await Navigator.push<User>(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext _) =>
                              UserFormPage(usuario: usuarios[index]),
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
                        SnackBar(content: Text(s.userUpdated)),
                      );
                    },
                    onEliminar: () {},
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
