import 'package:easy_localization/easy_localization.dart';

class AppStrings {
  AppStrings._();

  // App
  static String get appName => 'app_name'.tr();
  static String appVersion(String version) =>
      'app_version'.tr(namedArgs: {'version': version});

  // Auth
  static String get email => 'email'.tr();
  static String get password => 'password'.tr();
  static String get login => 'login'.tr();
  static String get logout => 'logout'.tr();
  static String get emailHint => 'email_hint'.tr();
  static String get passwordHint => 'password_hint'.tr();
  static String get emailRequired => 'email_required'.tr();
  static String get passwordRequired => 'password_required'.tr();
  static String get invalidEmail => 'invalid_email'.tr();

  // Navigation
  static String get preTraining => 'pre_training'.tr();
  static String get postTraining => 'post_training'.tr();

  // Pre Training
  static String get preTrainingTitle => 'pre_training_title'.tr();
  static String get sleepQuality => 'sleep_quality'.tr();
  static String get hoursOfSleep => 'hours_of_sleep'.tr();
  static String get fatigueLevel => 'fatigue_level'.tr();
  static String get muscleSoreness => 'muscle_soreness'.tr();
  static String get mood => 'mood'.tr();
  static String get stressLevel => 'stress_level'.tr();
  static String get energyLevel => 'energy_level'.tr();
  static String get painOrInjury => 'pain_or_injury'.tr();
  static String get painLocation => 'pain_location'.tr();
  static String get painLocationHint => 'pain_location_hint'.tr();
  static String get readinessToTrain => 'readiness_to_train'.tr();

  // Post Training
  static String get postTrainingTitle => 'post_training_title'.tr();
  static String get rpe => 'rpe'.tr();
  static String get completedWorkout => 'completed_workout'.tr();
  static String get feltPain => 'felt_pain'.tr();
  static String get injuryOccurred => 'injury_occurred'.tr();
  static String get currentFatigue => 'current_fatigue'.tr();
  static String get notes => 'notes'.tr();
  static String get notesHint => 'notes_hint'.tr();
  static String get trainingDuration => 'training_duration'.tr();
  static String get trainingDurationHint => 'training_duration_hint'.tr();
  static String get trainingLoad => 'training_load'.tr();

  // Common
  static String get yes => 'yes'.tr();
  static String get no => 'no'.tr();
  static String get submit => 'submit'.tr();
  static String get cancel => 'cancel'.tr();
  static String get veryBad => 'very_bad'.tr();
  static String get excellent => 'excellent'.tr();
  static String get low => 'low'.tr();
  static String get high => 'high'.tr();
  static String get submitSuccess => 'submit_success'.tr();
  static String get submitError => 'submit_error'.tr();

  // Register
  static String get register => 'register'.tr();
  static String get createAccount => 'create_account'.tr();
  static String get fullName => 'full_name'.tr();
  static String get fullNameHint => 'full_name_hint'.tr();
  static String get fullNameRequired => 'full_name_required'.tr();
  static String get phoneNumber => 'phone_number'.tr();
  static String get phoneHint => 'phone_hint'.tr();
  static String get phoneRequired => 'phone_required'.tr();
  static String get passwordTooShort => 'password_too_short'.tr();
  static String get tapToSelectImage => 'tap_to_select_image'.tr();
  static String get alreadyHaveAccount => 'already_have_account'.tr();
  static String get dontHaveAccount => 'dont_have_account'.tr();
  static String get signIn => 'sign_in'.tr();

  // Settings
  static String get settings => 'settings'.tr();
  static String get editProfile => 'edit_profile'.tr();
  static String get updateProfile => 'update_profile'.tr();
  static String get saveChanges => 'save_changes'.tr();
  static String get profileUpdated => 'profile_updated'.tr();
  static String get language => 'language'.tr();
  static String get changeLanguage => 'change_language'.tr();
  static String get english => 'english'.tr();
  static String get arabic => 'arabic'.tr();

  // Image picker
  static String get selectPhotoSource => 'select_photo_source'.tr();
  static String get fromGallery => 'from_gallery'.tr();
  static String get fromCamera => 'from_camera'.tr();

  // Account status screens
  static String get pendingTitle => 'pending_title'.tr();
  static String get pendingSubtitle => 'pending_subtitle'.tr();
  static String get pendingNote => 'pending_note'.tr();
  static String get rejectedTitle => 'rejected_title'.tr();
  static String get rejectedSubtitle => 'rejected_subtitle'.tr();
  static String get disabledTitle => 'disabled_title'.tr();
  static String get disabledSubtitle => 'disabled_subtitle'.tr();

