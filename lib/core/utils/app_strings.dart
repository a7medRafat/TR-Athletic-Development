class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'TR Athletic Development';

  // Auth
  static const String email = 'Email';
  static const String password = 'Password';
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String emailHint = 'Enter your email';
  static const String passwordHint = 'Enter your password';
  static const String emailRequired = 'Email is required';
  static const String passwordRequired = 'Password is required';
  static const String invalidEmail = 'Please enter a valid email';

  // Navigation
  static const String preTraining = 'Pre Training';
  static const String postTraining = 'Post Training';

  // Pre Training
  static const String preTrainingTitle = 'Pre-Training Check-In';
  static const String sleepQuality = 'Sleep Quality';
  static const String hoursOfSleep = 'Hours of Sleep';
  static const String fatigueLevel = 'Fatigue Level';
  static const String muscleSoreness = 'Muscle Soreness (DOMS)';
  static const String mood = 'Mood';
  static const String stressLevel = 'Stress Level';
  static const String energyLevel = 'Energy Level';
  static const String painOrInjury = 'Do you have pain or injury?';
  static const String painLocation = 'Pain Location';
  static const String painLocationHint = 'Describe the pain location';
  static const String readinessToTrain = 'Are you ready to train today?';

  // Post Training
  static const String postTrainingTitle = 'Post-Training Check-In';
  static const String rpe = 'RPE (Rate of Perceived Exertion)';
  static const String completedWorkout = 'Did you complete the workout?';
  static const String feltPain = 'Did you feel pain?';
  static const String injuryOccurred = 'Did injury happen?';
  static const String currentFatigue = 'Current Fatigue';
  static const String notes = 'Notes';
  static const String notesHint = 'Any additional notes (optional)';

  // Common
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String submit = 'Submit';
  static const String veryBad = 'Very Bad';
  static const String excellent = 'Excellent';
  static const String low = 'Low';
  static const String high = 'High';
  static const String submitSuccess = 'Submitted successfully!';
  static const String submitError = 'Failed to submit. Please try again.';

  // Register
  static const String register = 'Register';
  static const String createAccount = 'Create an account';
  static const String fullName = 'Full Name';
  static const String fullNameHint = 'Enter your full name';
  static const String fullNameRequired = 'Full name is required';
  static const String phoneNumber = 'Phone Number';
  static const String phoneHint = 'Enter your phone number';
  static const String phoneRequired = 'Phone number is required';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String tapToSelectImage = 'Tap to add a profile photo';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String signIn = 'Sign In';

  // Settings
  static const String settings = 'Settings';
  static const String editProfile = 'Edit Profile';
  static const String updateProfile = 'Update Profile';
  static const String saveChanges = 'Save Changes';
  static const String profileUpdated = 'Profile updated successfully!';

  // Image picker
  static const String selectPhotoSource = 'Select Photo';
  static const String fromGallery = 'Photo Library';
  static const String fromCamera = 'Camera';

  // Account status screens
  static const String pendingTitle = 'Waiting for Approval';
  static const String pendingSubtitle =
      'Your account is under review. An administrator will approve your access shortly.';
  static const String pendingNote =
      'You will be automatically redirected once your account is approved.';
  static const String rejectedTitle = 'Account Not Approved';
  static const String rejectedSubtitle =
      'Your account registration was not approved at this time.';
  static const String disabledTitle = 'Account Disabled';
  static const String disabledSubtitle =
      'Your account has been temporarily disabled. Please contact your administrator.';

  // Admin
  static const String adminDashboard = 'Admin Dashboard';
  static const String requests = 'Requests';
  static const String allUsers = 'All Users';
  static const String approve = 'Approve';
  static const String reject = 'Reject';
  static const String enable = 'Enable';
  static const String disable = 'Disable';
  static const String search = 'Search users...';
  static const String noRequests = 'No pending requests';
  static const String noUsers = 'No users found';
  static const String userDetails = 'User Details';
  static const String submissionHistory = 'Submission History';
  static const String analytics = 'Analytics';
  static const String totalSubmissions = 'Total Submissions';
  static const String preTrainingSessions = 'Pre-Training';
  static const String postTrainingSessions = 'Post-Training';
  static const String avgReadiness = 'Avg Readiness';
  static const String avgRpe = 'Avg RPE';
  static const String lastActivity = 'Last Activity';
  static const String noHistory = 'No submissions yet';
  static const String approveConfirm = 'Approve this user?';
  static const String rejectConfirm = 'Reject this user?';
  static const String disableConfirm = 'Disable this user?';
  static const String enableConfirm = 'Enable this user?';
  static const String confirmAction = 'Confirm';
  static const String rejectionReason = 'Rejection reason (optional)';
  static const String rejectionReasonHint = 'Enter reason...';
  static const String userApproved = 'User approved successfully';
  static const String userRejected = 'User rejected';
  static const String userEnabled = 'User account enabled';
  static const String userDisabled = 'User account disabled';

  // Status labels
  static const String statusPending = 'Pending';
  static const String statusApproved = 'Approved';
  static const String statusRejected = 'Rejected';
  static const String statusDisabled = 'Disabled';
}
