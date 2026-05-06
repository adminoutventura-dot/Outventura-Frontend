import 'package:flutter/material.dart';

class DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const DetailSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.onSurfaceVariant.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.12),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const DetailRow(this.icon, this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          ),
          Text(
            value,
            style: tt.bodyMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