  // Admin
  static String get adminDashboard => 'admin_dashboard'.tr();
  static String get requests => 'requests'.tr();
  static String get allUsers => 'all_users'.tr();
  static String get approve => 'approve'.tr();
  static String get reject => 'reject'.tr();
  static String get enable => 'enable'.tr();
  static String get disable => 'disable'.tr();
  static String get search => 'search'.tr();
  static String get noRequests => 'no_requests'.tr();
  static String get noUsers => 'no_users'.tr();
  static String get userDetails => 'user_details'.tr();
  static String get submissionHistory => 'submission_history'.tr();
  static String get analytics => 'analytics'.tr();
  static String get totalSubmissions => 'total_submissions'.tr();
  static String get preTrainingSessions => 'pre_training_sessions'.tr();
  static String get postTrainingSessions => 'post_training_sessions'.tr();
  static String get avgReadiness => 'avg_readiness'.tr();
  static String get avgRpe => 'avg_rpe'.tr();
  static String get lastActivity => 'last_activity'.tr();
  static String get noHistory => 'no_history'.tr();
  static String get submittedToday => 'submitted_today'.tr();
  static String get editSession => 'edit_session'.tr();
  static String get deleteSession => 'delete_session'.tr();
  static String get deleteSessionConfirm => 'delete_session_confirm'.tr();
  static String get editPreTrainingSession =>
      'edit_pre_training_session'.tr();
  static String get editPostTrainingSession =>
      'edit_post_training_session'.tr();
  static String get deleteUserData => 'delete_user_data'.tr();
  static String deleteUserDataConfirm(String name) =>
      'delete_user_data_confirm'.tr(namedArgs: {'name': name});
  static String get approveConfirm => 'approve_confirm'.tr();
  static String get rejectConfirm => 'reject_confirm'.tr();
  static String get disableConfirm => 'disable_confirm'.tr();
  static String get enableConfirm => 'enable_confirm'.tr();
  static String get confirmAction => 'confirm_action'.tr();
  static String get confirm => 'confirm'.tr();
  static String get rejectionReason => 'rejection_reason'.tr();
  static String get rejectionReasonHint => 'rejection_reason_hint'.tr();
  static String get userApproved => 'user_approved'.tr();
  static String get userRejected => 'user_rejected'.tr();
  static String get userEnabled => 'user_enabled'.tr();
  static String get userDisabled => 'user_disabled'.tr();

  // Status labels
  static String get statusPending => 'status_pending'.tr();
  static String get statusApproved => 'status_approved'.tr();
  static String get statusRejected => 'status_rejected'.tr();
  static String get statusDisabled => 'status_disabled'.tr();

  // Dialogs / common
  static String get signOutConfirm => 'sign_out_confirm'.tr();

  // Home screen
  static String get welcomeBack => 'welcome_back'.tr();
  static String get todaysCheckIn => 'todays_check_in'.tr();
  static String get trackTraining => 'track_training'.tr();
  static String get preTrainingSubtitle => 'pre_training_subtitle'.tr();
  static String get postTrainingSubtitle => 'post_training_subtitle'.tr();

  // Admin screen
  static String get adminPanel => 'admin_panel'.tr();
  static String get administrator => 'administrator'.tr();
  static String get usersTab => 'users_tab'.tr();
  static String get statsTab => 'stats_tab'.tr();
  static String approveUser(String name) =>
      'approve_user'.tr(namedArgs: {'name': name});
  static String get filterAll => 'filter_all'.tr();
  static String get userOverview => 'user_overview'.tr();
  static String get total => 'total'.tr();
  static String get active => 'active'.tr();
  static String get rejectedDisabled => 'rejected_disabled'.tr();
  static String get readinessOverview => 'readiness_overview'.tr();
  static String get scoreDistribution => 'score_distribution'.tr();
  static String get ready => 'ready'.tr();
  static String get notReady => 'not_ready'.tr();
  static String get noData => 'no_data'.tr();
  static String get avgScore => 'avg_score'.tr();
  static String get userNotFound => 'user_not_found'.tr();
  static String get lastActive => 'last_active'.tr();
  static String get totalInjuries => 'total_injuries'.tr();
  static String get readyToTrain => 'ready_to_train'.tr();
  static String get notReadyToTrain => 'not_ready_to_train'.tr();
  static String get previousInjuries => 'previous_injuries'.tr();
  static String get previousInjuriesHint => 'previous_injuries_hint'.tr();

  // Session field labels
  static String get sleep => 'sleep'.tr();
  static String get fatigue => 'fatigue'.tr();
  static String get muscleSorenessShort => 'muscle_soreness_short'.tr();
  static String get painInjury => 'pain_injury'.tr();
  static String get readiness => 'readiness'.tr();
  static String get energy => 'energy'.tr();
  static String get stress => 'stress'.tr();
  static String get completedWorkoutShort => 'completed_workout_short'.tr();
  static String get pain => 'pain'.tr();
  static String get injury => 'injury'.tr();
  static String get reported => 'reported'.tr();

