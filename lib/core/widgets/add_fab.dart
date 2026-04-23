import 'package:flutter/material.dart';

class AddFab extends StatelessWidget {
  final Future<void> Function() onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double elevation;
  final IconData icon;

  const AddFab({
    super.key,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.elevation = 2,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color fg = foregroundColor ?? cs.onSecondaryContainer;

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? cs.secondaryContainer,
      foregroundColor: fg,
      elevation: elevation,
      shape: CircleBorder(
        side: BorderSide(color: borderColor ?? fg, width: 3),
      ),
      child: Icon(icon),
    );
  }
}
