/// Model for student PDS data (display in modal)
class StudentPds {
  final String studentId;
  final String fullName;
  final String email;
  final String? profilePicture;

  // Academic Information
  final String? course;
  final String? yearLevel;
  final String? academicStatus;

  // Personal Information
  final String? lastName;
  final String? firstName;
  final String? middleName;
  final String? dateOfBirth;
  final String? age;
  final String? sex;
  final String? civilStatus;
  final String? contactNumber;
  final String? fbAccount;
  final String? personalEmail;

  // Permanent Address
  final String? permanentZone;
  final String? permanentBarangay;
  final String? permanentCity;
  final String? permanentProvince;

  // Present Address
  final String? presentZone;
  final String? presentBarangay;
  final String? presentCity;
  final String? presentProvince;

  // Family Information
  final String? fatherName;
  final String? fatherOccupation;
  final String? motherName;
  final String? motherOccupation;
  final String? spouse;
  final String? guardianContact;

  // Other Information
  final String? soloParent;
  final String? indigenous;
  final String? breastfeeding;
  final String? pwd;
  final String? pwdType;
  final String? pwdProof;
  final String? servicesNeeded;
  final String? servicesAvailed;
  final String? residence;
  final String? consent;

  StudentPds({
    required this.studentId,
    required this.fullName,
    required this.email,
    this.profilePicture,
    this.course,
    this.yearLevel,
    this.academicStatus,
    this.lastName,
    this.firstName,
    this.middleName,
    this.dateOfBirth,
    this.age,
    this.sex,
    this.civilStatus,
    this.contactNumber,
    this.fbAccount,
    this.personalEmail,
    this.permanentZone,
    this.permanentBarangay,
    this.permanentCity,
    this.permanentProvince,
    this.presentZone,
    this.presentBarangay,
    this.presentCity,
    this.presentProvince,
    this.fatherName,
    this.fatherOccupation,
    this.motherName,
    this.motherOccupation,
    this.spouse,
    this.guardianContact,
    this.soloParent,
    this.indigenous,
    this.breastfeeding,
    this.pwd,
    this.pwdType,
    this.pwdProof,
    this.servicesNeeded,
    this.servicesAvailed,
    this.residence,
    this.consent,
  });

  factory StudentPds.fromJson(Map<String, dynamic> json) {
    return StudentPds(
      studentId: json['student_id'] ?? json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profile_picture'],
      course: json['course'],
      yearLevel: json['year_level'],
      academicStatus: json['academic_status'],
      lastName: json['last_name'],
      firstName: json['first_name'],
      middleName: json['middle_name'],
      dateOfBirth: json['date_of_birth'],
      age: json['age'],
      sex: json['sex'],
      civilStatus: json['civil_status'],
      contactNumber: json['contact_number'],
      fbAccount: json['fb_account'],
      personalEmail: json['personal_email'] ?? json['email'],
      permanentZone: json['permanent_zone'],
      permanentBarangay: json['permanent_barangay'],
      permanentCity: json['permanent_city'],
      permanentProvince: json['permanent_province'],
      presentZone: json['present_zone'],
      presentBarangay: json['present_barangay'],
      presentCity: json['present_city'],
      presentProvince: json['present_province'],
      fatherName: json['father_name'],
      fatherOccupation: json['father_occupation'],
      motherName: json['mother_name'],
      motherOccupation: json['mother_occupation'],
      spouse: json['spouse'],
      guardianContact: json['guardian_contact'],
      soloParent: json['solo_parent'],
      indigenous: json['indigenous'],
      breastfeeding: json['breastfeeding'],
      pwd: json['pwd'],
      pwdType: json['pwd_type'],
      pwdProof: json['pwd_proof'],
      servicesNeeded: json['services_needed'],
      servicesAvailed: json['services_availed'],
      residence: json['residence'],
      consent: json['consent'],
    );
  }

  bool get hasPwd {
    return pwd == 'Yes' || pwd == 'yes' || pwd == '1';
  }
}
