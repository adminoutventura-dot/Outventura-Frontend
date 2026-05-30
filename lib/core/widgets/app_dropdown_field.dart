import 'package:flutter/material.dart';
import 'package:outventura/l10n/app_localizations.dart';

class AppDropdownField<T> extends StatefulWidget {
  final dynamic value; 
  final List<T> items;
  final dynamic Function(T) itemValue;
  final String Function(T) itemLabel;
  final ValueChanged<dynamic> onChanged;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final String? Function(dynamic)? validator;
  final bool isRequired;
  final String? errorText;
  final bool enabled;

  const AppDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.itemValue,
    required this.itemLabel,
    required this.onChanged,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.validator,
    this.isRequired = false,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<AppDropdownField<T>> createState() => _AppDropdownFieldState<T>();
}

class _AppDropdownFieldState<T> extends State<AppDropdownField<T>> {
  
  void _mostrarSelectorBuscable(BuildContext context, FormFieldState<dynamic> state) {
    String query = '';
    
    // 🌟 Capturamos el tema de la app para pasárselo al buscador
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            
            final filteredItems = widget.items.where((item) {
              final label = widget.itemLabel(item).toLowerCase();
              return label.contains(query.toLowerCase());
            }).toList();

            return AlertDialog(
              title: Text(widget.label, style: tt.titleMedium),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🌟 BUSCADOR CON EL ESTILO 100% OUTVENTURA (Calco de CustomInputField)
                    TextField(
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Buscar...',
                        labelStyle: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        prefixIcon: Icon(Icons.search_rounded, color: cs.primary.withAlpha(150), size: 22),
                        
                        // Bordes corporativos
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: cs.onSurfaceVariant.withAlpha(50), width: 1.5),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: cs.onSurfaceVariant.withAlpha(50), width: 1.5),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: cs.primaryContainer, width: 2),
                        ),
                        
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                      ),
                      onChanged: (val) {
                        setModalState(() => query = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredItems.length + 1, 
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return ListTile(
                              title: Text(widget.hint, style: TextStyle(color: cs.onSurfaceVariant)),
                              onTap: () {
                                state.didChange(null);
                                widget.onChanged(null);
                                Navigator.pop(dialogContext);
                              },
                            );
                          }

                          final item = filteredItems[index - 1];
                          final itemVal = widget.itemValue(item);
                          final esSeleccionado = widget.value == itemVal;

                          return ListTile(
                            title: Text(
                              widget.itemLabel(item),
                              style: TextStyle(
                                fontWeight: esSeleccionado ? FontWeight.bold : FontWeight.normal,
                                color: esSeleccionado ? cs.primary : null,
                              ),
                            ),
                            trailing: esSeleccionado ? Icon(Icons.check_circle_rounded, color: cs.primary, size: 20) : null,
                            onTap: () {
                              state.didChange(itemVal);
                              widget.onChanged(itemVal);
                              Navigator.pop(dialogContext);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    T? selectedItem;
    for (final item in widget.items) {
      if (widget.itemValue(item) == widget.value) {
        selectedItem = item;
        break;
      }
    }
    
    final String textToShow = selectedItem != null ? widget.itemLabel(selectedItem) : widget.hint;

    return FormField<dynamic>(
      initialValue: widget.value,
      validator: widget.validator ?? (widget.isRequired 
          ? (dynamic v) {
              if (v == null) return AppLocalizations.of(context)!.selectAnOption;
              return null;
            }
          : null),
      builder: (FormFieldState<dynamic> state) {
        return InkWell(
          onTap: widget.enabled ? () => _mostrarSelectorBuscable(context, state) : null,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: cs.primary.withAlpha(150), size: 22)
                  : null,
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: cs.onSurfaceVariant.withAlpha(50), width: 1.5),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: cs.onSurfaceVariant.withAlpha(50), width: 1.5),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: cs.primaryContainer, width: 2),
              ),
              filled: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              errorText: state.errorText ?? widget.errorText,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    textToShow,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyMedium?.copyWith(
                      color: selectedItem != null ? cs.onSurface : cs.onSurfaceVariant,
                    ),
                  ),
                ),
                if (widget.enabled)
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: cs.primary.withValues(alpha: 0.7),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}