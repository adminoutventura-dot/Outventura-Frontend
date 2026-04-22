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
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor: textColor ?? Theme.of(context).colorScheme.onPrimary,
        textStyle: Theme.of(context).textTheme.labelLarge,
        side: BorderSide(color: backgroundColor ?? Theme.of(context).colorScheme.primary),
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
                const SizedBox(width: 2),
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
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.borderColor,
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: borderColor,
        textStyle: Theme.of(context).textTheme.labelLarge,
        side: BorderSide(color: borderColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
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
  final IconData? icon;

  const TertiaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = textColor ?? Theme.of(context).colorScheme.secondary;
    final TextStyle? style = Theme.of(context).textTheme.labelLarge?.copyWith(color: color);

    if (icon != null) {
      return TextButton.icon(
        style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: color),
        label: Text(label, style: style),
      );
    }

    return TextButton(
      style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
      onPressed: onPressed,
      child: Text(label, style: style),
    );
  }
}

class MiniButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const MiniButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor: textColor ?? Theme.of(context).colorScheme.onPrimary,
        textStyle: Theme.of(context).textTheme.labelMedium,
        side: BorderSide(color: backgroundColor ?? Theme.of(context).colorScheme.primary),
        padding: const EdgeInsets.all(10),
        minimumSize: const Size(40, 24),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}