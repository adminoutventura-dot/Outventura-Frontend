class ActivityLog {
  final int id;
  final String method;
  final String url;
  final int? statusCode;
  final String? userRole;
  final int? userId;
  final int duration;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.method,
    required this.url,
    this.statusCode,
    this.userRole,
    this.userId,
    required this.duration,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as int,
      method: json['method'] as String,
      url: json['url'] as String,
      statusCode: json['statusCode'] as int?,
      userRole: json['userRole'] as String?,
      userId: json['userId'] as int?,
      duration: json['duration'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method,
      'url': url,
      'statusCode': statusCode,
      'userRole': userRole,
      'userId': userId,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
