import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/utils/snackbar_helper.dart';
import 'package:outventura/core/widgets/add_fab.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/core/widgets/confirm_dialog.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/presentation/controllers/search_controller.dart';
import 'package:outventura/features/outventura/presentation/pages/forms/category_form_page.dart';
import 'package:outventura/features/outventura/presentation/providers/categories_provider.dart';
import 'package:outventura/features/outventura/presentation/widgets/category_card.dart';
import 'package:outventura/l10n/app_localizations.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final SearchFieldController _search = SearchFieldController();

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

    final AsyncValue<List<Category>> categoriasAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: CustomAppBar(title: s.categories),
      floatingActionButton: AddFab(
        onPressed: () async {
          final Category? nueva = await Navigator.of(context).push<Category>(
            MaterialPageRoute(builder: (_) => const CategoryFormPage()),
          );
          if (nueva == null) {
            return;
          }
          try {
            await ref.read(categoriesProvider.notifier).agregar(nueva);
            if (!context.mounted) {
              return;
            }
            showSuccessSnackBar(context, s.create);
          } catch (e) {
            if (!context.mounted) {
              return;
            }
            showErrorSnackBar(context, e);
          }
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: CustomInputField(
              controller: _search.controller,
              labelText: s.searchByName,
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
          Expanded(
            child: categoriasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(s.error(error.toString()))),
              data: (List<Category> lista) {
                final String q = _search.query.trim().toLowerCase();
                final List<Category> filtradas = q.isEmpty
                    ? lista
                    : lista.where((Category c) {
                        final String code = c.code.toLowerCase();
                        final String desc = (c.description ?? '').toLowerCase();
                        return code.contains(q) || desc.contains(q);
                      }).toList();

                if (filtradas.isEmpty) {
                  return Center(
                    child: Text(
                      s.noEquipmentForCategory,
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, MediaQuery.of(context).padding.bottom + 80),
                  itemCount: filtradas.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (BuildContext context, int index) {
                    final Category categoria = filtradas[index];

                    return CategoryCard(
                      categoria: categoria,
                      onEditar: () async {
                        final Category? actualizada = await Navigator.of(context)
                            .push<Category>(
                          MaterialPageRoute(
                            builder: (_) => CategoryFormPage(categoria: categoria),
                          ),
                        );
                        if (actualizada == null) {
                          return;
                        }
                        try {
                          await ref.read(categoriesProvider.notifier).actualizar(categoria, actualizada);
                          if (!context.mounted) {
                            return;
                          }
                          showSuccessSnackBar(context, s.save);
                        } catch (e) {
                          if (!context.mounted) {
                            return;
                          }
                          showErrorSnackBar(context, e);
                        }
                      },
                      onEliminar: () async {
                        final bool confirm = await showConfirmDialog(
                          context: context,
                          title: s.delete,
                          content: s.deleteEquipmentConfirm(categoria.code),
                        );
                        if (!confirm) {
                          return;
                        }
                        try {
                          await ref.read(categoriesProvider.notifier).eliminar(categoria);
                          if (!context.mounted) {
                            return;
                          }
                          showSuccessSnackBar(context, s.delete);
                        } catch (e) {
                          if (!context.mounted) {
                            return;
                          }
                          showErrorSnackBar(context, e);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
