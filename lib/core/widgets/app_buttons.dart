import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 15,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor: textColor ?? Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      onPressed: onPressed,
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 8),
                Text(label),
              ],
            )
          : Text(label),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color borderColor;
  final double borderRadius;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.borderColor,
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: borderColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: borderColor, width: 2),
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class TertiaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? textColor;

  const TertiaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? Theme.of(context).colorScheme.secondary,
          fontSize: 16,
        ),
      ),
    );
  }
}