# Explicaciones de selección múltiple e individual con chips

## Selección múltiple (AppFilterChip)

- Permite elegir varias opciones a la vez.
- Ejemplo: categorías de actividad.
- Se usa una lista o set para guardar las seleccionadas.
- Al pulsar un chip, se añade o quita del set.

```dart
AppChipWrap(
  children: CategoriaActividad.values.map((cat) {
    final selected = _controller.categorias.contains(cat);
    return AppFilterChip(
      label: cat.nombre,
      selected: selected,
      onSelected: (_) => setState(() => _controller.toggleCategoria(cat)),
    );
  }).toList(),
)
```

- toggleCategoria añade o quita la categoría:
```dart
void toggleCategoria(CategoriaActividad cat) {
  if (categorias.contains(cat)) {
    categorias.remove(cat);
  } else {
    categorias.add(cat);
  }
}
```

## Selección individual (AppChoiceChip)

- Solo puedes elegir una opción.
- Ejemplo: estado del material.
- Se usa una variable para guardar la opción seleccionada.
- Al pulsar un chip, se cambia esa variable.

```dart
AppChipWrap(
  children: mat.EstadoMaterial.values.map((est) {
    final selected = _controller.estado == est;
    return AppChoiceChip(
      label: est.nombre,
      selected: selected,
      onSelected: (_) => setState(() => _controller.estado = est),
    );
  }).toList(),
)
```
---

