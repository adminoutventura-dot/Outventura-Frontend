import 'package:flutter/material.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/l10n/app_localizations.dart';
import 'package:outventura/features/auth/domain/entities/guide.dart';
import 'package:outventura/features/auth/domain/entities/user.dart';
import 'package:outventura/features/auth/domain/entities/role.dart';
import 'package:outventura/features/auth/presentation/providers/guides_provider.dart';
import 'package:outventura/features/auth/presentation/providers/users_provider.dart';
import 'package:outventura/features/auth/presentation/providers/current_user_provider.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/presentation/controllers/users_page_controller.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/user_form_page.dart';
import 'package:outventura/features/outventura/presentation/pages/user_detail_page.dart';
import 'package:outventura/features/outventura/presentation/controllers/search_controller.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/features/outventura/presentation/widgets/user_card.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';

class UsersPage extends ConsumerStatefulWidget {
  final bool soloGuiasOInferior;

  const UsersPage({super.key, this.soloGuiasOInferior = false});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  final SearchFieldController _search = SearchFieldController();
  final UsersPageController _controller = UsersPageController();
  int _currentPage = 1;
  final int _perPage = 10;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Si soloGuiasOInferior es true, preseleccionar el filtro de rol a GUIDE
    if (widget.soloGuiasOInferior && _controller.rolFiltro == null) {
      _controller.rolFiltro = UserRole.guia;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final AppLocalizations s = AppLocalizations.of(context)!;
    final usuarioActual = ref.watch(currentUserProvider);
    final String? currentRole = usuarioActual?.role.code;

    // Lista base: guías (cuando es vista reducida) o usuarios filtrados completos.
    final AsyncValue<List<User>> usuariosAsync = widget.soloGuiasOInferior
        ? ref.watch(expertsProvider)
        : ref.watch(usuariosFiltradosProvider((
            query: _search.query,
            rol: _controller.rolFiltro,
            activo: _controller.activoFiltro,
          )));

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.soloGuiasOInferior ? s.guides : s.usersTitle,
        actions: [
          // Botón de filtros. Oculto en la vista reducida de guías.
          if (!widget.soloGuiasOInferior)
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

      // Botón flotante para crear un nuevo usuario.
      floatingActionButton: widget.soloGuiasOInferior
          ? null
          : AddFab(
              onPressed: () async {
                // Navega al formulario de creación de usuario.
                final Map<String, dynamic>? result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(builder: (_) => const UserFormPage()),
                );
                
                // Si el usuario cancela la creación, no hace nada.
                if (result == null) {
                  return;
                }
                final User nuevo = result['usuario'] as User;
                final String? password = result['password'] as String?;
                final Map<String, dynamic>? guiaData = result['guia'] as Map<String, dynamic>?;

                try {
                  // Agrega el nuevo usuario al estado global.
                  final User creado = await ref.read(usuariosProvider.notifier).agregar(nuevo, password: password);

                  // Si tiene datos de guía, crea el registro de guía.
                  if (guiaData != null) {
                    final Guide guia = Guide(
                      userId: creado.id!,
                      credentials: guiaData['credentials'] as String,
                      categories: (guiaData['categoryCodes'] as List<dynamic>).cast<Category>(),
                      user: creado,
                    );
                    await ref.read(guidesProvider.notifier).agregar(guia);
                  }
                  if (!context.mounted) {
                    return;
                  }
                  showSuccessSnackBar(context, s.userCreated);

                } catch (e) {
                  if (!context.mounted) return;
                  showErrorSnackBar(context, e.toString()); 
                }
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

          // Lista de usuarios filtrados con paginación
          Expanded(
            child: usuariosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(s.error(error.toString()))),
              data: (List<User> usuariosBase) {
                List<User> usuarios = usuariosBase;

                if (widget.soloGuiasOInferior) {
                  if (_controller.activoFiltro != null) {
                    usuarios = usuarios.where((u) => u.active == _controller.activoFiltro).toList();
                  }

                  if (_search.query.isNotEmpty) {
                    final String q = _search.query.toLowerCase();
                    usuarios = usuarios.where((User u) =>
                      '${u.name} ${u.surname} ${u.email} ${u.phone ?? ''}'.toLowerCase().contains(q)
                    ).toList();
                  }
                }

                if (usuarios.isEmpty) {
                  return Center(
                    child: Text(
                      widget.soloGuiasOInferior
                          ? 'No hay guías registradas'
                          : s.noUsers,
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  );
                }

                final int total = usuarios.length;
                final int totalPages = (total / _perPage).ceil().clamp(1, 9999);
                if (_currentPage > totalPages) _currentPage = totalPages;

                final int start = (_currentPage - 1) * _perPage;
                final List<User> pageItems = usuarios.skip(start).take(_perPage).toList();

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(12, 12, 12, MediaQuery.of(context).padding.bottom + 80),
                        itemCount: pageItems.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (BuildContext context, int index) {
                          final User targetUser = pageItems[index];
                          final String targetRole = targetUser.role.code;
                          final bool isSelf = targetUser.id == usuarioActual?.id;

                          // Reglas de edición
                          final bool puedeEditar = widget.soloGuiasOInferior
                              ? (currentRole == 'SUPER' || currentRole == 'ADMIN') &&
                                  ((currentRole == 'SUPER') ||
                                  (currentRole == 'ADMIN' && targetRole != 'SUPER' && (targetRole != 'ADMIN' || isSelf)))
                              : (currentRole == 'SUPER') ||
                                  (currentRole == 'ADMIN' && targetRole != 'SUPER' && (targetRole != 'ADMIN' || isSelf)) ||
                                  (isSelf && (currentRole == 'GUIDE' || currentRole == 'USER'));

                          // Reglas de eliminación/desactivación
                          final bool puedeEliminar = widget.soloGuiasOInferior
                              ? (currentRole == 'SUPER' || currentRole == 'ADMIN') &&
                                  ((currentRole == 'SUPER' && (targetRole != 'SUPER' || isSelf)) ||
                                  (currentRole == 'ADMIN' && targetRole != 'SUPER' && targetRole != 'ADMIN'))
                              : (currentRole == 'SUPER' && (targetRole != 'SUPER' || isSelf)) ||
                                  (currentRole == 'ADMIN' && targetRole != 'SUPER' && targetRole != 'ADMIN') ||
                                  (isSelf && (currentRole == 'GUIDE' || currentRole == 'USER'));

                          return UserCard(
                            usuario: targetUser,
                            onVerDetalle: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => UserDetailPage(user: targetUser),
                                ),
                              );
                            },
                            onEditar: puedeEditar ? () async {
                              final Guide? guiaActual = ref.read(guidesProvider.notifier).porUsuario(targetUser.id!);

                              final Map<String, dynamic>? result =
                                  await Navigator.push<Map<String, dynamic>>(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext _) => UserFormPage(
                                    usuario: targetUser,
                                    guia: guiaActual,
                                  ),
                                ),
                              );

                              if (result == null) {
                                return;
                              }

                              final User actualizado = result['usuario'] as User;
                              final Map<String, dynamic>? guiaData = result['guia'] as Map<String, dynamic>?;
                              final String? passwordNueva = result['password'] as String?;

                              try {
                                await ref.read(usuariosProvider.notifier).actualizar(
                                  targetUser,
                                  actualizado,
                                  password: passwordNueva,
                                );

                                if (guiaData != null) {
                                  final Guide nuevaGuia = Guide(
                                    id: guiaActual?.id,
                                    userId: actualizado.id!,
                                    credentials: guiaData['credentials'] as String,
                                    categories: (guiaData['categoryCodes'] as List<dynamic>).cast<Category>(),
                                    user: actualizado,
                                  );

                                  if (guiaActual != null) {
                                    await ref.read(guidesProvider.notifier).actualizar(guiaActual, nuevaGuia);
                                  } else {
                                    await ref.read(guidesProvider.notifier).agregar(nuevaGuia);
                                  }

                                } else if (guiaActual != null) {
                                  await ref.read(guidesProvider.notifier).eliminar(guiaActual);
                                }

                                if (!context.mounted) {
                                  return;
                                }

                                showSuccessSnackBar(context, s.userUpdated);

                              } catch (e) {
                                if (!context.mounted) return;
                                showErrorSnackBar(context, e.toString());
                              }
                            } : null,
                            onEliminar: puedeEliminar ? () async {
                              final bool confirmar = await showConfirmDialog(
                                context: context,
                                title: s.deleteUser,
                                content: s.deleteUserConfirm('${targetUser.name} ${targetUser.surname}'),
                                confirmLabel: s.deleteUser,
                              );

                              try {
                                if (!confirmar || !context.mounted) return;

                                await ref.read(usuariosProvider.notifier).eliminar(targetUser);

                                if (!context.mounted) return;
                                showSuccessSnackBar(context, s.userDeleted);
                              } catch (e) {
                                if (!context.mounted) return;
                                showErrorSnackBar(context, e.toString());
                              }
                            } : null,
                          );
                        },
                      ),
                    ),
                    
                    // Paginación
                    if (totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton(
                              onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                              child: const Icon(Icons.chevron_left),
                            ),
                            const SizedBox(width: 12),
                            Text('$_currentPage / $totalPages'),
                            const SizedBox(width: 12),
                            FilledButton(
                              onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                              child: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}