import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const TagWidget({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: textColor),
      ),
    );
  }
}
