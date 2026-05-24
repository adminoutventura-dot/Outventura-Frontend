import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outventura/core/widgets/app_buttons.dart';
import 'package:outventura/l10n/app_localizations.dart';

class AppImagePickerField extends StatefulWidget {
  final String? imageUrl;
  final bool isAsset;
  final bool isCircular;
  final double? size;
  final IconData placeholder;
  final ValueChanged<String?>? onChanged;

  const AppImagePickerField({
    super.key,
    this.imageUrl,
    this.isAsset = true,
    this.isCircular = false,
    this.size,
    this.placeholder = Icons.image_outlined,
    this.onChanged,
  });

  @override
  State<AppImagePickerField> createState() => _AppImagePickerFieldState();
}

class _AppImagePickerFieldState extends State<AppImagePickerField> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _seleccionarImagen() async {
    // Abre la galería del móvil
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      // Comprime un poco para no saturar el Base64
      imageQuality: 70, 
      maxWidth: 800,
    );

    if (image != null && widget.onChanged != null) {
      // Lee el archivo como bytes
      final bytes = await image.readAsBytes();
      // Lo convierte a String Base64 y lo manda al formulario
      final String base64String = base64Encode(bytes);
      widget.onChanged!(base64String);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final double resolvedSize = widget.size ?? (widget.isCircular ? 90 : 120);

    Widget imageWidget;

    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      // Si empieza por 'assets/', es una imagen local de prueba
      if (widget.imageUrl!.startsWith('assets/')) {
        imageWidget = Image.asset(widget.imageUrl!, fit: BoxFit.cover);
      } 
      // Si empieza por 'http', es una URL de internet (por si acaso)
      else if (widget.imageUrl!.startsWith('http')) {
        imageWidget = Image.network(widget.imageUrl!, fit: BoxFit.cover);
      } 
      // Si no es ninguna de las anteriores, asume que es el texto Base64
      else {
        try {
          imageWidget = Image.memory(
            base64Decode(widget.imageUrl!), 
            fit: BoxFit.cover,
          );
        } catch (e) {
          // Si el base64 está corrupto, pinta un icono de error
          imageWidget = Center(child: Icon(Icons.broken_image, color: cs.error));
        }
      }
    } else {
      imageWidget = ColoredBox(
        color: cs.primary.withValues(alpha: 0.1),
        child: Icon(widget.placeholder, color: cs.primary, size: 36),
      );
    }

    final Widget preview = widget.isCircular
        ? ClipOval(
            child: SizedBox(width: resolvedSize, height: resolvedSize, child: imageWidget),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: widget.size != null ? resolvedSize : double.infinity, 
              height: resolvedSize, 
              child: imageWidget
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        preview,
        const SizedBox(height: 10),
        PrimaryButton(
          onPressed: _seleccionarImagen,
          label: (widget.imageUrl == null || widget.imageUrl!.isEmpty) 
              ? AppLocalizations.of(context)!.addImage 
              : AppLocalizations.of(context)!.changeImage,
        )
      ],
    );
  }
}