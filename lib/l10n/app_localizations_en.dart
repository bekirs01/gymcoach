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
  String get navProgress => 'Progress';

  @override
  String get navProfile => 'Profile';

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
  String get workoutNameHint => 'e.g. Upper Body Power';

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
  String get progressMonthlyHint => 'Rolling training adherence (mock)';

  @override
  String get progressWeeklyVolume => 'Weekly volume';

  @override
  String get progressAchievements => 'Achievements';

  @override
  String get progressPersonalRecords => 'Personal records';

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
  String get sessionActiveTitle => 'Active Session';

  @override
  String get sessionCurrentExercise => 'Current exercise';

  @override
  String get labelSets => 'Sets';

  @override
  String get labelReps => 'Reps';

  @override
  String get sessionAllExercises => 'All exercises';

  @override
  String get sessionCompleteExercise => 'Complete exercise';

  @override
  String get sessionCompleteFinal => 'Complete final exercise';

  @override
  String get sessionFinishWorkout => 'Finish workout';

  @override
  String get sessionSummaryTitle => 'Session summary';

  @override
  String get sessionSummaryDuration => 'Duration';

  @override
  String get sessionSummaryCalories => 'Calories';

  @override
  String sessionCaloriesUnit(int count) {
    return '$count kcal';
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
  String get validationLogName => 'Enter a workout name.';

  @override
  String get historyWorkoutSummary => 'Workout summary';

  @override
  String get historyCompletedOn => 'Completed on';

  @override
  String get historyExercisesCompleted => 'Exercises completed';

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
  String get prBackSquat => 'Back Squat';

  @override
  String get pr5kRun => '5K Run';

  @override
  String get prPullUps => 'Pull-ups';

  @override
  String get prMockSquatValue => '110 kg';

  @override
  String get prMock5kValue => '22:40';

  @override
  String get prMockPullValue => '12 reps';

  @override
  String get prMockSquatDate => 'Apr 2026';

  @override
  String get prMock5kDate => 'Mar 2026';

  @override
  String get prMockPullDate => 'Feb 2026';

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
}
