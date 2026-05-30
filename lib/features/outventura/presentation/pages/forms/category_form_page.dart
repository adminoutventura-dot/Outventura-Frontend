import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_bar_forms.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/core/widgets/app_input_field.dart';
import 'package:outventura/core/utils/form_validators.dart';
import 'package:outventura/features/outventura/domain/entities/category.dart';
import 'package:outventura/features/outventura/presentation/controllers/category_form_controller.dart';
import 'package:outventura/l10n/app_localizations.dart';

class CategoryFormPage extends ConsumerStatefulWidget {
  final Category? categoria;

  const CategoryFormPage({super.key, this.categoria});

  @override
  ConsumerState<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends ConsumerState<CategoryFormPage> {
  late final CategoryFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CategoryFormController();
    if (widget.categoria != null) {
      _controller.cargarCategoria(widget.categoria!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final Category? categoria = _controller.construirCategoria();
    if (categoria == null) {
      return;
    }
    Navigator.of(context).pop(categoria);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations s = AppLocalizations.of(context)!;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final String title = _controller.editando
        ? '${s.edit} ${s.categoryFilter}'
        : '${s.create} ${s.categoryFilter}';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: CustomAppBarForm(title: title),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 24),
        child: Form(
          key: _controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.categories.toUpperCase(),
                style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              CustomInputField(
                controller: _controller.codeController,
                labelText: s.name,
                prefixIcon: Icons.category_outlined,
                validator: ValidadoresFormulario.campoObligatorio(s),
              ),
              const SizedBox(height: 14),
              CustomInputField(
                controller: _controller.descriptionController,
                labelText: s.description,
                prefixIcon: Icons.notes_outlined,
                keyboardType: TextInputType.multiline,
                maxLines: 1,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _controller.editando ? s.save : s.create,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
