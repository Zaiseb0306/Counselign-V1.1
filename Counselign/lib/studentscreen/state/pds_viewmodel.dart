import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/student_profile.dart';
import '../../api/config.dart';
import '../../utils/session.dart';

class PDSViewModel extends ChangeNotifier {
  final Session _session = Session();

  // PDS data
  PDSData? _pdsData;

  // Loading states
  bool _isLoadingPDS = false;
  bool _isSavingPDS = false;

  // Error states
  String? _pdsError;
  String? _saveError;

  // PDS editing state
  bool _isPdsEditingEnabled = false;

  // Form controllers for PDS
  final Map<String, TextEditingController> _pdsControllers = {};

  // Radio button states for PDS
  final Map<String, String> _radioValues = {};

  // Checkbox states for PDS
  final Map<String, bool> _checkboxValues = {};

  // PWD proof file handling
  PlatformFile? _selectedPwdProofFile;

  PlatformFile? get selectedPwdProofFile => _selectedPwdProofFile;

  void setPwdProofFile(PlatformFile? file) {
    _selectedPwdProofFile = file;
    notifyListeners();
  }

  // Getters
  PDSData? get pdsData => _pdsData;

  bool get isLoadingPDS => _isLoadingPDS;
  bool get isSavingPDS => _isSavingPDS;

  String? get pdsError => _pdsError;
  String? get saveError => _saveError;

  bool get isPdsEditingEnabled => _isPdsEditingEnabled;

  // PDS getters
  String get course => _pdsData?.academic?.course ?? '';
  String get yearLevel => _pdsData?.academic?.yearLevel ?? '';
  String get academicStatus => _pdsData?.academic?.academicStatus ?? '';
  String get schoolLastAttended => _pdsData?.academic?.schoolLastAttended ?? '';
  String get locationOfSchool => _pdsData?.academic?.locationOfSchool ?? '';
  String get previousCourseGrade =>
      _pdsData?.academic?.previousCourseGrade ?? '';

  String get lastName => _pdsData?.personal?.lastName ?? '';
  String get firstName => _pdsData?.personal?.firstName ?? '';
  String get middleName => _pdsData?.personal?.middleName ?? '';
  String get dateOfBirth => _pdsData?.personal?.dateOfBirth ?? '';
  String get age => _pdsData?.personal?.age ?? '';
  String get sex => _pdsData?.personal?.sex ?? '';
  String get civilStatus => _pdsData?.personal?.civilStatus ?? '';
  String get contactNumber => _pdsData?.personal?.contactNumber ?? '';
  String get fbAccountName => _pdsData?.personal?.fbAccountName ?? '';
  String get placeOfBirth => _pdsData?.personal?.placeOfBirth ?? '';
  String get religion => _pdsData?.personal?.religion ?? '';
  String get personalEmail => _pdsData?.userEmail ?? '';

  String get permanentZone => _pdsData?.address?.permanentZone ?? '';
  String get permanentBarangay => _pdsData?.address?.permanentBarangay ?? '';
  String get permanentCity => _pdsData?.address?.permanentCity ?? '';
  String get permanentProvince => _pdsData?.address?.permanentProvince ?? '';
  String get presentZone => _pdsData?.address?.presentZone ?? '';
  String get presentBarangay => _pdsData?.address?.presentBarangay ?? '';
  String get presentCity => _pdsData?.address?.presentCity ?? '';
  String get presentProvince => _pdsData?.address?.presentProvince ?? '';

  String get fatherName => _pdsData?.family?.fatherName ?? '';
  String get fatherOccupation => _pdsData?.family?.fatherOccupation ?? '';
  String get fatherEducationalAttainment =>
      _pdsData?.family?.fatherEducationalAttainment ?? '';
  String get fatherAge => _pdsData?.family?.fatherAge ?? '';
  String get fatherContactNumber => _pdsData?.family?.fatherContactNumber ?? '';
  String get motherName => _pdsData?.family?.motherName ?? '';
  String get motherOccupation => _pdsData?.family?.motherOccupation ?? '';
  String get motherEducationalAttainment =>
      _pdsData?.family?.motherEducationalAttainment ?? '';
  String get motherAge => _pdsData?.family?.motherAge ?? '';
  String get motherContactNumber => _pdsData?.family?.motherContactNumber ?? '';
  String get parentsPermanentAddress =>
      _pdsData?.family?.parentsPermanentAddress ?? '';
  String get parentsContactNumber =>
      _pdsData?.family?.parentsContactNumber ?? '';
  String get spouse => _pdsData?.family?.spouse ?? '';
  String get spouseOccupation => _pdsData?.family?.spouseOccupation ?? '';
  String get spouseEducationalAttainment =>
      _pdsData?.family?.spouseEducationalAttainment ?? '';
  String get guardianName => _pdsData?.family?.guardianName ?? '';
  String get guardianAge => _pdsData?.family?.guardianAge ?? '';
  String get guardianOccupation => _pdsData?.family?.guardianOccupation ?? '';
  String get guardianContactNumber =>
      _pdsData?.family?.guardianContactNumber ?? '';

