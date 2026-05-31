import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/widgets/app_bar.dart';
import 'package:outventura/features/outventura/domain/entities/activity_log.dart';
import 'package:outventura/features/outventura/presentation/providers/activity_log_provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class LogsPage extends ConsumerStatefulWidget {
  const LogsPage({super.key});

  @override
  ConsumerState<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends ConsumerState<LogsPage> {
  int _currentPage = 1;
  final int _perPage = 5;

  void _prevPage() {
    if (_currentPage > 1) setState(() => _currentPage--);
  }

  void _nextPage(int totalPages) {
    if (_currentPage < totalPages) setState(() => _currentPage++);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;
    final logsAsync = ref.watch(activityLogProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const CustomAppBar(title: 'Logs del Sistema'),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: cs.error),
              const SizedBox(height: 16),
              Text('Error al cargar logs', style: tt.bodyLarge),
              const SizedBox(height: 8),
              Text(error.toString(), style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 48, color: cs.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No hay logs disponibles', style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            );
          }

          final int total = logs.length;
          final int totalPages = (total / _perPage).ceil();
          final int start = (_currentPage - 1) * _perPage;
          final int end = min(start + _perPage, total);
          final pageItems = logs.sublist(start, end);

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: _currentPage > 1 ? _prevPage : null,
                      icon: const Icon(Icons.chevron_left, size: 28),
                      color: _currentPage > 1
                          ? cs.primary
                          : cs.onSurfaceVariant.withValues(alpha: 0.3),
                      tooltip: 'Anterior',
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$_currentPage / $totalPages',
                      style: tt.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _currentPage < totalPages ? () => _nextPage(totalPages) : null,
                      icon: const Icon(Icons.chevron_right, size: 28),
                      color: _currentPage < totalPages
                          ? cs.primary
                          : cs.onSurfaceVariant.withValues(alpha: 0.3),
                      tooltip: 'Siguiente',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: pageItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final log = pageItems[index];
                    return _LogCard(log: log);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final ActivityLog log;

  const _LogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    final Color methodColor = _getMethodColor(log.method);
    final Color statusColor = _getStatusCodeColor(log.statusCode);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: methodColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  log.method,
                  style: tt.labelSmall?.copyWith(
                    color: methodColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (log.statusCode != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    log.statusCode.toString(),
                    style: tt.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                '${log.duration}ms',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            log.url,
            style: tt.bodyMedium?.copyWith(fontFamily: 'monospace'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (log.userRole != null)
                Text(
                  'Rol: ${log.userRole}',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              if (log.userRole != null && log.userId != null)
                const SizedBox(width: 8),
              if (log.userId != null)
                Text(
                  'ID: ${log.userId}',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              const Spacer(),
              Text(
                DateFormat('dd/MM/yyyy HH:mm:ss').format(log.createdAt),
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
      case 'PATCH':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusCodeColor(int? statusCode) {
    if (statusCode == null) return Colors.grey;
    if (statusCode >= 200 && statusCode < 300) return Colors.green;
    if (statusCode >= 300 && statusCode < 400) return Colors.blue;
    if (statusCode >= 400 && statusCode < 500) return Colors.orange;
    if (statusCode >= 500) return Colors.red;
    return Colors.grey;
  }
}
