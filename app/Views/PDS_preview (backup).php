<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>PDS Preview - <?= esc($user_info['user_id']) ?></title>
    <link rel="icon" href="<?= base_url('Photos/counselign.ico') ?>" sizes="16x16 32x32" type="image/x-icon">
    <link rel="stylesheet" href="<?= base_url('css/pds_preview.css') . '?v=' . @filemtime(FCPATH . 'css/pds_preview.css') ?>">
    <style>
        @media print {
            .print-controls {
                display: none !important;
            }
        }
    </style>
</head>
<body>
    <?php
    // Helper functions for data formatting
    function formatValue($value, $default = '') {
        return ($value && $value !== 'N/A' && $value !== '') ? esc($value) : $default;
    }
    
    function formatDate($dateString) {
        if (!$dateString || $dateString === 'N/A') return '';
        try {
            $date = new DateTime($dateString);
            return $date->format('F d, Y');
        } catch (Exception $e) {
            return $dateString;
        }
    }
    
    function formatDateShort($dateString) {
        if (!$dateString || $dateString === 'N/A') return '';
        try {
            $date = new DateTime($dateString);
            return $date->format('m/d/Y');
        } catch (Exception $e) {
            return $dateString;
        }
    }
    
    function getProfilePictureUrl($path) {
        if (empty($path) || $path === 'Photos/profile.png') {
            return base_url('Photos/profile.png');
        }
        if (strpos($path, 'http') === 0) {
            return $path;
        }
        return base_url($path);
    }
    
    $pds = $pds_data ?? [];
    $academic = $pds['academic_info'] ?? [];
    $personal = $pds['personal_info'] ?? [];
    $address = $pds['address_info'] ?? [];
    $family = $pds['family_info'] ?? [];
    $residence = $pds['residence_info'] ?? [];
    $other = $pds['other_info'] ?? [];
    $special = $pds['special_circumstances'] ?? [];
    $servicesNeeded = $pds['services_needed'] ?? [];
    $servicesAvailed = $pds['services_availed'] ?? [];
    $gcsActivities = $pds['gcs_activities'] ?? [];
    $awards = $pds['awards'] ?? [];
    
    // Format family description
    $familyDesc = '';
    if (isset($other['family_description']) && !empty($other['family_description'])) {
        $descMap = [
            'harmonious' => 'a family with harmonious relationship among family members',
            'conflict' => 'a family having conflict with some family members',
            'separated_parents' => 'a family with separated parents',
            'parents_working_abroad' => 'a family with parents working abroad'
        ];
        
        $familyDescArray = [];
        if (is_array($other['family_description'])) {
            foreach ($other['family_description'] as $descKey) {
                if (is_string($descKey) && isset($descMap[$descKey])) {
                    $familyDescArray[] = $descMap[$descKey];
                } elseif (is_string($descKey)) {
                    $familyDescArray[] = $descKey;
                }
            }
        } elseif (is_string($other['family_description'])) {
            $familyDescArray[] = $descMap[$other['family_description']] ?? $other['family_description'];
        }
        
        if (!empty($familyDescArray)) {
            $familyDesc = implode(', ', $familyDescArray);
        }
        
        if (!empty($other['family_description_other'])) {
            if (!empty($familyDesc)) {
                $familyDesc .= ', others, pls. specify: ' . $other['family_description_other'];
            } else {
                $familyDesc = 'others, pls. specify: ' . $other['family_description_other'];
            }
        }
    }
    
    // Format residence
    $residenceType = '';
    if (!empty($residence['residence_type'])) {
        $resMap = [
            'at_home' => 'at home',
            'boarding_house' => 'boarding house',
            'relatives' => 'relatives',
            'friends' => 'friends'
        ];
        $residenceType = $resMap[$residence['residence_type']] ?? $residence['residence_type'];
        if (!empty($residence['residence_other_specify'])) {
            if (!empty($residenceType)) {
                $residenceType .= ', others, pls. specify: ' . $residence['residence_other_specify'];
            } else {
                $residenceType = 'others, pls. specify: ' . $residence['residence_other_specify'];
            }
        }
    }
    
    // Format living condition (from other_info, not residence_info)
    $livingCondition = '';
    if (!empty($other['living_condition'])) {
        $livingCondition = $other['living_condition'] === 'good_environment' 
            ? 'good environment for learning' 
            : 'not-so-good environment for learning';
    }
    
    // Format health condition
    $healthCondition = '';
    if (!empty($other['physical_health_condition'])) {
        $healthValue = strtolower($other['physical_health_condition']);
        if (($healthValue === 'yes') && !empty($other['physical_health_condition_specify'])) {
            $healthCondition = 'Yes, pls. specify: ' . $other['physical_health_condition_specify'];
        } elseif ($healthValue === 'no') {
            $healthCondition = 'No';
        } else {
            $healthCondition = ucfirst($other['physical_health_condition']);
        }
    }
    
    // Format psych treatment
    $psychTreatment = '';
    if (!empty($other['psych_treatment'])) {
        $psychValue = strtolower($other['psych_treatment']);
        if ($psychValue === 'yes') {
            $psychTreatment = 'Yes';
        } elseif ($psychValue === 'no') {
            $psychTreatment = 'No';
        } else {
            $psychTreatment = ucfirst($other['psych_treatment']);
        }
    }
    
    // Format GCS activities
    $gcsActivitiesList = [];
    if (!empty($gcsActivities)) {
        $activityMap = [
            'adjustment' => 'Adjustment (dealing with people, handling pressures, environment, class schedules, etc.)',
            'building_self_confidence' => 'Building Self-Confidence',
            'developing_communication_skills' => 'Developing Communication Skills',
            'study_habits' => 'Study Habits',
            'time_management' => 'Time Management',
            'tutorial_with_peers' => 'Tutorial with Peers'
        ];
        foreach ($gcsActivities as $activity) {
            if ($activity['type'] === 'tutorial_with_peers' && !empty($activity['tutorial_subjects'])) {
                $gcsActivitiesList[] = 'Tutorial with Peers (Please specify the subject/s): ' . $activity['tutorial_subjects'];
            } elseif ($activity['type'] === 'other' && !empty($activity['other'])) {
                $gcsActivitiesList[] = 'others, pls. specify: ' . $activity['other'];
            } elseif (isset($activityMap[$activity['type']])) {
                $gcsActivitiesList[] = $activityMap[$activity['type']];
            }
        }
    }
    
    // Calculate age
    $age = '';
    if (!empty($personal['date_of_birth'])) {
        try {
            $birthDate = new DateTime($personal['date_of_birth']);
            $today = new DateTime();
            $age = $today->diff($birthDate)->y;
        } catch (Exception $e) {
            $age = '';
        }
    }
    ?>
    
    <!-- Print Controls -->
    <div class="print-controls">
        <button onclick="window.print()" class="btn-print">🖨️ Print PDS</button>
        <button onclick="downloadPDF()" class="btn-download">📥 Download as PDF</button>
    </div>
    
    <!-- Page 1 -->
    <div class="pds-page page-1">
        <!-- Document Code Table (Top Right) -->
        <div class="document-stamp">
            <table class="stamp-table">
                <tr>
                    <td colspan="3" class="stamp-header">Document Code No.</td>
                </tr>
                <tr>
                    <td colspan="3" class="stamp-code">FM-USTP-GCS-02</td>
                </tr>
                <tr>
                    <td class="stamp-label">Rev. No.</td>
                    <td class="stamp-label">Effective Date</td>
                    <td class="stamp-label">Page No.</td>
                </tr>
                <tr>
                    <td class="stamp-value">00</td>
                    <td class="stamp-value">03.17.25</td>
                    <td class="stamp-value">1 of 2</td>
                </tr>
            </table>
        </div>
        
        <!-- University Header -->
        <div class="university-header">
            <div class="ustp-logo-container">
                <img src="<?= base_url('Photos/USTP.png') ?>" alt="USTP Logo" class="ustp-logo-image">
            </div>
            <div class="university-name">UNIVERSITY OF SCIENCE AND TECHNOLOGY OF SOUTHERN PHILIPPINES</div>
            <div class="campuses">Alubijid | Balubal | Cagayan de Oro | Claveria | Jasaan | Oroquieta | Panaon | Villanueva</div>
            <div class="department-name">GUIDANCE AND COUNSELING SERVICES</div>
            <div class="form-title">STUDENT'S PERSONAL DATA SHEET</div>
        </div>
        
        <!-- Photo Box -->
        <div class="photo-box">
            <img src="<?= getProfilePictureUrl($user_info['profile_picture']) ?>" alt="Student Photo" class="student-photo">
        </div>
        
        <!-- Confidentiality Notice -->
        <div class="confidentiality-notice">
            <p>The Guidance and Counseling Services (GCS) observes <strong>STRICT CONFIDENTIALITY</strong> on the personal information shared in this form according to the ethical principles of privacy and in compliance with the Data Privacy Act. However, please take note that the information will be disclosed in the following circumstances:</p>
            <ol>
                <li>Threat or risk of life (of the client, his/her immediate family, victim of abuse)</li>
                <li>The client can cause danger to the lives and health of other people.</li>
            </ol>
            <p>Moreover, information may also be given to agencies (e.g. DSWD, Police, Women and Children Protection Unit, Rehabilitation Unit Hospitals and other health providers) that can facilitate or address client's need and situation.</p>
            <p class="instruction"><strong>Instruction:</strong> Please provide honest response to the information needed. Rest assured that data gathered will be treated with utmost confidentiality in accordance with Data Privacy Act.</p>
        </div>
        
        <!-- Personal Background Section -->
        <div class="section personal-background">
            <h3 class="section-title">PERSONAL BACKGROUND</h3>
            
            <div class="form-row">
                <div class="form-field">
                    <label>Course/Track:</label>
                    <span class="field-value"><?= formatValue($academic['course'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Major/Strand:</label>
                    <span class="field-value"><?= formatValue($academic['major_or_strand'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Grade/Year Level:</label>
                    <span class="field-value"><?= formatValue($academic['year_level'] ?? '') ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field">
                    <label>First Name:</label>
                    <span class="field-value"><?= formatValue($personal['first_name'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Gender:</label>
                    <span class="field-value"><?= formatValue($personal['sex'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Date of Birth: <span style="font-size: 7px;">(month) (day) (year)</span></label>
                    <span class="field-value"><?= formatDateShort($personal['date_of_birth'] ?? '') ?></span>
                </div>
                <div class="form-field" style="max-width: 60px;">
                    <label>Age:</label>
                    <span class="field-value"><?= $age ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field">
                    <label>Last Name:</label>
                    <span class="field-value"><?= formatValue($personal['last_name'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Place of Birth:</label>
                    <span class="field-value"><?= formatValue($personal['place_of_birth'] ?? '') ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field">
                    <label>Middle Name:</label>
                    <span class="field-value"><?= formatValue($personal['middle_name'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Civil Status: <span style="font-size: 7px;">☐Single ☐Married ☐Widowed ☐Divorced ☐Separated</span></label>
                    <span class="field-value"><?= formatValue($personal['civil_status'] ?? '') ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field">
                    <label>Religion:</label>
                    <span class="field-value"><?= formatValue($personal['religion'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Contact Number:</label>
                    <span class="field-value"><?= formatValue($personal['contact_number'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>E-mail Address:</label>
                    <span class="field-value"><?= formatValue($personal['email_address'] ?? $user_info['email'] ?? '') ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field full-width">
                    <label>Permanent Address: <span style="font-size: 7px;">(street) (brgy) (city) (province)</span></label>
                    <span class="field-value"><?= formatValue($address['permanent_zone'] ?? '') ?><?= !empty($address['permanent_zone']) ? ', ' : '' ?><?= formatValue($address['permanent_barangay'] ?? '') ?><?= !empty($address['permanent_barangay']) ? ', ' : '' ?><?= formatValue($address['permanent_city'] ?? '') ?><?= !empty($address['permanent_city']) ? ', ' : '' ?><?= formatValue($address['permanent_province'] ?? '') ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field full-width">
                    <label>Present Address: <span style="font-size: 7px;">(street) (brgy) (city) (province)</span></label>
                    <span class="field-value"><?= formatValue($address['present_zone'] ?? '') ?><?= !empty($address['present_zone']) ? ', ' : '' ?><?= formatValue($address['present_barangay'] ?? '') ?><?= !empty($address['present_barangay']) ? ', ' : '' ?><?= formatValue($address['present_city'] ?? '') ?><?= !empty($address['present_city']) ? ', ' : '' ?><?= formatValue($address['present_province'] ?? '') ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field">
                    <label>School Last Attended:</label>
                    <span class="field-value"><?= formatValue($academic['school_last_attended'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Location of School:</label>
                    <span class="field-value"><?= formatValue($academic['location_of_school'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Previous Course/Grade:</label>
                    <span class="field-value"><?= formatValue($academic['previous_course_grade'] ?? '') ?></span>
                </div>
            </div>
        </div>
        
        <!-- Family Background Section -->
        <div class="section family-background">
            <h3 class="section-title">FAMILY BACKGROUND</h3>
            
            <div class="form-row">
                <div class="form-field" style="flex: 2;">
                    <label>Name of Father:</label>
                    <span class="field-value"><?= formatValue($family['father_name'] ?? '') ?></span>
                </div>
                <div class="form-field" style="max-width: 60px;">
                    <label>Age:</label>
                    <span class="field-value"><?= formatValue($family['father_age'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Contact No:</label>
                    <span class="field-value"><?= formatValue($family['father_contact_number'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Educational Attainment:</label>
                    <span class="field-value"><?= formatValue($family['father_educational_attainment'] ?? '') ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field full-width">
                    <label>Occupation:</label>
                    <span class="field-value"><?= formatValue($family['father_occupation'] ?? '') ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field" style="flex: 2;">
                    <label>Name of Mother:</label>
                    <span class="field-value"><?= formatValue($family['mother_name'] ?? '') ?></span>
                </div>
                <div class="form-field" style="max-width: 60px;">
                    <label>Age:</label>
                    <span class="field-value"><?= formatValue($family['mother_age'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Contact No:</label>
                    <span class="field-value"><?= formatValue($family['mother_contact_number'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Educational Attainment:</label>
                    <span class="field-value"><?= formatValue($family['mother_educational_attainment'] ?? '') ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field full-width">
                    <label>Occupation:</label>
                    <span class="field-value"><?= formatValue($family['mother_occupation'] ?? '') ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field full-width">
                    <label>Parents' Permanent Address:</label>
                    <span class="field-value"><?= formatValue($family['parents_permanent_address'] ?? '') ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field" style="flex: 2;">
                    <label>Husband/Wife (If Married):</label>
                    <span class="field-value"><?= formatValue($family['spouse'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Contact No: <span style="font-size: 7px;">********</span></label>
                    <span class="field-value"><?= formatValue($family['spouse_contact_number'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Educational Attainment: <span style="font-size: 7px;">********</span></label>
                    <span class="field-value"><?= formatValue($family['spouse_educational_attainment'] ?? '') ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field full-width">
                    <label>Occupation:</label>
                    <span class="field-value"><?= formatValue($family['spouse_occupation'] ?? '') ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field" style="flex: 2;">
                    <label>Name of Guardian (if applicable):</label>
                    <span class="field-value"><?= formatValue($family['guardian_name'] ?? '') ?></span>
                </div>
                <div class="form-field" style="max-width: 60px;">
                    <label>Age:</label>
                    <span class="field-value"><?= formatValue($family['guardian_age'] ?? '') ?></span>
                </div>
                <div class="form-field">
                    <label>Contact No:</label>
                    <span class="field-value"><?= formatValue($family['guardian_contact_number'] ?? '') ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field full-width">
                    <label>Occupation:</label>
                    <span class="field-value"><?= formatValue($family['guardian_occupation'] ?? '') ?></span>
                </div>
            </div>
        </div>
        
        <!-- Footer -->
        <div class="page-footer">
            <div class="footer-content-wrapper">
                <div class="footer-text">
                    <p class="continue-note">Pls. continue on the back page →</p>
                    <p class="footer-address">C.M. Recto Avenue, Lapasan, Cagayan De Oro City 9000 Philippines</p>
                    <p class="footer-contact">Tel Nos. +63 (88) 856 1738; Telefax +63 (88) 856 4696 | http://www.ustp.edu.ph</p>
                </div>
                <div class="footer-stamp">
                    <img src="<?= base_url('Misc/PDS/SOCOTECH_stamp.jpg') ?>" alt="SOCOTEC Stamp" class="socotech-stamp-image">
                </div>
            </div>
        </div>
    </div>
    
    <!-- Page 2 -->
    <div class="pds-page page-2">
        <!-- Document Code Table (Top Right) -->
        <div class="document-stamp">
            <table class="stamp-table">
                <tr>
                    <td colspan="3" class="stamp-header">Document Code No.</td>
                </tr>
                <tr>
                    <td colspan="3" class="stamp-code">FM-USTP-GCS-02</td>
                </tr>
                <tr>
                    <td class="stamp-label">Rev. No.</td>
                    <td class="stamp-label">Effective Date</td>
                    <td class="stamp-label">Page No.</td>
                </tr>
                <tr>
                    <td class="stamp-value">00</td>
                    <td class="stamp-value">03.17.25</td>
                    <td class="stamp-value">2 of 2</td>
                </tr>
            </table>
        </div>
        
        <!-- University Header (Page 2) -->
        <div class="university-header">
            <div class="ustp-logo-container">
                <img src="<?= base_url('Photos/USTP.png') ?>" alt="USTP Logo" class="ustp-logo-image">
            </div>
            <div class="university-name">UNIVERSITY OF SCIENCE AND TECHNOLOGY OF SOUTHERN PHILIPPINES</div>
            <div class="campuses">Alubijid | Balubal | Cagayan de Oro | Claveria | Jasaan | Oroquieta | Panaon | Villanueva</div>
            <div class="department-name">GUIDANCE AND COUNSELING SERVICES</div>
        </div>
        
        <!-- Other Information Section -->
        <div class="section other-information">
            <h3 class="section-title">OTHER INFORMATION</h3>
            
            <div class="form-row">
                <div class="form-field full-width">
                    <label>1. Why did you choose this course/program?</label>
                    <span class="field-value"><?= formatValue($other['course_choice_reason'] ?? '') ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field full-width">
                    <label>2. How would you describe your family? Please put a check (/) mark on the space provided.</label>
                    <div style="font-size: 7px; margin-top: 2px; margin-bottom: 2px;">
                        ___ a family with harmonious relationship among family members<br>
                        ___ a family having conflict with some family members<br>
                        ___ a family with separated parents<br>
                        ___ a family with parents working abroad<br>
                        ___ others, pls. specify_________________________
                    </div>
                    <span class="field-value"><?= $familyDesc ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field full-width">
                    <label>3. Where do you live right now? Please put a check (/) mark on the space provided.</label>
                    <div style="font-size: 7px; margin-top: 2px; margin-bottom: 2px;">
                        ___ at home &nbsp;&nbsp; ___ boarding house &nbsp;&nbsp; ___ relatives &nbsp;&nbsp; ___ friends &nbsp;&nbsp; ___ others, pls. specify_____________
                    </div>
                    <span class="field-value"><?= $residenceType ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field full-width">
                    <label>4. Describe your living condition. Please put a check (/) mark on the space provided.</label>
                    <div style="font-size: 7px; margin-top: 2px; margin-bottom: 2px;">
                        ___ good environment for learning &nbsp;&nbsp; ___ not-so-good environment for learning
                    </div>
                    <span class="field-value"><?= $livingCondition ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field full-width">
                    <label>5. Do you have any physical/health condition/s?</label>
                    <div style="font-size: 7px; margin-top: 2px; margin-bottom: 2px;">
                        ___ No &nbsp;&nbsp; ___ Yes, pls. specify_________________________________________________
                    </div>
                    <span class="field-value"><?= $healthCondition ?></span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-field full-width">
                    <label>6. Have you undergone intervention/treatment with a psychologist/psychiatrist?</label>
                    <div style="font-size: 7px; margin-top: 2px; margin-bottom: 2px;">
                        ___ No &nbsp;&nbsp; ___ Yes
                    </div>
                    <span class="field-value"><?= $psychTreatment ?></span>
                </div>
            </div>
        </div>
        
        <!-- GCS Activities Section -->
        <div class="section gcs-activities">
            <h3 class="section-title">CHECK THE SEMINARS/ACTIVITIES YOU WANT TO AVAIL FROM THE GUIDANCE SERVICES UNIT</h3>
            <div class="activities-list">
                <div class="activity-item">Adjustment (dealing with people, handling pressures, environment, class schedules, etc.)</div>
                <div class="activity-item">Building Self-Confidence</div>
                <div class="activity-item">Developing Communication Skills</div>
                <div class="activity-item">Study Habits</div>
                <div class="activity-item">Time Management</div>
                <div class="activity-item">Tutorial with Peers (Please specify the subject/s) __________________________________</div>
                <div class="activity-item">others, pls. specify_________________________________________________________</div>
            </div>
            <?php if (!empty($gcsActivitiesList)): ?>
                <div style="margin-top: 10px; font-size: 8px; font-weight: bold;">
                    <div style="text-decoration: underline; margin-bottom: 5px;">Selected Activities:</div>
                    <?php foreach ($gcsActivitiesList as $activity): ?>
                        <div style="margin-bottom: 3px;">• <?= esc($activity) ?></div>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </div>
        
        <!-- Awards Section -->
        <div class="section awards-section">
            <h3 class="section-title">AWARDS AND RECOGNITION</h3>
            <table class="awards-table">
                <thead>
                    <tr>
                        <th>AWARDS/RECOGNITION RECEIVED</th>
                        <th>NAME OF SCHOOL/ORGANIZATION</th>
                        <th>YEAR</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if (!empty($awards)): ?>
                        <?php foreach ($awards as $award): ?>
                            <tr>
                                <td><?= formatValue($award['award_name'] ?? '') ?></td>
                                <td><?= formatValue($award['school_organization'] ?? '') ?></td>
                                <td><?= formatValue($award['year_received'] ?? '') ?></td>
                            </tr>
                        <?php endforeach; ?>
                        <?php 
                        $emptyRows = max(0, 4 - count($awards));
                        for ($i = 0; $i < $emptyRows; $i++): 
                        ?>
                            <tr>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                        <?php endfor; ?>
                    <?php else: ?>
                        <?php for ($i = 0; $i < 4; $i++): ?>
                            <tr>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                            </tr>
                        <?php endfor; ?>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
        
        <!-- Certification -->
        <div class="certification-section">
            <p class="certification-text">I hereby certify that all entries on the form are true and correct. I also agree to allow GCS to use the information/data for research purposes.</p>
            <div class="signature-date-row">
                <div class="signature-field">
                    <label>SIGNATURE OVER PRINTED NAME</label>
                    <div class="signature-line"></div>
                </div>
                <div class="date-field">
                    <label>DATE</label>
                    <div class="date-line"></div>
                </div>
            </div>
        </div>
        
        <!-- Footer -->
        <div class="page-footer">
            <div class="footer-content-wrapper">
                <div class="footer-text">
                    <p class="footer-address">C.M. Recto Avenue, Lapasan, Cagayan De Oro City 9000 Philippines</p>
                    <p class="footer-contact">Tel Nos. +63 (88) 856 1738; Telefax +63 (88) 856 4696 | http://www.ustp.edu.ph</p>
                </div>
                <div class="footer-stamp">
                    <img src="<?= base_url('Misc/PDS/SOCOTECH_stamp.jpg') ?>" alt="SOCOTEC Stamp" class="socotech-stamp-image">
                </div>
            </div>
        </div>
    </div>
    
    <script>
        function downloadPDF() {
            // Hide print controls before printing
            const controls = document.querySelector('.print-controls');
            if (controls) controls.style.display = 'none';
            
            // Use browser's print to PDF functionality
            window.print();
            
            // Show controls again after print dialog
            setTimeout(() => {
                if (controls) controls.style.display = 'block';
            }, 100);
        }
    </script>
</body>
</html>