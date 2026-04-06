import 'package:flutter/foundation.dart';
import '../../utils/user_display_helper.dart';

class UserProfile {
  final String userId;
  final String? username;
  final String? email;
  final String? lastLogin;
  final String? profileImage;
  final String? courseYear;
  final String? firstName;
  final String? lastName;
  final String? fullName;

  UserProfile({
    required this.userId,
    this.username,
    this.email,
    this.lastLogin,
    this.profileImage,
    this.courseYear,
    this.firstName,
    this.lastName,
    this.fullName,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 UserProfile.fromJson - Raw JSON: $json');
    final profile = UserProfile(
      userId: json['user_id'] ?? json['id'] ?? '',
      username: json['username'],
      email: json['email'],
      lastLogin: json['last_login'],
      profileImage: json['profile_picture'] ?? json['profile_image'],
      courseYear: json['courseYear'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: json['full_name'],
    );
    debugPrint(
      '🔍 UserProfile parsed - firstName: ${profile.firstName}, lastName: ${profile.lastName}, fullName: ${profile.fullName}',
    );
    debugPrint(
      '🔍 UserProfile displayName: ${profile.displayName}, hasName: ${profile.hasName}',
    );
    return profile;
  }

  String get displayName => UserDisplayHelper.getDisplayName(
    userId: userId,
    firstName: firstName,
    lastName: lastName,
    fullName: fullName,
  );

  bool get hasName => UserDisplayHelper.hasName(
    userId: userId,
    firstName: firstName,
    lastName: lastName,
    fullName: fullName,
  );
  String get profileImageUrl {
    if (profileImage == null || profileImage!.isEmpty) {
      return 'Photos/profile.png';
    }

    // If it's already a full URL, return as is
    if (profileImage!.startsWith('http')) {
      return profileImage!;
    }

    // If it starts with Photos/, return as is
    if (profileImage!.startsWith('Photos/')) {
      return profileImage!;
    }

    // Otherwise, prepend Photos/ if not already there
    return profileImage!.startsWith('/')
        ? profileImage!.substring(1)
        : profileImage!;
  }
}
