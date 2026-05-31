import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outventura/core/network/dio_client.dart';
import 'package:outventura/features/outventura/domain/entities/activity_log.dart';

class ActivityLogNotifier extends AsyncNotifier<List<ActivityLog>> {
  @override
  Future<List<ActivityLog>> build() async {
    return await _fetchLogs();
  }

  Future<List<ActivityLog>> _fetchLogs({
    String? method,
    int? userId,
    int? statusCode,
    int page = 1,
    int limit = 20,
  }) async {
    final dio = ref.read(dioProvider);
    final response = await dio.get(
      '/activity-log',
      queryParameters: {
        if (method != null) 'method': method,
        if (userId != null) 'userId': userId,
        if (statusCode != null) 'statusCode': statusCode,
        'page': page,
        'limit': limit,
      },
    );

    final dynamic responseData = response.data;
    List<dynamic> data;

    if (responseData is List) {
      data = responseData as List<dynamic>;
    } else if (responseData is Map<String, dynamic>) {
      // El backend devuelve un objeto con la lista dentro
      final map = responseData as Map<String, dynamic>;
      data = (map['data'] as List<dynamic>?) ?? (map['items'] as List<dynamic>?) ?? (map['logs'] as List<dynamic>?) ?? [];
    } else {
      data = [];
    }

    return data
        .map((json) => ActivityLog.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> loadLogs({
    String? method,
    int? userId,
    int? statusCode,
    int page = 1,
    int limit = 20,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchLogs(
      method: method,
      userId: userId,
      statusCode: statusCode,
      page: page,
      limit: limit,
    ));
  }
}

final activityLogProvider = AsyncNotifierProvider<ActivityLogNotifier, List<ActivityLog>>(
  ActivityLogNotifier.new,
);
