// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GymCoach';

  @override
  String get navHome => 'Home';

  @override
  String get navPlans => 'Plans';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navFeed => 'Feed';

  @override
  String get navMap => 'Map';

  @override
  String get navProgress => 'Progress';

  @override
  String get navProfile => 'Profile';

  @override
  String get navLeaderboard => 'Leaderboard';

  @override
  String get leaderboardSubtitle =>
      'Ranked by total captured territory on the map';

  @override
  String get leaderboardYou => 'You';

  @override
  String get closeTooltip => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String scheduleToday(String time) {
    return 'Today · $time';
  }

  @override
  String scheduleTomorrow(String time) {
    return 'Tomorrow · $time';
  }

  @override
  String scheduleDateTime(String date, String time) {
    return '$date · $time';
  }

  @override
  String get activityYesterday => 'Yesterday';

  @override
  String activityDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get activityToday => 'Today';

  @override
  String get homeWelcomeBack => 'Welcome back';

  @override
  String get homeStayConsistent => 'Stay consistent and keep moving.';

  @override
  String get homeTodaysFocus => 'Today\'s Focus';

  @override
  String get homeTrainingFocus => 'Training Focus';

  @override
  String get homeSchedulePlanPrompt => 'Schedule a plan to stay consistent.';

  @override
  String get homeOneWorkoutToday => '1 workout planned for today';

  @override
  String homeNWorkoutsToday(int count) {
    return '$count workouts planned for today';
  }

  @override
  String get homeMetricPlanned => 'Planned workouts';

  @override
  String get homeMetricCompleted => 'Completed workouts';

  @override
  String get homeMetricThisWeek => 'This week';

  @override
  String get homeNextWorkout => 'Next Workout';

  @override
  String get homeNoneScheduled => 'None scheduled';

  @override
  String get homeAddWorkoutPlan => 'Add a workout plan';

  @override
  String get homeNextWorkoutEmptyHint =>
      'Create a plan to see your next session here.';

  @override
  String get homeOpenDetails => 'Open Details';

  @override
  String get homeViewPlans => 'View Plans';

  @override
  String get homeQuickActions => 'Quick Actions';

  @override
  String get homeWeeklyActivity => 'Weekly Activity';

  @override
  String get homeExerciseCategories => 'Exercise Categories';

  @override
  String get homeRecentActivity => 'Recent Activity';

  @override
  String get homeRecentEmpty =>
      'No recent sessions yet. Finish a workout to see it here.';

  @override
  String get homeStartWorkout => 'Start Workout';

  @override
  String get homeViewPlanLink => 'View Plan';

  @override
  String get homeStreakTitle => 'Keep your streak alive';

  @override
  String get homeStreakSubtitle =>
      'Complete one workout today to stay on track.';

  @override
  String get homeQuickCreatePlan => 'Create Plan';

  @override
  String get homeQuickLogWorkout => 'Log Workout';

  @override
  String get homeQuickStatistics => 'View Statistics';

  @override
  String get homeNoWorkoutToday => 'No workout planned for today.';

  @override
  String get homeScreenTitle => 'Workouts';

  @override
  String get homeTabDashboard => 'Dashboard';

  @override
  String get homeTabWorkouts => 'Workouts';

  @override
  String get homeTabDiet => 'Diet';

  @override
  String get homeBannerCreateHint => 'See how to create new workouts';

  @override
  String get homeBannerStartHint => 'Start by adding a new training day';

  @override
  String get homeMyTraining => 'My Training';

  @override
  String homeCompletedSessions(int count) {
    return '$count sessions completed';
  }

  @override
  String get homeTrainingSchedule => 'Training Schedule';

  @override
  String get homeMore => 'More';

  @override
  String get homeNoWorkoutsOnDate => 'No workouts scheduled for this date';

  @override
  String get homeFeaturedEmptyTitle => 'No training plan yet';

  @override
  String get homeFeaturedEmptySubtitle =>
      'Create your first workout to get started';

  @override
  String get plansPageTitle => 'Workout Plans';

  @override
  String get plansPageSubtitle => 'Plan your training and stay consistent.';

  @override
  String get plansCreate => 'Create Plan';

  @override
  String get plansSectionYourPlans => 'Your plans';

  @override
  String plansTotalCount(int count) {
    return '$count total';
  }

  @override
  String get plansEmptyTitle => 'No workout plans yet';

  @override
  String get plansEmptyBody =>
      'Create your first plan and start building consistency.';

  @override
  String get plansSnackbarCreated => 'Workout plan created';

  @override
  String get plansSnackbarOnlyPlanned =>
      'Only planned workouts can start a live session.';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String minutesPlanShort(int count) {
    return '$count min plan';
  }

  @override
  String durationMinutesLabel(int count) {
    return '$count minutes';
  }

  @override
  String get homeAddWorkout => 'Add workout';

  @override
  String get workoutListEmptyTitle => 'Your workout list is empty';

  @override
  String get workoutListEmptyBody =>
      'Start by adding exercises to a new training day.';

  @override
  String get workoutAddTrainingDay => 'Add training day';

  @override
  String get workoutChooseMuscleGroup => 'Choose muscle group';

  @override
  String get workoutChooseExercises => 'Choose exercises';

  @override
  String get workoutNameYourWorkout => 'Name your workout';

  @override
  String get workoutScheduleTitle => 'Schedule workout';

  @override
  String get workoutScheduleHint =>
      'Choose date, time, and duration for this workout.';

  @override
  String get workoutMuscleGroupHint =>
      'Select one or more areas you want to train.';

  @override
  String get workoutContinue => 'Continue';

  @override
  String workoutContinueGroups(int count) {
    return 'Continue ($count groups)';
  }

  @override
  String get workoutSelectExercises => 'Select exercises';

  @override
  String workoutContinueExercises(int count) {
    return 'Continue ($count)';
  }

  @override
  String get workoutSaveWorkout => 'Save workout';

  @override
  String workoutExerciseHintSingle(String category) {
    return 'Choose $category exercises. Tap a row to select and read the details.';
  }

  @override
  String get workoutExerciseHintMulti =>
      'Choose exercises from your selected muscle groups.';

  @override
  String get workoutNameHint => 'e.g. Upper Body Power';

  @override
  String get workoutSelected => 'Selected';

  @override
  String get workoutBack => 'Back';

  @override
  String get planRepeatWorkout => 'Repeat workout';

  @override
  String get planCustomizeRepeat => 'Customize and schedule';

  @override
  String get planCompletedHint =>
      'This workout is finished. Repeat it on another day or adjust exercises first.';

  @override
  String exercisesCount(int count) {
    return '$count exercises';
  }

  @override
  String get difficultyBeginner => 'Beginner';

  @override
  String get difficultyIntermediate => 'Intermediate';

  @override
  String get difficultyAdvanced => 'Advanced';

  @override
  String get statusPlanned => 'Planned';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusMissed => 'Missed';

  @override
  String get planCardDetails => 'Details';

  @override
  String get planCardStart => 'Start';

  @override
  String get planDetailTitle => 'Plan Details';

  @override
  String get planDetailSchedule => 'Schedule';

  @override
  String get planDetailExercises => 'Exercises';

  @override
  String get labelDate => 'Date';

  @override
  String get labelTime => 'Time';

  @override
  String get labelDuration => 'Duration';

  @override
  String get beginSession => 'Begin Session';

  @override
  String get editPlan => 'Edit Plan';

  @override
  String get planSessionOnlyPlanned =>
      'Only planned workouts can begin a new session.';

  @override
  String get deletePlanTitle => 'Delete plan';

  @override
  String deletePlanConfirm(String name) {
    return 'Delete \"$name\" permanently?';
  }

  @override
  String get createPlanTitle => 'Create Plan';

  @override
  String get editPlanSheetTitle => 'Edit Plan';

  @override
  String get savePlan => 'Save Plan';

  @override
  String get updatePlan => 'Update Plan';

  @override
  String get workoutNameLabel => 'Workout name';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get durationLabel => 'Duration';

  @override
  String get difficultyLabel => 'Difficulty';

  @override
  String get exercisesLabel => 'Exercises';

  @override
  String exercisesSelected(int count) {
    return '$count selected';
  }

  @override
  String get validationWorkoutName => 'Please enter a workout name.';

  @override
  String get validationPickExercise => 'Select at least one exercise.';

  @override
  String chipMinutes(int count) {
    return '$count min';
  }

  @override
  String get calendarTitle => 'Calendar';

  @override
  String calendarWorkoutsOn(String date) {
    return 'Workouts on $date';
  }

  @override
  String get calendarEmptyDay =>
      'No workouts on this day. Add a session to stay on schedule.';

  @override
  String get progressTitle => 'Progress';

  @override
  String get progressSubtitle => 'Performance overview and history';

  @override
  String get progressWeeklySessions => 'Weekly sessions';

  @override
  String get progressActiveStreak => 'Active streak';

  @override
  String progressStreakDays(int count) {
    return '$count days';
  }

  @override
  String get progressMonthlyConsistency => 'Monthly consistency';

  @override
  String get progressMonthlyHint =>
      'Completed sessions vs plans scheduled this month';

  @override
  String get progressWeeklyVolume => 'Weekly volume';

  @override
  String get progressTotalSessions => 'Total sessions';

  @override
  String get progressWeeklyMinutes => 'Training time this week';

  @override
  String get progressWeeklyCalories => 'Calories this week';

  @override
  String get progressWeekActivity => 'Calories by day';

  @override
  String get progressWeekActivityHint => 'Calories burned each day this week';

  @override
  String get progressMonthSessions => 'Sessions this month';

  @override
  String get progressPlannedUpcoming => 'Upcoming workouts';

  @override
  String get progressAchievements => 'Achievements';

  @override
  String get progressSessionHighlights => 'Session highlights';

  @override
  String get progressHighlightLongest => 'Longest session';

  @override
  String get progressHighlightCalories => 'Peak calories';

  @override
  String get progressHighlightMoves => 'Most exercises';

  @override
  String get progressHighlightsEmpty =>
      'Log workouts to see your best sessions here.';

  @override
  String get progressWorkoutHistory => 'Workout history';

  @override
  String get progressHistoryEmpty =>
      'No completed sessions yet. Finish a workout to see it here.';

  @override
  String get streakDetailsTitle => 'Streak details';

  @override
  String streakDayStreak(int count) {
    return '$count day streak';
  }

  @override
  String get streakMomentum => 'Train today to keep momentum.';

  @override
  String get streakRecentDays => 'Recent training days';

  @override
  String get streakEmpty => 'Complete a workout to start your streak.';

  @override
  String get streakOpenProgress => 'Open Progress';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileTabPhotos => 'Photos';

  @override
  String get profileTabAbout => 'About';

  @override
  String get profileTabFeed => 'Feed';

  @override
  String get profileTabSaved => 'Saved';

  @override
  String get profileTabSettings => 'Settings';

  @override
  String get profileEditShort => 'Edit';

  @override
  String get profileClose => 'Close';

  @override
  String get profileNoBio => 'No public bio yet.';

  @override
  String get profileAboutEmpty =>
      'This user has not added information about themselves yet.';

  @override
  String get profilePhotosEmpty => 'This user has not added any photos yet.';

  @override
  String get profilePostsEmpty => 'This user has not shared any posts yet.';

  @override
  String get profileSavedEmpty =>
      'No saved posts yet. Tap bookmark on a feed post to save it here.';

  @override
  String get profilePrivateNotes => 'Private notes';

  @override
  String get profilePrivateNotesEmpty => 'Add private notes only you can see.';

  @override
  String get profileFitnessSummary => 'Fitness summary';

  @override
  String get profileWeight => 'Weight';

  @override
  String get profileHeight => 'Height';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileEditProfile => 'Edit profile';

  @override
  String get profileAppPreferences => 'App preferences';

  @override
  String get profileNotificationsSection => 'Notifications';

  @override
  String get profileRemindersTitle => 'Training reminders';

  @override
  String get profileRemindersSubtitle =>
      'Stay notified about upcoming sessions';

  @override
  String get profileLogOut => 'Log out';

  @override
  String get profileEditSheetTitle => 'Edit profile';

  @override
  String get profileAvatarButton => 'Avatar';

  @override
  String get profileCoverButton => 'Cover';

  @override
  String get profilePublicBioLabel => 'Public bio';

  @override
  String get profilePublicToggleTitle => 'Public profile';

  @override
  String get profilePublicToggleSubtitle => 'Visible in Feed and Leaderboard';

  @override
  String get labelName => 'Name';

  @override
  String get labelWeightKg => 'Weight (kg)';

  @override
  String get labelHeightCm => 'Height (cm)';

  @override
  String get labelFitnessGoal => 'Fitness goal';

  @override
  String get labelMembership => 'Membership';

  @override
  String get validationProfileName => 'Name is required.';

  @override
  String get validationProfileWeight =>
      'Enter a valid weight (use dot or comma as decimal separator).';

  @override
  String get validationProfileHeight =>
      'Enter a valid height (use dot or comma as decimal separator).';

  @override
  String get membershipFree => 'Free';

  @override
  String get membershipPlus => 'Plus';

  @override
  String get membershipPremium => 'Premium';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'App display language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languagePickerTitle => 'Choose language';

  @override
  String get profilePreferencesSnack =>
      'Preferences will connect to settings in a future release.';

  @override
  String get profileLogoutSnack =>
      'Logout will be available when accounts launch.';

  @override
  String get profileDefaultGoal => 'Strength and conditioning';

  @override
  String get onboardingTitle => 'Welcome to GymCoach';

  @override
  String get onboardingSubtitle =>
      'Enter your name, weight, and height so workouts and calorie estimates fit you.';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get sessionActiveTitle => 'Active Session';

  @override
  String get sessionStartTitle => 'Ready to train?';

  @override
  String get sessionStartBody =>
      'Start the session when you begin your workout. Duration and calories will be calculated from that moment.';

  @override
  String get sessionStartButton => 'Start session';

  @override
  String get sessionStartFirst => 'Start the session before logging exercises.';

  @override
  String get sessionTimerRunning => 'Timer running';

  @override
  String get sessionCurrentExercise => 'Current exercise';

  @override
  String get labelSets => 'Sets';

  @override
  String get labelReps => 'Reps';

  @override
  String get labelRest => 'Rest';

  @override
  String get sessionAllExercises => 'All exercises';

  @override
  String sessionExerciseOf(int current, int total) {
    return 'Exercise $current of $total';
  }

  @override
  String get sessionCompleteExercise => 'Complete exercise';

  @override
  String get sessionCompleteFinal => 'Complete final exercise';

  @override
  String get sessionNextExercise => 'Next exercise';

  @override
  String get sessionEndWorkout => 'End workout';

  @override
  String get sessionFinishWorkout => 'Finish workout';

  @override
  String get sessionFormTips => 'FORM TIPS';

  @override
  String get sessionBetweenSets => 'Between sets';

  @override
  String get sessionChipTarget => 'Target';

  @override
  String get sessionChipTempo => 'Tempo';

  @override
  String get sessionChipEquipment => 'Equipment';

  @override
  String get sessionSummaryTitle => 'Session summary';

  @override
  String get sessionSummaryDuration => 'Duration';

  @override
  String get sessionSummaryCalories => 'Calories';

  @override
  String sessionSummaryVolumeLine(int logKcal, int totalKcal) {
    return 'Exercise volume: $logKcal kcal · Session total: $totalKcal kcal';
  }

  @override
  String sessionDurationSecondsOnly(int count) {
    return '${count}s';
  }

  @override
  String sessionDurationMinutesOnly(int count) {
    return '$count min';
  }

  @override
  String sessionDurationMinutesSeconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String sessionCaloriesUnit(int count) {
    return '$count kcal';
  }

  @override
  String get sessionCaloriesEstimateNote =>
      'Calorie values are approximate only, not exact. They are estimated from your weight, height, each exercise, sets, reps, and session duration.';

  @override
  String get sessionValidationSetsReps =>
      'Enter a positive number of sets and reps to log this exercise.';

  @override
  String get sessionExerciseAlreadyLogged =>
      'This exercise is already logged. Select another from the list.';

  @override
  String get sessionCameraTrackingComingSoon => 'Camera tracking (coming soon)';

  @override
  String get sessionCameraTracking => 'Track with camera';

  @override
  String get cameraTrackingTitle => 'Camera tracking';

  @override
  String get cameraStartTracking => 'Start tracking';

  @override
  String get cameraApplyCount => 'Apply count';

  @override
  String get cameraRepCount => 'Reps';

  @override
  String get cameraHoldSeconds => 'Hold (sec)';

  @override
  String get cameraBodyNotVisible => 'Step into frame so your body is visible';

  @override
  String get cameraSafetyDisclaimer =>
      'This tool does not replace a qualified trainer. Stop if you feel pain.';

  @override
  String get cameraPermissionDenied =>
      'Camera permission is required for tracking.';

  @override
  String get cameraPlatformUnsupported =>
      'Camera tracking works on Android and iOS devices.';

  @override
  String get cameraManualFallback =>
      'You can count reps manually on the workout screen.';

  @override
  String get cameraUseManual => 'Use manual counting';

  @override
  String get cameraOpenSettings => 'Open settings';

  @override
  String get cameraRetry => 'Try again';

  @override
  String get cameraPreviewLoading => 'Starting camera…';

  @override
  String get cameraTrackingLive => 'Live';

  @override
  String get cameraInvalidAttempts => 'Adjust';

  @override
  String get cameraUnsupportedExercise =>
      'Camera tracking is not available for this exercise yet.';

  @override
  String get cameraInitFailed =>
      'Could not start the camera. Try again or use manual counting.';

  @override
  String get cameraFeedbackSaggingHips => 'Keep hips aligned — avoid sagging';

  @override
  String get cameraFeedbackRaiseHigher => 'Raise arms higher to shoulder level';

  @override
  String get cameraFeedbackIncompletePress =>
      'Full overhead extension required';

  @override
  String get cameraFeedbackPullHigher => 'Pull higher — chin above hands';

  @override
  String get cameraFeedbackHipsSagging => 'Lift hips — keep body straight';

  @override
  String get cameraFeedbackAdjustForm => 'Adjust form and try again';

  @override
  String cameraAppliedReps(int count) {
    return 'Applied $count reps from camera';
  }

  @override
  String cameraAppliedHold(int count) {
    return 'Applied ${count}s hold from camera';
  }

  @override
  String get sessionCompletedExercises => 'Completed exercises';

  @override
  String get sessionDone => 'Done';

  @override
  String get workoutTypePlannedSession => 'Planned session';

  @override
  String get logWorkoutTitle => 'Log workout';

  @override
  String get logWorkoutName => 'Workout name';

  @override
  String get logWorkoutType => 'Workout type';

  @override
  String get logWorkoutTypeDefault => 'Custom';

  @override
  String get logDuration => 'Duration';

  @override
  String get logSave => 'Save log';

  @override
  String get quickLogTitle => 'Log past workout';

  @override
  String get quickLogDate => 'Workout date';

  @override
  String get quickLogYesterday => 'Yesterday';

  @override
  String get quickLogDayBefore => '2 days ago';

  @override
  String get quickLogAddExercise => 'Add exercise';

  @override
  String get templateFromLabel => 'From template';

  @override
  String get templateSave => 'Save as template';

  @override
  String get templateSaved => 'Template saved';

  @override
  String get copyPlanTitle => 'Schedule on another day';

  @override
  String get copyPlanConfirm => 'Schedule';

  @override
  String get snackbarPlanCopied => 'Workout copied to calendar';

  @override
  String get sessionManageExercises => 'Manage exercises';

  @override
  String get sessionAddExercise => 'Add exercise';

  @override
  String get validationLogName => 'Enter a workout name.';

  @override
  String get historyWorkoutSummary => 'Workout summary';

  @override
  String get historyCompletedOn => 'Completed on';

  @override
  String get historyExercisesCompleted => 'Exercises completed';

  @override
  String historySetsRepsDetail(int sets, int reps) {
    return '$sets sets · $reps reps';
  }

  @override
  String get historyCaloriesEstimateNote =>
      'Calorie values are approximate only, not an exact measurement.';

  @override
  String get snackbarWorkoutSavedHistory => 'Workout saved to your history';

  @override
  String get snackbarPlanUpdated => 'Plan updated';

  @override
  String get snackbarPlanDeleted => 'Plan deleted';

  @override
  String get snackbarWorkoutLogged => 'Workout logged';

  @override
  String get snackbarCalendarAdded => 'Workout added to your calendar';

  @override
  String categorySubtitle(int count) {
    return '$count exercises';
  }

  @override
  String get catStrengthTitle => 'Strength';

  @override
  String get catStrengthDesc =>
      'Heavy compound lifts and accessory work to build power.';

  @override
  String get catCardioTitle => 'Cardio';

  @override
  String get catCardioDesc =>
      'Intervals and steady sessions to improve endurance.';

  @override
  String get catMobilityTitle => 'Mobility';

  @override
  String get catMobilityDesc =>
      'Joint-friendly flows to improve range of motion.';

  @override
  String get catCoreTitle => 'Core';

  @override
  String get catCoreDesc =>
      'Bracing and anti-rotation work for a resilient midline.';

  @override
  String get catRecoveryTitle => 'Recovery';

  @override
  String get catRecoveryDesc =>
      'Low intensity sessions to restore movement quality.';

  @override
  String get catSectionExercises => 'Available exercises';

  @override
  String get catSectionExamplePlans => 'Example plans';

  @override
  String get exPushUps => 'Push-ups';

  @override
  String get exSquats => 'Squats';

  @override
  String get exPlank => 'Plank';

  @override
  String get exLunges => 'Lunges';

  @override
  String get exJumpingJacks => 'Jumping Jacks';

  @override
  String get exPullUps => 'Pull-ups';

  @override
  String get exShoulderPress => 'Shoulder Press';

  @override
  String get exRunning => 'Running';

  @override
  String get exBackSquat => 'Back Squat';

  @override
  String get exBenchPress => 'Bench Press';

  @override
  String get exDeadlift => 'Deadlift';

  @override
  String get exRomanianDeadlift => 'Romanian Deadlift';

  @override
  String get exTempoRun => 'Tempo Run';

  @override
  String get exCycleIntervals => 'Cycle Intervals';

  @override
  String get exRowingSprint => 'Rowing Sprint';

  @override
  String get exJumpRope => 'Jump Rope';

  @override
  String get exThoracicRotation => 'Thoracic Rotation';

  @override
  String get exHipCars => 'Hip CARs';

  @override
  String get exAnkleMobility => 'Ankle Mobility';

  @override
  String get exShoulderDislocates => 'Shoulder Dislocates';

  @override
  String get exPlankVariations => 'Plank Variations';

  @override
  String get exPallofPress => 'Pallof Press';

  @override
  String get exHangingLegRaise => 'Hanging Leg Raise';

  @override
  String get exDeadBug => 'Dead Bug';

  @override
  String get exLightWalk => 'Light Walk';

  @override
  String get exBreathwork => 'Breathwork';

  @override
  String get exFoamRolling => 'Foam Rolling';

  @override
  String get exLegPress => 'Leg Press';

  @override
  String get exCalfRaises => 'Calf Raises';

  @override
  String get exBicycleCrunches => 'Bicycle Crunches';

  @override
  String get exRussianTwists => 'Russian Twists';

  @override
  String get exDynamicWarmUp => 'Dynamic Warm-up';

  @override
  String get seedPlanPushDay => 'Push Day';

  @override
  String get seedPlanLowerBody => 'Lower Body';

  @override
  String get seedPlanCardio => 'Cardio Session';

  @override
  String get seedPlanCore => 'Core Stability';

  @override
  String get sampleCompletionLegDay => 'Leg Day';

  @override
  String get sampleCompletionCore => 'Core Session';

  @override
  String get sampleCompletionRun => 'Morning Run';

  @override
  String get sampleTypeLowerBody => 'Lower body';

  @override
  String get sampleTypeCore => 'Core';

  @override
  String get sampleTypeOutdoorCardio => 'Outdoor cardio';

  @override
  String get sampleTypeCustomLog => 'Logged session';

  @override
  String get planUpperPower => 'Upper Power';

  @override
  String get planLowerStrength => 'Lower Strength';

  @override
  String get planFullBodyA => 'Full Body A';

  @override
  String get planHiit20 => 'HIIT 20';

  @override
  String get planSteadyZone2 => 'Steady Zone 2';

  @override
  String get planSprintLadder => 'Sprint Ladder';

  @override
  String get planMorningReset => 'Morning Reset';

  @override
  String get planPreTrainingPrep => 'Pre-Training Prep';

  @override
  String get planAbsFinishers => 'Abs Finishers';

  @override
  String get planAntiRotation => 'Anti-Rotation Block';

  @override
  String get planDeloadWeek => 'Deload Week';

  @override
  String get planSundayReset => 'Sunday Reset';

  @override
  String get badgeFirstSession => 'First session';

  @override
  String get badgeWeekWarrior => 'Week warrior';

  @override
  String get badgeStreakStarter => 'Streak starter';

  @override
  String get badgeConsistency => 'Consistency';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get progressWeeklyBarsDow1 => 'M';

  @override
  String get progressWeeklyBarsDow2 => 'T';

  @override
  String get progressWeeklyBarsDow3 => 'W';

  @override
  String get progressWeeklyBarsDow4 => 'T';

  @override
  String get progressWeeklyBarsDow5 => 'F';

  @override
  String get progressWeeklyBarsDow6 => 'S';

  @override
  String get progressWeeklyBarsDow7 => 'S';

  @override
  String get calendarDow1 => 'M';

  @override
  String get calendarDow2 => 'T';

  @override
  String get calendarDow3 => 'W';

  @override
  String get calendarDow4 => 'T';

  @override
  String get calendarDow5 => 'F';

  @override
  String get calendarDow6 => 'S';

  @override
  String get calendarDow7 => 'S';

  @override
  String get mapTitle => 'Territory Map';

  @override
  String get mapLocateMe => 'My location';

  @override
  String get mapLocating => 'Finding your location...';

  @override
  String get mapLocationUnavailable =>
      'Could not find your location. Turn on GPS and try again.';

  @override
  String get mapLocationServiceDisabled =>
      'Location services are off. Turn on GPS to see where you are.';

  @override
  String get mapLocationPermissionDenied =>
      'Location permission is required to show your position on the map.';

  @override
  String get mapLocationTimeout =>
      'GPS is taking too long. Move outdoors and tap My location again.';

  @override
  String get mapOpenLocationSettings => 'Open settings';

  @override
  String get mapModeMap => 'Map view';

  @override
  String get mapModeSatellite => 'Satellite view';

  @override
  String get mapLeaderboard => 'Leaderboard';

  @override
  String get mapStartCapture => 'Start Capture';

  @override
  String get mapCaptureActive => 'Capturing route';

  @override
  String get mapElapsed => 'Elapsed';

  @override
  String get mapDistance => 'Distance';

  @override
  String get mapEstimatedArea => 'Est. area';

  @override
  String get mapGpsAccuracy => 'GPS accuracy';

  @override
  String get mapFinishCapture => 'Finish';

  @override
  String get mapPermissionTitle => 'Location access needed';

  @override
  String get mapPermissionBody =>
      'GymCoach uses your location while the app is open to show your position and record territory capture routes.';

  @override
  String get mapPermissionServiceDisabled =>
      'Turn on location services in system settings to use the territory map.';

  @override
  String get mapAllowLocation => 'Allow location';

  @override
  String get mapOpenSettings => 'Open settings';

  @override
  String get mapPermissionDialogTitle =>
      'Enable location for territory capture';

  @override
  String get mapPermissionDialogBody =>
      'We only use your GPS while you actively capture a route. Your path is sent to the server when you finish a capture.';

  @override
  String get mapContinue => 'Continue';

  @override
  String get mapSatelliteUnavailable =>
      'Satellite view requires an external paid map provider. Standard OpenFreeMap is available for free.';

  @override
  String get mapEmptyTerritories => 'No territories captured yet';

  @override
  String get mapGpsAccuracyWarning =>
      'GPS accuracy is lower than ideal. You can continue, but try moving to open sky for a cleaner capture.';

  @override
  String get mapNameTerritoryTitle => 'Name your territory';

  @override
  String get mapTerritoryNameLabel => 'Territory name';

  @override
  String get mapCaptureSuccessTitle => 'Territory captured';

  @override
  String mapCaptureSuccessBody(String name, String area) {
    return '$name is now yours at $area.';
  }

  @override
  String get mapDone => 'Done';

  @override
  String get mapValidationMinPoints =>
      'Capture at least 4 valid GPS points before finishing.';

  @override
  String get mapValidationMinArea =>
      'The captured area is too small. Walk a larger loop and try again.';

  @override
  String get mapCaptureFailed => 'Could not finish the capture. Try again.';

  @override
  String get mapOwner => 'Owner';

  @override
  String get mapArea => 'Area';

  @override
  String get mapCapturedOn => 'Captured';

  @override
  String get mapZoomToTerritory => 'Zoom to territory';

  @override
  String get mapMyTerritory => 'My territory';

  @override
  String get mapViewOwnerProfile => 'View owner profile';

  @override
  String get mapLoopClosed =>
      'Loop closed — finish capture to claim this area.';

  @override
  String get mapLeaderboardTitle => 'Territory leaderboard';

  @override
  String get mapLeaderboardEmpty => 'No leaderboard data yet.';

  @override
  String mapLeaderboardMeta(String area, int count) {
    return '$area · $count territories';
  }

  @override
  String get feedSubtitle => 'Progress photos and training updates';

  @override
  String get feedPost => 'Post';

  @override
  String get feedPublish => 'Publish';

  @override
  String get feedDeletePost => 'Delete post';

  @override
  String get feedBlockUser => 'Block user';

  @override
  String get feedReportPost => 'Report post';
}