  String get isSoloParent => _pdsData?.circumstances?.isSoloParent ?? '';
  String get isIndigenous => _pdsData?.circumstances?.isIndigenous ?? '';
  String get isBreastfeeding => _pdsData?.circumstances?.isBreastfeeding ?? '';
  String get isPwd => _pdsData?.circumstances?.isPwd ?? '';
  String get pwdDisabilityType =>
      _pdsData?.circumstances?.pwdDisabilityType ?? '';
  String get pwdProofFile => _pdsData?.circumstances?.pwdProofFile ?? '';

  String get residenceType => _pdsData?.residence?.residenceType ?? '';
  String get residenceOtherSpecify =>
      _pdsData?.residence?.residenceOtherSpecify ?? '';
  bool get hasConsent => _pdsData?.residence?.hasConsent == 1;

  List<ServiceItem> get servicesNeeded => _pdsData?.servicesNeeded ?? [];
  List<ServiceItem> get servicesAvailed => _pdsData?.servicesAvailed ?? [];

  String get courseChoiceReason =>
      _pdsData?.otherInfo?.courseChoiceReason ?? '';
  List<String> get familyDescription =>
      _pdsData?.otherInfo?.familyDescription ?? [];
  String get familyDescriptionOther =>
      _pdsData?.otherInfo?.familyDescriptionOther ?? '';
  String get livingCondition => _pdsData?.otherInfo?.livingCondition ?? '';
  String get physicalHealthCondition =>
      _pdsData?.otherInfo?.physicalHealthCondition ?? '';
  String get physicalHealthConditionSpecify =>
      _pdsData?.otherInfo?.physicalHealthConditionSpecify ?? '';
  String get psychTreatment => _pdsData?.otherInfo?.psychTreatment ?? '';

  List<GCSActivity> get gcsActivities => _pdsData?.gcsActivities ?? [];
  List<Award> get awards => _pdsData?.awards ?? [];

  String get userEmail => _pdsData?.userEmail ?? '';

  // Initialize the PDS viewmodel
  Future<void> initialize(String userId, String email) async {
    await loadPDSData();
  }

