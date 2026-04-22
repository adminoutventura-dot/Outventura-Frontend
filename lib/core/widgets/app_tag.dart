import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const TagWidget({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.labelSmall?.copyWith(color: textColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: textColor),
                const SizedBox(width: 4),
                Text(text, style: style),
              ],
            )
          : Text(text, style: style),
    );
  }
}
