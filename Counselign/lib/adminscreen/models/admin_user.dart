/// Model for student users (admin view)
class AdminUser {
  final int id;
  final String userId;
  final String fullName;
  final String username;
  final String email;
  final String? course;
  final String? yearLevel;
  final DateTime createdAt;
  final bool isActive;

  AdminUser({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.username,
    required this.email,
    this.course,
    this.yearLevel,
    required this.createdAt,
    this.isActive = true,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      course: json['course'],
      yearLevel: json['year_level'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      isActive:
          json['is_active'] == 1 ||
          json['is_active'] == true ||
          json['is_active'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'username': username,
      'email': email,
      'course': course,
      'year_level': yearLevel,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  String get courseAndYear {
    if (course == null || yearLevel == null) {
      return 'Not specified';
    }
    return '$course - $yearLevel';
  }
}
