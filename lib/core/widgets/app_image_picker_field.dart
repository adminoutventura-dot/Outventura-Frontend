import 'package:flutter/material.dart';
import 'package:outventura/core/widgets/app_buttons.dart';

// Selector de imagen deshabilitado.
class AppImagePickerField extends StatelessWidget {
  final String? imageUrl;
  final bool isAsset;
  final bool isCircular;
  final double? size;
  final IconData placeholder;

  const AppImagePickerField({
    super.key,
    this.imageUrl,
    this.isAsset = true,
    this.isCircular = false,
    this.size,
    this.placeholder = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    final double resolvedSize = size ?? (isCircular ? 90 : 120);

    // TODO: Temporal hasta tener backend
    Widget imageWidget;
    if (imageUrl != null) {
      final Image img = isAsset
          ? Image.asset(imageUrl!, fit: BoxFit.cover)
          : Image.network(imageUrl!, fit: BoxFit.cover);
      imageWidget = img;
    } else {
      imageWidget = ColoredBox(
        color: cs.primary.withValues(alpha: 0.1),
        child: Icon(placeholder, color: cs.primary, size: 36),
      );
    }

    // Forma de la imagen
    final Widget preview = isCircular
        ? ClipOval(
            child: SizedBox(width: resolvedSize, height: resolvedSize, child: imageWidget),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: size != null ? resolvedSize : double.infinity, height: resolvedSize, child: imageWidget),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        preview,
        const SizedBox(height: 10),
        PrimaryButton(
          onPressed: (){},
            label: imageUrl == null ? 'Añadir imagen' : 'Cambiar imagen',
        )
      ],
    );
  }
}