  // Load PDS data
  Future<void> loadPDSData() async {
    _isLoadingPDS = true;
    _pdsError = null;
    notifyListeners();

    try {
      final response = await _session.get(
        '${ApiConfig.currentBaseUrl}/student/pds/load',
      );

      debugPrint('PDS Load Response Status: ${response.statusCode}');
      debugPrint('PDS Load Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          _pdsData = PDSData.fromJson(data['data']);
          _initializePDSControllers();
          debugPrint('PDS data loaded successfully');
        } else {
          _pdsError = data['message'] ?? 'Failed to load PDS data';
          debugPrint('PDS Load Error: $_pdsError');
        }
      } else {
        _pdsError = 'Failed to load PDS data: ${response.statusCode}';
        debugPrint('PDS Load HTTP Error: $_pdsError');
      }
    } catch (e) {
      _pdsError = 'Error loading PDS data: $e';
      debugPrint('PDS load error: $e');
    } finally {
      _isLoadingPDS = false;
      notifyListeners();
    }
  }

  // Initialize PDS form controllers
  void _initializePDSControllers() {
    if (_pdsData == null) return;

    // Clear existing controllers first
    _pdsControllers.clear();

    // Helper to filter out 'N/A' values - treat 'N/A' as empty
    String filterNA(String value) =>
        (value.isEmpty || value == 'N/A') ? '' : value;

    // Academic
    _pdsControllers['course'] = TextEditingController(text: filterNA(course));
    _pdsControllers['yearLevel'] = TextEditingController(
      text: filterNA(yearLevel),
    );
    _pdsControllers['academicStatus'] = TextEditingController(
      text: filterNA(academicStatus),
    );
    _pdsControllers['schoolLastAttended'] = TextEditingController(
      text: filterNA(schoolLastAttended),
    );
    _pdsControllers['locationOfSchool'] = TextEditingController(
      text: filterNA(locationOfSchool),
    );
    _pdsControllers['previousCourseGrade'] = TextEditingController(
      text: filterNA(previousCourseGrade),
    );

    // Personal
    _pdsControllers['lastName'] = TextEditingController(
      text: filterNA(lastName),
    );
    _pdsControllers['firstName'] = TextEditingController(
      text: filterNA(firstName),
    );
    _pdsControllers['middleName'] = TextEditingController(
      text: filterNA(middleName),
    );
    _pdsControllers['dateOfBirth'] = TextEditingController(
      text: dateOfBirth.isNotEmpty ? _formatDateForUI(dateOfBirth) : '',
    );
    _pdsControllers['age'] = TextEditingController(text: filterNA(age));
    _pdsControllers['sex'] = TextEditingController(text: filterNA(sex));
    _pdsControllers['civilStatus'] = TextEditingController(
      text: filterNA(civilStatus),
    );
    _pdsControllers['contactNumber'] = TextEditingController(
      text: filterNA(contactNumber),
    );
    _pdsControllers['fbAccountName'] = TextEditingController(
      text: filterNA(fbAccountName),
    );
    _pdsControllers['placeOfBirth'] = TextEditingController(
      text: filterNA(placeOfBirth),
    );
    _pdsControllers['religion'] = TextEditingController(
      text: filterNA(religion),
    );

    // Address
    _pdsControllers['permanentZone'] = TextEditingController(
      text: filterNA(permanentZone),
    );
    _pdsControllers['permanentBarangay'] = TextEditingController(
      text: filterNA(permanentBarangay),
    );
    _pdsControllers['permanentCity'] = TextEditingController(
      text: filterNA(permanentCity),
    );
    _pdsControllers['permanentProvince'] = TextEditingController(
      text: filterNA(permanentProvince),
    );
    _pdsControllers['presentZone'] = TextEditingController(
      text: filterNA(presentZone),
    );
    _pdsControllers['presentBarangay'] = TextEditingController(
      text: filterNA(presentBarangay),
    );
    _pdsControllers['presentCity'] = TextEditingController(
      text: filterNA(presentCity),
    );
    _pdsControllers['presentProvince'] = TextEditingController(
      text: filterNA(presentProvince),
    );

    // Family
    _pdsControllers['fatherName'] = TextEditingController(
      text: filterNA(fatherName),
    );
    _pdsControllers['fatherOccupation'] = TextEditingController(
      text: filterNA(fatherOccupation),
    );
    _pdsControllers['fatherEducationalAttainment'] = TextEditingController(
      text: filterNA(fatherEducationalAttainment),
    );
    _pdsControllers['fatherAge'] = TextEditingController(
      text: filterNA(fatherAge),
    );
    _pdsControllers['fatherContactNumber'] = TextEditingController(
      text: filterNA(fatherContactNumber),
    );
    _pdsControllers['motherName'] = TextEditingController(
      text: filterNA(motherName),
    );
    _pdsControllers['motherOccupation'] = TextEditingController(
      text: filterNA(motherOccupation),
    );
    _pdsControllers['motherEducationalAttainment'] = TextEditingController(
      text: filterNA(motherEducationalAttainment),
    );
    _pdsControllers['motherAge'] = TextEditingController(
      text: filterNA(motherAge),
    );
    _pdsControllers['motherContactNumber'] = TextEditingController(
      text: filterNA(motherContactNumber),
    );
    _pdsControllers['parentsPermanentAddress'] = TextEditingController(
      text: filterNA(parentsPermanentAddress),
    );
    _pdsControllers['parentsContactNumber'] = TextEditingController(
      text: filterNA(parentsContactNumber),
    );
    _pdsControllers['spouse'] = TextEditingController(text: filterNA(spouse));
    _pdsControllers['spouseOccupation'] = TextEditingController(
      text: filterNA(spouseOccupation),
    );
    _pdsControllers['spouseEducationalAttainment'] = TextEditingController(
      text: filterNA(spouseEducationalAttainment),
    );
    _pdsControllers['guardianName'] = TextEditingController(
      text: filterNA(guardianName),
    );
    _pdsControllers['guardianAge'] = TextEditingController(
      text: filterNA(guardianAge),
    );
    _pdsControllers['guardianOccupation'] = TextEditingController(
      text: filterNA(guardianOccupation),
    );
    _pdsControllers['guardianContactNumber'] = TextEditingController(
      text: filterNA(guardianContactNumber),
    );

    // Special circumstances
    _pdsControllers['pwdDisabilityType'] = TextEditingController(
      text: filterNA(pwdDisabilityType),
    );
    _pdsControllers['residenceOtherSpecify'] = TextEditingController(
      text: filterNA(residenceOtherSpecify),
    );

    // Services other fields
    final svcOtherText =
        servicesNeeded.where((s) => s.type == 'other').isNotEmpty
        ? servicesNeeded.firstWhere((s) => s.type == 'other').other
        : '';
    final availedOtherText =
        servicesAvailed.where((s) => s.type == 'other').isNotEmpty
        ? servicesAvailed.firstWhere((s) => s.type == 'other').other
        : '';
    _pdsControllers['svcOther'] = TextEditingController(
      text: svcOtherText != null && svcOtherText.isNotEmpty ? svcOtherText : '',
    );
    _pdsControllers['availedOther'] = TextEditingController(
      text: availedOtherText != null && availedOtherText.isNotEmpty
          ? availedOtherText
          : '',
    );

    // Personal email field - auto-populate with user's email
    _pdsControllers['personalEmail'] = TextEditingController(
      text: filterNA(userEmail),
    );

    // Other Info controllers
    _pdsControllers['courseChoiceReason'] = TextEditingController(
      text: filterNA(courseChoiceReason),
    );
    _pdsControllers['familyDescriptionOther'] = TextEditingController(
      text: filterNA(familyDescriptionOther),
    );
    _pdsControllers['physicalHealthConditionSpecify'] = TextEditingController(
      text: filterNA(physicalHealthConditionSpecify),
    );

    // GCS Activities controllers
    final tutorialActivity = gcsActivities.firstWhere(
      (a) => a.type == 'tutorial_with_peers',
      orElse: () => GCSActivity(type: '', tutorialSubjects: ''),
    );
    _pdsControllers['tutorialSubjects'] = TextEditingController(
      text: tutorialActivity.tutorialSubjects ?? '',
    );

    final otherActivity = gcsActivities.firstWhere(
      (a) => a.type == 'other',
      orElse: () => GCSActivity(type: '', other: ''),
    );
    _pdsControllers['gcsOther'] = TextEditingController(
      text: otherActivity.other ?? '',
    );

    // Awards controllers (3 sets)
    for (int i = 0; i < 3; i++) {
      final index = i + 1;
      if (i < awards.length) {
        _pdsControllers['awardName$index'] = TextEditingController(
          text: awards[i].awardName,
        );
        _pdsControllers['awardSchoolOrg$index'] = TextEditingController(
          text: awards[i].schoolOrganization,
        );
        _pdsControllers['awardYear$index'] = TextEditingController(
          text: awards[i].yearReceived,
        );
      } else {
        _pdsControllers['awardName$index'] = TextEditingController(text: '');
        _pdsControllers['awardSchoolOrg$index'] = TextEditingController(
          text: '',
        );
        _pdsControllers['awardYear$index'] = TextEditingController(text: '');
      }
    }

    // Initialize radio button values - filter out 'N/A', use empty string instead
    _radioValues['soloParent'] = filterNA(isSoloParent);
    _radioValues['indigenous'] = filterNA(isIndigenous);
    _radioValues['breastFeeding'] = filterNA(isBreastfeeding);
    _radioValues['pwd'] = filterNA(isPwd);
    _radioValues['residence'] = filterNA(residenceType);
    _radioValues['livingCondition'] = filterNA(livingCondition);
    _radioValues['physicalHealthCondition'] = filterNA(physicalHealthCondition);
    _radioValues['psychTreatment'] = filterNA(psychTreatment);

    // Initialize checkbox values
    _initializeCheckboxValues();
  }

  // Initialize checkbox values from services data
  void _initializeCheckboxValues() {
    // Services needed checkboxes (NO checkbox for 'other' - just text field)
    _checkboxValues['svcCounseling'] = servicesNeeded.any(
      (service) => service.type == 'counseling',
    );
    _checkboxValues['svcInsurance'] = servicesNeeded.any(
      (service) => service.type == 'insurance',
    );
    _checkboxValues['svcSpecialLanes'] = servicesNeeded.any(
      (service) => service.type == 'special_lanes',
    );
    _checkboxValues['svcSafeLearning'] = servicesNeeded.any(
      (service) => service.type == 'safe_learning',
    );
    _checkboxValues['svcEqualAccess'] = servicesNeeded.any(
      (service) => service.type == 'equal_access',
    );

    // Services availed checkboxes (NO checkbox for 'other' - just text field)
    _checkboxValues['availedCounseling'] = servicesAvailed.any(
      (service) => service.type == 'counseling',
    );
    _checkboxValues['availedInsurance'] = servicesAvailed.any(
      (service) => service.type == 'insurance',
    );
    _checkboxValues['availedSpecialLanes'] = servicesAvailed.any(
      (service) => service.type == 'special_lanes',
    );
    _checkboxValues['availedSafeLearning'] = servicesAvailed.any(
      (service) => service.type == 'safe_learning',
    );
    _checkboxValues['availedEqualAccess'] = servicesAvailed.any(
      (service) => service.type == 'equal_access',
    );

    // Consent checkbox
    _checkboxValues['consentAgree'] = hasConsent;

    // Family description checkboxes
    _checkboxValues['familyDescHarmonious'] = familyDescription.contains(
      'harmonious',
    );
    _checkboxValues['familyDescConflict'] = familyDescription.contains(
      'conflict',
    );
    _checkboxValues['familyDescSeparatedParents'] = familyDescription.contains(
      'separated_parents',
    );
    _checkboxValues['familyDescParentsWorkingAbroad'] = familyDescription
        .contains('parents_working_abroad');

    // GCS activities checkboxes
    _checkboxValues['gcsAdjustment'] = gcsActivities.any(
      (a) => a.type == 'adjustment',
    );
    _checkboxValues['gcsSelfConfidence'] = gcsActivities.any(
      (a) => a.type == 'building_self_confidence',
    );
    _checkboxValues['gcsCommunication'] = gcsActivities.any(
      (a) => a.type == 'developing_communication_skills',
    );
    _checkboxValues['gcsStudyHabits'] = gcsActivities.any(
      (a) => a.type == 'study_habits',
    );
    _checkboxValues['gcsTimeManagement'] = gcsActivities.any(
      (a) => a.type == 'time_management',
    );
    _checkboxValues['gcsTutorial'] = gcsActivities.any(
      (a) => a.type == 'tutorial_with_peers',
    );
  }

  // Toggle PDS editing
  void togglePdsEditing() {
    _isPdsEditingEnabled = !_isPdsEditingEnabled;
    notifyListeners();
  }

  // Save PDS data - matching PHP backend expectations exactly
  Future<bool> savePDSData(String email) async {
    _isSavingPDS = true;
    _saveError = null;
    notifyListeners();

    try {
      // Validate and sanitize sex value
      String sexValue = (_pdsControllers['sex']?.text ?? '').trim();
      if (sexValue.isNotEmpty && !['Male', 'Female'].contains(sexValue)) {
        debugPrint(
          'WARNING: Invalid sex value "$sexValue", resetting to empty',
        );
        sexValue = '';
      }

      // Validate and sanitize civilStatus value
      String civilStatusValue = (_pdsControllers['civilStatus']?.text ?? '')
          .trim();
      final validCivilStatuses = [
        'Single',
        'Married',
        'Widowed',
        'Legally Separated',
        'Annulled',
      ];
      if (civilStatusValue.isNotEmpty &&
          !validCivilStatuses.contains(civilStatusValue)) {
        debugPrint(
          'WARNING: Invalid civilStatus value "$civilStatusValue", resetting to empty',
        );
        civilStatusValue = '';
      }

      // Create payload matching PHP preparePDSData method exactly
      final payload = <String, dynamic>{
        // Academic Information - send actual values, empty strings are acceptable
        'course': _pdsControllers['course']?.text ?? '',
        'yearLevel': _pdsControllers['yearLevel']?.text ?? '',
        'academicStatus': _pdsControllers['academicStatus']?.text ?? '',
        'schoolLastAttended': _pdsControllers['schoolLastAttended']?.text ?? '',
        'locationOfSchool': _pdsControllers['locationOfSchool']?.text ?? '',
        'previousCourseGrade':
            _pdsControllers['previousCourseGrade']?.text ?? '',

        // Personal Information - send actual values, empty strings are acceptable
        'lastName': (_pdsControllers['lastName']?.text ?? '').trim(),
        'firstName': (_pdsControllers['firstName']?.text ?? '').trim(),
        'middleName': (_pdsControllers['middleName']?.text ?? '').trim(),
        'dateOfBirth': _pdsControllers['dateOfBirth']?.text.isNotEmpty == true
            ? _formatDateForBackend(_pdsControllers['dateOfBirth']!.text)
            : '',
        'age': (_pdsControllers['age']?.text ?? '').trim(),
        'sex': sexValue, // Use validated sex value
        'civilStatus': civilStatusValue, // Use validated civilStatus value
        'contactNumber': (_pdsControllers['contactNumber']?.text ?? '').trim(),
        'fbAccountName': (_pdsControllers['fbAccountName']?.text ?? '').trim(),
        'placeOfBirth': (_pdsControllers['placeOfBirth']?.text ?? '').trim(),
        'religion': (_pdsControllers['religion']?.text ?? '').trim(),

        // Address Information - send actual values
        'permanentZone': _pdsControllers['permanentZone']?.text ?? '',
        'permanentBarangay': _pdsControllers['permanentBarangay']?.text ?? '',
        'permanentCity': _pdsControllers['permanentCity']?.text ?? '',
        'permanentProvince': _pdsControllers['permanentProvince']?.text ?? '',
        'presentZone': _pdsControllers['presentZone']?.text ?? '',
        'presentBarangay': _pdsControllers['presentBarangay']?.text ?? '',
        'presentCity': _pdsControllers['presentCity']?.text ?? '',
        'presentProvince': _pdsControllers['presentProvince']?.text ?? '',

        // Family Information - send actual values
        'fatherName': _pdsControllers['fatherName']?.text ?? '',
        'fatherOccupation': _pdsControllers['fatherOccupation']?.text ?? '',
        'fatherEducationalAttainment':
            _pdsControllers['fatherEducationalAttainment']?.text ?? '',
        'fatherAge': _pdsControllers['fatherAge']?.text ?? '',
        'fatherContactNumber':
            _pdsControllers['fatherContactNumber']?.text ?? '',
        'motherName': _pdsControllers['motherName']?.text ?? '',
        'motherOccupation': _pdsControllers['motherOccupation']?.text ?? '',
        'motherEducationalAttainment':
            _pdsControllers['motherEducationalAttainment']?.text ?? '',
        'motherAge': _pdsControllers['motherAge']?.text ?? '',
        'motherContactNumber':
            _pdsControllers['motherContactNumber']?.text ?? '',
        'parentsPermanentAddress':
            _pdsControllers['parentsPermanentAddress']?.text ?? '',
        'parentsContactNumber':
            _pdsControllers['parentsContactNumber']?.text ?? '',
        'spouse': _pdsControllers['spouse']?.text ?? '',
        'spouseOccupation': _pdsControllers['spouseOccupation']?.text ?? '',
        'spouseEducationalAttainment':
            _pdsControllers['spouseEducationalAttainment']?.text ?? '',
        'guardianName': _pdsControllers['guardianName']?.text ?? '',
        'guardianAge': _pdsControllers['guardianAge']?.text ?? '',
        'guardianOccupation': _pdsControllers['guardianOccupation']?.text ?? '',
        'guardianContactNumber':
            _pdsControllers['guardianContactNumber']?.text ?? '',

        // Special Circumstances - send radio values (empty string if not selected)
        'soloParent': _radioValues['soloParent'] ?? '',
        'indigenous': _radioValues['indigenous'] ?? '',
        'breastFeeding': _radioValues['breastFeeding'] ?? '',
        'pwd': _radioValues['pwd'] ?? '',
        'pwdSpecify': _pdsControllers['pwdDisabilityType']?.text ?? '',

        // Services Needed
        'services_needed': _buildServicesJson('needed'),

        // Services Availed
        'services_availed': _buildServicesJson('availed'),

        // Residence Information - ALWAYS send consent as '1' (user agreed when first filling)
        'residence': _radioValues['residence'] ?? '',
        'resOtherText': _pdsControllers['residenceOtherSpecify']?.text ?? '',
        // CRITICAL FIX: Always send '1' for consent (user already agreed initially)
        'consentAgree': '1',

        // Other Information
        'courseChoiceReason': _pdsControllers['courseChoiceReason']?.text ?? '',
        'family_description': _buildFamilyDescriptionJson(),
        'familyDescriptionOther':
            _pdsControllers['familyDescriptionOther']?.text ?? '',
        'livingCondition': _radioValues['livingCondition'] ?? '',
        'physicalHealthCondition':
            _radioValues['physicalHealthCondition'] ?? '',
        'physicalHealthConditionSpecify':
            _pdsControllers['physicalHealthConditionSpecify']?.text ?? '',
        'psychTreatment': _radioValues['psychTreatment'] ?? '',

        // GCS Activities
        'gcs_activities': _buildGCSActivitiesJson(),

        // Awards
        'awards': _buildAwardsJson(),
      };

      // Debug: Log the data being sent (remove in production)
      debugPrint('=== PDS SAVE PAYLOAD ===');
      debugPrint('consentAgree: ${payload['consentAgree']}');

      // Debug: Check what's in the controllers BEFORE building payload
      debugPrint('\n=== CONTROLLER VALUES (RAW) ===');
      debugPrint('course controller: "${_pdsControllers['course']?.text}"');
      debugPrint(
        'yearLevel controller: "${_pdsControllers['yearLevel']?.text}"',
      );
      debugPrint(
        'academicStatus controller: "${_pdsControllers['academicStatus']?.text}"',
      );
      debugPrint('lastName controller: "${_pdsControllers['lastName']?.text}"');
      debugPrint(
        'firstName controller: "${_pdsControllers['firstName']?.text}"',
      );
      debugPrint('sex controller: "${_pdsControllers['sex']?.text}"');
      debugPrint(
        'civilStatus controller: "${_pdsControllers['civilStatus']?.text}"',
      );
      debugPrint('================================\n');

      debugPrint('course: ${payload['course']}');
      debugPrint('yearLevel: ${payload['yearLevel']}');
      debugPrint('academicStatus: ${payload['academicStatus']}');
      debugPrint('lastName: ${payload['lastName']}');
      debugPrint('firstName: ${payload['firstName']}');
      debugPrint(
        'sex: "${payload['sex']}" (length: ${(payload['sex'] as String).length})',
      );
      debugPrint(
        'civilStatus: "${payload['civilStatus']}" (length: ${(payload['civilStatus'] as String).length})',
      );
      payload.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          debugPrint('$key: $value');
        }
      });
      debugPrint('========================');

      // Prepare files for upload if PWD proof file is selected
      Map<String, List<int>>? files;
      if (_selectedPwdProofFile != null) {
        try {
          final file = File(_selectedPwdProofFile!.path!);
          final fileBytes = await file.readAsBytes();
          files = {'pwdProof': fileBytes};
          debugPrint(
            'PDS Save - Including PWD proof file: ${_selectedPwdProofFile!.name}',
          );
        } catch (e) {
          debugPrint('PDS Save - Error reading PWD proof file: $e');
          _saveError = 'Error reading PWD proof file: $e';
          return false;
        }
      }

      // Convert payload to Map<String, String> for form data
      final stringFields = payload.map((key, value) {
        // Convert to string, but handle null properly
        final stringValue = value == null ? '' : value.toString();
        return MapEntry(key, stringValue);
      });

      // Send as multipart form data (backend expects form-data format)
      final response = await _session.post(
        '${ApiConfig.currentBaseUrl}/student/pds/save',
        fields: stringFields,
        files: files,
      );

      debugPrint('PDS Save Response Status: ${response.statusCode}');
      debugPrint('PDS Save Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _isPdsEditingEnabled = false;

          // Clear selected file after successful save
          _selectedPwdProofFile = null;

          await loadPDSData(); // Reload data
          debugPrint('PDS data saved successfully');
          return true;
        } else {
          _saveError = data['message'] ?? 'Failed to save PDS data';
          debugPrint('PDS Save Error: $_saveError');
        }
      } else {
        _saveError = 'Failed to save PDS data: ${response.statusCode}';
        debugPrint('PDS Save HTTP Error: $_saveError');
      }
    } catch (e) {
      _saveError = 'Error saving PDS data: $e';
      debugPrint('PDS save error: $e');
    } finally {
      _isSavingPDS = false;
      notifyListeners();
    }

    return false;
  }

  // Helper method to format date for UI display
  String _formatDateForUI(String dateString) {
    try {
      // Check if the date is already in dd/MM/yyyy format (from UI)
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(dateString)) {
        return dateString;
      }

      // Check if the date is in yyyy-MM-dd format (from backend)
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateString)) {
        final parsedDate = DateFormat('yyyy-MM-dd').parse(dateString);
        return DateFormat('dd/MM/yyyy').format(parsedDate);
      }

      // If neither format matches, return empty string
      debugPrint(
        'PDS Date Format Error: Unrecognized date format: $dateString',
      );
      return '';
    } catch (e) {
      debugPrint(
        'PDS Date Format Error: Failed to parse date "$dateString": $e',
      );
      return '';
    }
  }

  // Helper method to format date for backend
  String _formatDateForBackend(String dateString) {
    try {
      // Check if the date is already in yyyy-MM-dd format (from backend)
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateString)) {
        return dateString;
      }

      // Check if the date is in dd/MM/yyyy format (from UI)
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(dateString)) {
        final parsedDate = DateFormat('dd/MM/yyyy').parse(dateString);
        return DateFormat('yyyy-MM-dd').format(parsedDate);
      }

      // If neither format matches, return empty string
      debugPrint(
        'PDS Date Format Error: Unrecognized date format: $dateString',
      );
      return '';
    } catch (e) {
      debugPrint(
        'PDS Date Format Error: Failed to parse date "$dateString": $e',
      );
      return '';
    }
  }

  // Helper method to build services JSON
  String _buildServicesJson(String type) {
    final services = <Map<String, dynamic>>[];
    final checkboxes = type == 'needed'
        ? [
            {'id': 'svcCounseling', 'type': 'counseling'},
            {'id': 'svcInsurance', 'type': 'insurance'},
            {'id': 'svcSpecialLanes', 'type': 'special_lanes'},
            {'id': 'svcSafeLearning', 'type': 'safe_learning'},
            {'id': 'svcEqualAccess', 'type': 'equal_access'},
          ]
        : [
            {'id': 'availedCounseling', 'type': 'counseling'},
            {'id': 'availedInsurance', 'type': 'insurance'},
            {'id': 'availedSpecialLanes', 'type': 'special_lanes'},
            {'id': 'availedSafeLearning', 'type': 'safe_learning'},
            {'id': 'availedEqualAccess', 'type': 'equal_access'},
          ];

    for (final service in checkboxes) {
      if (_checkboxValues[service['id']] == true) {
        services.add({'type': service['type'], 'other': null});
      }
    }

    // Match JS logic: only add 'other' if text field has value (no checkbox check)
    final otherText =
        _pdsControllers[type == 'needed' ? 'svcOther' : 'availedOther']?.text ??
        '';
    if (otherText.isNotEmpty) {
      services.add({'type': 'other', 'other': otherText});
    }

    return services.isNotEmpty ? json.encode(services) : '[]';
  }

  // Helper method to build family description JSON
  String _buildFamilyDescriptionJson() {
    final descriptions = <String>[];

    if (_checkboxValues['familyDescHarmonious'] == true) {
      descriptions.add('harmonious');
    }
    if (_checkboxValues['familyDescConflict'] == true) {
      descriptions.add('conflict');
    }
    if (_checkboxValues['familyDescSeparatedParents'] == true) {
      descriptions.add('separated_parents');
    }
    if (_checkboxValues['familyDescParentsWorkingAbroad'] == true) {
      descriptions.add('parents_working_abroad');
    }

    return descriptions.isNotEmpty ? json.encode(descriptions) : '[]';
  }

  // Helper method to build GCS activities JSON
  String _buildGCSActivitiesJson() {
    final activities = <Map<String, dynamic>>[];
    final activityCheckboxes = [
      {'id': 'gcsAdjustment', 'type': 'adjustment'},
      {'id': 'gcsSelfConfidence', 'type': 'building_self_confidence'},
      {'id': 'gcsCommunication', 'type': 'developing_communication_skills'},
      {'id': 'gcsStudyHabits', 'type': 'study_habits'},
      {'id': 'gcsTimeManagement', 'type': 'time_management'},
    ];

    for (final activity in activityCheckboxes) {
      if (_checkboxValues[activity['id']] == true) {
        activities.add({
          'type': activity['type'],
          'other': null,
          'tutorial_subjects': null,
        });
      }
    }

    // Tutorial with peers
    if (_checkboxValues['gcsTutorial'] == true) {
      final tutorialSubjects = _pdsControllers['tutorialSubjects']?.text ?? '';
      activities.add({
        'type': 'tutorial_with_peers',
        'other': null,
        'tutorial_subjects': tutorialSubjects.isNotEmpty
            ? tutorialSubjects
            : null,
      });
    }

    // Other activity
    final gcsOther = _pdsControllers['gcsOther']?.text ?? '';
    if (gcsOther.isNotEmpty) {
      activities.add({
        'type': 'other',
        'other': gcsOther,
        'tutorial_subjects': null,
      });
    }

    return activities.isNotEmpty ? json.encode(activities) : '[]';
  }

  // Helper method to build awards JSON
  String _buildAwardsJson() {
    final awards = <Map<String, dynamic>>[];

    for (int i = 1; i <= 3; i++) {
      final awardName = _pdsControllers['awardName$i']?.text ?? '';
      final schoolOrg = _pdsControllers['awardSchoolOrg$i']?.text ?? '';
      final year = _pdsControllers['awardYear$i']?.text ?? '';

      if (awardName.isNotEmpty && schoolOrg.isNotEmpty && year.isNotEmpty) {
        awards.add({
          'award_name': awardName,
          'school_organization': schoolOrg,
          'year_received': year,
        });
      }
    }

    return awards.isNotEmpty ? json.encode(awards) : '[]';
  }

  // Get controller for PDS field
  TextEditingController? getController(String fieldName) {
    return _pdsControllers[fieldName];
  }

  // Get radio button value
  String getRadioValue(String fieldName) {
    return _radioValues[fieldName] ?? '';
  }

  // Set radio button value
  void setRadioValue(String fieldName, String value) {
    _radioValues[fieldName] = value;
    notifyListeners();
  }

  // Get checkbox value
  bool getCheckboxValue(String fieldName) {
    return _checkboxValues[fieldName] ?? false;
  }

  // Set checkbox value
  void setCheckboxValue(String fieldName, bool value) {
    _checkboxValues[fieldName] = value;
    notifyListeners();
  }

  // Clear errors
  void clearErrors() {
    _pdsError = null;
    _saveError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _pdsControllers.values) {
      controller.dispose();
    }
    _pdsControllers.clear();
    super.dispose();
  }
}
