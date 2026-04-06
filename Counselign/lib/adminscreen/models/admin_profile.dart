class AdminProfile {
  final int id;
  final String name;
  final String email;
  final String profileImageUrl;
  final String role;
  final DateTime? lastLogin;
  final DateTime? createdAt;

  AdminProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.role,
    this.lastLogin,
    this.createdAt,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profile_image_url'] ?? 'Photos/UGC-Logo.png',
      role: json['role'] ?? 'Admin',
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'role': role,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}