  // Slider labels
  static String get veryEasy => 'very_easy'.tr();
  static String get maxEffort => 'max_effort'.tr();
  static String get zeroHrs => 'zero_hrs'.tr();
  static String get twelveHrs => 'twelve_hrs'.tr();

  // Profile / settings
  static String get personalInformation => 'personal_information'.tr();
  static String get updatePersonalInfo => 'update_personal_info'.tr();
  static String get noChanges => 'no_changes'.tr();
  static String get signInToContinue => 'sign_in_to_continue'.tr();

  // Register — profile fields
  static String get age => 'age'.tr();
  static String get ageHint => 'age_hint'.tr();
  static String get ageRequired => 'age_required'.tr();
  static String get invalidAge => 'invalid_age'.tr();
  static String get weightKg => 'weight_kg'.tr();
  static String get weightHint => 'weight_hint'.tr();
  static String get weightRequired => 'weight_required'.tr();
  static String get invalidWeight => 'invalid_weight'.tr();
  static String get heightCm => 'height_cm'.tr();
  static String get heightHint => 'height_hint'.tr();
  static String get heightRequired => 'height_required'.tr();
  static String get invalidHeight => 'invalid_height'.tr();
  static String get gender => 'gender'.tr();
  static String get genderRequired => 'gender_required'.tr();
  static String get male => 'male'.tr();
  static String get female => 'female'.tr();
  static String get otherGender => 'other_gender'.tr();

  // Multi-step register
  static String get next => 'next'.tr();
  static String get back => 'back'.tr();
  static String get stepGeneral => 'step_general'.tr();
  static String get stepMedical => 'step_medical'.tr();
  static String get step1Title => 'step_1_title'.tr();
  static String get step2Title => 'step_2_title'.tr();

  // Medical step — sections
  static String get medicalPrevMuscle => 'medical_prev_muscle'.tr();
  static String get medicalPrevJoint => 'medical_prev_joint'.tr();
  static String get medicalSurgeryHist => 'medical_surgery_hist'.tr();
  static String get medicalCurrentStatus => 'medical_current_status'.tr();
  static String get medicalQMuscle => 'medical_q_muscle'.tr();
  static String get medicalQJoint => 'medical_q_joint'.tr();
  static String get medicalQSurgery => 'medical_q_surgery'.tr();

  // Medical step — fields
  static String get medicalSide => 'medical_side'.tr();
  static String get medicalGrade => 'medical_grade'.tr();
  static String get medicalDateInjury => 'medical_date_injury'.tr();
  static String get medicalDaysLost => 'medical_days_lost'.tr();
  static String get medicalReinjury => 'medical_reinjury'.tr();
  static String get medicalSurgeryReq => 'medical_surgery_req'.tr();
  static String get medicalSurgeryName => 'medical_surgery_name'.tr();
  static String get medicalBodyArea => 'medical_body_area'.tr();
  static String get medicalSurgeryDate => 'medical_surgery_date'.tr();
  static String get medicalSurgeon => 'medical_surgeon'.tr();
  static String get medicalRtp => 'medical_rtp'.tr();
  static String get medicalStatusField => 'medical_status_field'.tr();
  static String get medicalAddSurgery => 'medical_add_surgery'.tr();
  static String medicalSurgeryN(int n) =>
      'medical_surgery_n'.tr(namedArgs: {'n': '$n'});

  // Medical step — current status toggles
  static String get medicalCurrentPain => 'medical_current_pain'.tr();
  static String get medicalChronicInjury => 'medical_chronic_injury'.tr();
  static String get medicalMedications => 'medical_medications'.tr();
  static String get medicalAllergies => 'medical_allergies'.tr();
  static String get medicalSupportiveEq => 'medical_supportive_eq'.tr();

  // Muscle groups (display, data key stays English)
  static String get mgHamstring => 'mg_hamstring'.tr();
  static String get mgQuadriceps => 'mg_quadriceps'.tr();
  static String get mgAdductor => 'mg_adductor'.tr();
  static String get mgCalf => 'mg_calf'.tr();
  static String get mgHipFlexor => 'mg_hip_flexor'.tr();
  static String get mgGlute => 'mg_glute'.tr();
  static String get mgLowerBack => 'mg_lower_back'.tr();

