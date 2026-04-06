class Appointment {
  final int id;
  final int userId;
  final String userName;
  final String userEmail;
  final String preferredDate;
  final String? preferredTime;
  final String? consultationType;
  final String? description;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.preferredDate,
    this.preferredTime,
    this.consultationType,
    this.description,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      preferredDate: json['preferred_date'] ?? '',
      preferredTime: json['preferred_time'],
      consultationType: json['consultation_type'],
      description: json['description'],
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'preferred_date': preferredDate,
      'preferred_time': preferredTime,
      'consultation_type': consultationType,
      'description': description,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}