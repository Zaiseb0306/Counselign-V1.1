/// Model for counselor schedule (admin view)
class CounselorSchedule {
  final int counselorId;
  final String counselorName;
  final String degree;
  final Map<String, List<String>> schedule; // Day -> List of time slots

  CounselorSchedule({
    required this.counselorId,
    required this.counselorName,
    required this.degree,
    required this.schedule,
  });

  factory CounselorSchedule.fromJson(Map<String, dynamic> json) {
    return CounselorSchedule(
      counselorId: json['counselor_id'] ?? 0,
      counselorName: json['counselor_name'] ?? '',
      degree: json['degree'] ?? '',
      schedule: json['schedule'] != null
          ? Map<String, List<String>>.from(
              json['schedule'].map(
                (key, value) => MapEntry(key, List<String>.from(value ?? [])),
              ),
            )
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'counselor_id': counselorId,
      'counselor_name': counselorName,
      'degree': degree,
      'schedule': schedule,
    };
  }
}

/// Model for counselor info
class CounselorInfo {
  final int id;
  final String counselorId;
  final String name;
  final String degree;
  final String email;
  final String? contactNumber;
  final String? address;
  final String? timeScheduled;
  final String? availableDays;
  final String? specialization;
  final String? licenseNumber;
  final String? profilePicture;

  CounselorInfo({
    required this.id,
    required this.counselorId,
    required this.name,
    required this.degree,
    required this.email,
    this.contactNumber,
    this.address,
    this.timeScheduled,
    this.availableDays,
    this.specialization,
    this.licenseNumber,
    this.profilePicture,
  });

  factory CounselorInfo.fromJson(Map<String, dynamic> json) {
    return CounselorInfo(
      id: json['id'] ?? 0,
      counselorId: json['counselor_id'] ?? '',
      name: json['name'] ?? '',
      degree: json['degree'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contact_number'],
      address: json['address'],
      timeScheduled: json['time_scheduled'],
      availableDays: json['available_days'],
      specialization: json['specialization'],
      licenseNumber: json['license_number'],
      profilePicture: json['profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'counselor_id': counselorId,
      'name': name,
      'degree': degree,
      'email': email,
      'contact_number': contactNumber,
      'address': address,
      'time_scheduled': timeScheduled,
      'available_days': availableDays,
      'specialization': specialization,
      'license_number': licenseNumber,
      'profile_picture': profilePicture,
    };
  }
}