  // Joint types (display)
  static String get jtAcl => 'jt_acl'.tr();
  static String get jtPcl => 'jt_pcl'.tr();
  static String get jtMcl => 'jt_mcl'.tr();
  static String get jtLcl => 'jt_lcl'.tr();
  static String get jtMeniscus => 'jt_meniscus'.tr();
  static String get jtAnkleSprain => 'jt_ankle_sprain'.tr();
  static String get jtShoulder => 'jt_shoulder'.tr();
  static String get jtOther => 'jt_other'.tr();

  // Sides
  static String get sideRight => 'side_right'.tr();
  static String get sideLeft => 'side_left'.tr();
  static String get sideBoth => 'side_both'.tr();

  // Grades
  static String get grade1 => 'grade_1'.tr();
  static String get grade2 => 'grade_2'.tr();
  static String get grade3 => 'grade_3'.tr();

  // Surgery statuses
  static String get statusFullyRecovered => 'status_fully_recovered'.tr();
  static String get statusOngoingRehab => 'status_ongoing_rehab'.tr();
  static String get statusLimited => 'status_limited'.tr();
  static String get statusUnknown => 'status_unknown'.tr();

  // Medical History tab (admin)
  static String get medicalHistory => 'medical_history'.tr();
  static String get riskProfile => 'risk_profile'.tr();
  static String get riskLow => 'risk_low'.tr();
  static String get riskModerate => 'risk_moderate'.tr();
  static String get riskHigh => 'risk_high'.tr();
  static String get noMedicalHistory => 'no_medical_history'.tr();
  static String get noneReported => 'none_reported'.tr();

  // Workload Monitoring
  static String get workloadMonitoring => 'workload_monitoring'.tr();
  static String get acuteLoad => 'acute_load'.tr();
  static String get chronicLoad => 'chronic_load'.tr();
  static String get acwr => 'acwr'.tr();
  static String get workloadStatus => 'workload_status'.tr();
  static String get dailyLoadChart => 'daily_load_chart'.tr();
  static String get acuteVsChronic => 'acute_vs_chronic'.tr();
  static String get acwrHistory => 'acwr_history'.tr();
  static String get workloadSummary => 'workload_summary'.tr();
  static String get peakAcute => 'peak_acute'.tr();
  static String get peakChronic => 'peak_chronic'.tr();
  static String get peakAcwr => 'peak_acwr'.tr();
  static String get avgDailyLoad => 'avg_daily_load'.tr();
  static String get noWorkloadData => 'no_workload_data'.tr();
  static String get noWorkloadSubtitle => 'no_workload_subtitle'.tr();
  static String get safeZone => 'safe_zone'.tr();
  static String get last28Days => 'last_28_days'.tr();
  static String get arbitraryUnits => 'arbitrary_units'.tr();
  static String get previousMonth => 'previous_month'.tr();
  static String get nextMonth => 'next_month'.tr();
  static String weekLabel(int number) =>
      'week_label'.tr(namedArgs: {'number': '$number'});
  static String get acwrStatusVeryLow => 'acwr_status_very_low'.tr();
  static String get acwrStatusOptimal => 'acwr_status_optimal'.tr();
  static String get acwrStatusElevated => 'acwr_status_elevated'.tr();
  static String get acwrStatusHighRisk => 'acwr_status_high_risk'.tr();
  static String get acwrDescVeryLow => 'acwr_desc_very_low'.tr();
  static String get acwrDescOptimal => 'acwr_desc_optimal'.tr();
  static String get acwrDescElevated => 'acwr_desc_elevated'.tr();
  static String get acwrDescHighRisk => 'acwr_desc_high_risk'.tr();
  static String get workloadCollectingShort =>
      'workload_collecting_short'.tr();
  static String get workloadCollectingLong => 'workload_collecting_long'.tr();
  static String get workloadPendingAcuteMessage =>
      'workload_pending_acute_message'.tr();
  static String get workloadPendingChronicMessage =>
      'workload_pending_chronic_message'.tr();
  static String get workloadNeeds7Days => 'workload_needs_7_days'.tr();
  static String get workloadNeeds4Weeks => 'workload_needs_4_weeks'.tr();
  static String get acuteLegend => 'acute_legend'.tr();
  static String get chronicLegend => 'chronic_legend'.tr();
  static String workloadMaxLabel(String value, String unit) =>
      'workload_max_label'.tr(namedArgs: {'value': value, 'unit': unit});

  // Stats with params
  static String thresholdLabel(int value) =>
      'threshold_label'.tr(namedArgs: {'value': '$value'});
  static String percentReady(int percent) =>
      'percent_ready'.tr(namedArgs: {'percent': '$percent'});
  static String sleepQualityDisplay(int quality) =>
      'sleep_quality_display'.tr(namedArgs: {'quality': '$quality'});
}
