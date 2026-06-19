import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GymCoach'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPlans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get navPlans;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get navFeed;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get navLeaderboard;

  /// No description provided for @leaderboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ranked by total captured territory on the map'**
  String get leaderboardSubtitle;

  /// No description provided for @leaderboardYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get leaderboardYou;

  /// No description provided for @closeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeTooltip;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @scheduleToday.
  ///
  /// In en, this message translates to:
  /// **'Today · {time}'**
  String scheduleToday(String time);

  /// No description provided for @scheduleTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow · {time}'**
  String scheduleTomorrow(String time);

  /// No description provided for @scheduleDateTime.
  ///
  /// In en, this message translates to:
  /// **'{date} · {time}'**
  String scheduleDateTime(String date, String time);

  /// No description provided for @activityYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get activityYesterday;

  /// No description provided for @activityDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String activityDaysAgo(int count);

  /// No description provided for @activityToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get activityToday;

  /// No description provided for @homeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeWelcomeBack;

  /// No description provided for @homeStayConsistent.
  ///
  /// In en, this message translates to:
  /// **'Stay consistent and keep moving.'**
  String get homeStayConsistent;

  /// No description provided for @homeTodaysFocus.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Focus'**
  String get homeTodaysFocus;

  /// No description provided for @homeTrainingFocus.
  ///
  /// In en, this message translates to:
  /// **'Training Focus'**
  String get homeTrainingFocus;

  /// No description provided for @homeSchedulePlanPrompt.
  ///
  /// In en, this message translates to:
  /// **'Schedule a plan to stay consistent.'**
  String get homeSchedulePlanPrompt;

  /// No description provided for @homeOneWorkoutToday.
  ///
  /// In en, this message translates to:
  /// **'1 workout planned for today'**
  String get homeOneWorkoutToday;

  /// No description provided for @homeNWorkoutsToday.
  ///
  /// In en, this message translates to:
  /// **'{count} workouts planned for today'**
  String homeNWorkoutsToday(int count);

  /// No description provided for @homeMetricPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned workouts'**
  String get homeMetricPlanned;

  /// No description provided for @homeMetricCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed workouts'**
  String get homeMetricCompleted;

  /// No description provided for @homeMetricThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get homeMetricThisWeek;

  /// No description provided for @homeNextWorkout.
  ///
  /// In en, this message translates to:
  /// **'Next Workout'**
  String get homeNextWorkout;

  /// No description provided for @homeNoneScheduled.
  ///
  /// In en, this message translates to:
  /// **'None scheduled'**
  String get homeNoneScheduled;

  /// No description provided for @homeAddWorkoutPlan.
  ///
  /// In en, this message translates to:
  /// **'Add a workout plan'**
  String get homeAddWorkoutPlan;

  /// No description provided for @homeNextWorkoutEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Create a plan to see your next session here.'**
  String get homeNextWorkoutEmptyHint;

  /// No description provided for @homeOpenDetails.
  ///
  /// In en, this message translates to:
  /// **'Open Details'**
  String get homeOpenDetails;

  /// No description provided for @homeViewPlans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get homeViewPlans;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActions;

  /// No description provided for @homeWeeklyActivity.
  ///
  /// In en, this message translates to:
  /// **'Weekly Activity'**
  String get homeWeeklyActivity;

  /// No description provided for @homeExerciseCategories.
  ///
  /// In en, this message translates to:
  /// **'Exercise Categories'**
  String get homeExerciseCategories;

  /// No description provided for @homeRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get homeRecentActivity;

  /// No description provided for @homeRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recent sessions yet. Finish a workout to see it here.'**
  String get homeRecentEmpty;

  /// No description provided for @homeStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get homeStartWorkout;

  /// No description provided for @homeViewPlanLink.
  ///
  /// In en, this message translates to:
  /// **'View Plan'**
  String get homeViewPlanLink;

  /// No description provided for @homeStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak alive'**
  String get homeStreakTitle;

  /// No description provided for @homeStreakSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete one workout today to stay on track.'**
  String get homeStreakSubtitle;

  /// No description provided for @homeQuickCreatePlan.
  ///
  /// In en, this message translates to:
  /// **'Create Plan'**
  String get homeQuickCreatePlan;

  /// No description provided for @homeQuickLogWorkout.
  ///
  /// In en, this message translates to:
  /// **'Log Workout'**
  String get homeQuickLogWorkout;

  /// No description provided for @homeQuickStatistics.
  ///
  /// In en, this message translates to:
  /// **'View Statistics'**
  String get homeQuickStatistics;

  /// No description provided for @homeNoWorkoutToday.
  ///
  /// In en, this message translates to:
  /// **'No workout planned for today.'**
  String get homeNoWorkoutToday;

  /// No description provided for @homeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get homeScreenTitle;

  /// No description provided for @homeTabDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get homeTabDashboard;

  /// No description provided for @homeTabWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get homeTabWorkouts;

  /// No description provided for @homeTabDiet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get homeTabDiet;

  /// No description provided for @homeBannerCreateHint.
  ///
  /// In en, this message translates to:
  /// **'See how to create new workouts'**
  String get homeBannerCreateHint;

  /// No description provided for @homeBannerStartHint.
  ///
  /// In en, this message translates to:
  /// **'Start by adding a new training day'**
  String get homeBannerStartHint;

  /// No description provided for @homeMyTraining.
  ///
  /// In en, this message translates to:
  /// **'My Training'**
  String get homeMyTraining;

  /// No description provided for @homeCompletedSessions.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions completed'**
  String homeCompletedSessions(int count);

  /// No description provided for @homeTrainingSchedule.
  ///
  /// In en, this message translates to:
  /// **'Training Schedule'**
  String get homeTrainingSchedule;

  /// No description provided for @homeMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get homeMore;

  /// No description provided for @homeArticles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get homeArticles;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAll;

  /// No description provided for @homeNoWorkoutsOnDate.
  ///
  /// In en, this message translates to:
  /// **'No workouts scheduled for this date'**
  String get homeNoWorkoutsOnDate;

  /// No description provided for @homeFeaturedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No training plan yet'**
  String get homeFeaturedEmptyTitle;

  /// No description provided for @homeFeaturedEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first workout to get started'**
  String get homeFeaturedEmptySubtitle;

  /// No description provided for @plansPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Plans'**
  String get plansPageTitle;

  /// No description provided for @plansPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan your training and stay consistent.'**
  String get plansPageSubtitle;

  /// No description provided for @plansCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Plan'**
  String get plansCreate;

  /// No description provided for @plansSectionYourPlans.
  ///
  /// In en, this message translates to:
  /// **'Your plans'**
  String get plansSectionYourPlans;

  /// No description provided for @plansTotalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String plansTotalCount(int count);

  /// No description provided for @plansEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No workout plans yet'**
  String get plansEmptyTitle;

  /// No description provided for @plansEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create your first plan and start building consistency.'**
  String get plansEmptyBody;

  /// No description provided for @plansSnackbarCreated.
  ///
  /// In en, this message translates to:
  /// **'Workout plan created'**
  String get plansSnackbarCreated;

  /// No description provided for @plansSnackbarOnlyPlanned.
  ///
  /// In en, this message translates to:
  /// **'Only planned workouts can start a live session.'**
  String get plansSnackbarOnlyPlanned;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutesShort(int count);

  /// No description provided for @minutesPlanShort.
  ///
  /// In en, this message translates to:
  /// **'{count} min plan'**
  String minutesPlanShort(int count);

  /// No description provided for @durationMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String durationMinutesLabel(int count);

  /// No description provided for @homeAddWorkout.
  ///
  /// In en, this message translates to:
  /// **'Add workout'**
  String get homeAddWorkout;

  /// No description provided for @workoutListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your workout list is empty'**
  String get workoutListEmptyTitle;

  /// No description provided for @workoutListEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Start by adding exercises to a new training day.'**
  String get workoutListEmptyBody;

  /// No description provided for @workoutAddTrainingDay.
  ///
  /// In en, this message translates to:
  /// **'Add training day'**
  String get workoutAddTrainingDay;

  /// No description provided for @workoutChooseMuscleGroup.
  ///
  /// In en, this message translates to:
  /// **'Choose muscle group'**
  String get workoutChooseMuscleGroup;

  /// No description provided for @workoutChooseExercises.
  ///
  /// In en, this message translates to:
  /// **'Choose exercises'**
  String get workoutChooseExercises;

  /// No description provided for @workoutNameYourWorkout.
  ///
  /// In en, this message translates to:
  /// **'Name your workout'**
  String get workoutNameYourWorkout;

  /// No description provided for @workoutScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule workout'**
  String get workoutScheduleTitle;

  /// No description provided for @workoutScheduleHint.
  ///
  /// In en, this message translates to:
  /// **'Choose date, time, and duration for this workout.'**
  String get workoutScheduleHint;

  /// No description provided for @workoutMuscleGroupHint.
  ///
  /// In en, this message translates to:
  /// **'Select one or more areas you want to train.'**
  String get workoutMuscleGroupHint;

  /// No description provided for @workoutContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get workoutContinue;

  /// No description provided for @workoutContinueGroups.
  ///
  /// In en, this message translates to:
  /// **'Continue ({count} groups)'**
  String workoutContinueGroups(int count);

  /// No description provided for @workoutSelectExercises.
  ///
  /// In en, this message translates to:
  /// **'Select exercises'**
  String get workoutSelectExercises;

  /// No description provided for @workoutContinueExercises.
  ///
  /// In en, this message translates to:
  /// **'Continue ({count})'**
  String workoutContinueExercises(int count);

  /// No description provided for @workoutSaveWorkout.
  ///
  /// In en, this message translates to:
  /// **'Save workout'**
  String get workoutSaveWorkout;

  /// No description provided for @workoutExerciseHintSingle.
  ///
  /// In en, this message translates to:
  /// **'Choose {category} exercises. Tap a row to select and read the details.'**
  String workoutExerciseHintSingle(String category);

  /// No description provided for @workoutExerciseHintMulti.
  ///
  /// In en, this message translates to:
  /// **'Choose exercises from your selected muscle groups.'**
  String get workoutExerciseHintMulti;

  /// No description provided for @workoutNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Upper Body Power'**
  String get workoutNameHint;

  /// No description provided for @workoutSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get workoutSelected;

  /// No description provided for @workoutBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get workoutBack;

  /// No description provided for @planRepeatWorkout.
  ///
  /// In en, this message translates to:
  /// **'Repeat workout'**
  String get planRepeatWorkout;

  /// No description provided for @planCustomizeRepeat.
  ///
  /// In en, this message translates to:
  /// **'Customize and schedule'**
  String get planCustomizeRepeat;

  /// No description provided for @planCompletedHint.
  ///
  /// In en, this message translates to:
  /// **'This workout is finished. Repeat it on another day or adjust exercises first.'**
  String get planCompletedHint;

  /// No description provided for @exercisesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String exercisesCount(int count);

  /// No description provided for @difficultyBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get difficultyBeginner;

  /// No description provided for @difficultyIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get difficultyIntermediate;

  /// No description provided for @difficultyAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get difficultyAdvanced;

  /// No description provided for @statusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get statusPlanned;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// No description provided for @planCardDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get planCardDetails;

  /// No description provided for @planCardStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get planCardStart;

  /// No description provided for @planDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Details'**
  String get planDetailTitle;

  /// No description provided for @planDetailSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get planDetailSchedule;

  /// No description provided for @planDetailExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get planDetailExercises;

  /// No description provided for @labelDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get labelDate;

  /// No description provided for @labelTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get labelTime;

  /// No description provided for @labelDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get labelDuration;

  /// No description provided for @beginSession.
  ///
  /// In en, this message translates to:
  /// **'Begin Session'**
  String get beginSession;

  /// No description provided for @editPlan.
  ///
  /// In en, this message translates to:
  /// **'Edit Plan'**
  String get editPlan;

  /// No description provided for @planSessionOnlyPlanned.
  ///
  /// In en, this message translates to:
  /// **'Only planned workouts can begin a new session.'**
  String get planSessionOnlyPlanned;

  /// No description provided for @deletePlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete plan'**
  String get deletePlanTitle;

  /// No description provided for @deletePlanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" permanently?'**
  String deletePlanConfirm(String name);

  /// No description provided for @deleteWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete workout?'**
  String get deleteWorkoutTitle;

  /// No description provided for @deleteWorkoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{name}\" and its exercises.'**
  String deleteWorkoutSubtitle(String name);

  /// No description provided for @deleteWorkoutWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get deleteWorkoutWarning;

  /// No description provided for @deleteWorkoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete workout'**
  String get deleteWorkoutConfirm;

  /// No description provided for @createPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Plan'**
  String get createPlanTitle;

  /// No description provided for @editPlanSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Plan'**
  String get editPlanSheetTitle;

  /// No description provided for @savePlan.
  ///
  /// In en, this message translates to:
  /// **'Save Plan'**
  String get savePlan;

  /// No description provided for @updatePlan.
  ///
  /// In en, this message translates to:
  /// **'Update Plan'**
  String get updatePlan;

  /// No description provided for @workoutNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Workout name'**
  String get workoutNameLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @difficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficultyLabel;

  /// No description provided for @exercisesLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercisesLabel;

  /// No description provided for @exercisesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String exercisesSelected(int count);

  /// No description provided for @validationWorkoutName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a workout name.'**
  String get validationWorkoutName;

  /// No description provided for @validationPickExercise.
  ///
  /// In en, this message translates to:
  /// **'Select at least one exercise.'**
  String get validationPickExercise;

  /// No description provided for @chipMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String chipMinutes(int count);

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarWorkoutsOn.
  ///
  /// In en, this message translates to:
  /// **'Workouts on {date}'**
  String calendarWorkoutsOn(String date);

  /// No description provided for @calendarEmptyDay.
  ///
  /// In en, this message translates to:
  /// **'No workouts on this day. Add a session to stay on schedule.'**
  String get calendarEmptyDay;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Performance overview and history'**
  String get progressSubtitle;

  /// No description provided for @progressWeeklySessions.
  ///
  /// In en, this message translates to:
  /// **'Weekly sessions'**
  String get progressWeeklySessions;

  /// No description provided for @progressActiveStreak.
  ///
  /// In en, this message translates to:
  /// **'Active streak'**
  String get progressActiveStreak;

  /// No description provided for @progressStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String progressStreakDays(int count);

  /// No description provided for @progressMonthlyConsistency.
  ///
  /// In en, this message translates to:
  /// **'Monthly consistency'**
  String get progressMonthlyConsistency;

  /// No description provided for @progressMonthlyHint.
  ///
  /// In en, this message translates to:
  /// **'Completed sessions vs plans scheduled this month'**
  String get progressMonthlyHint;

  /// No description provided for @progressWeeklyVolume.
  ///
  /// In en, this message translates to:
  /// **'Weekly volume'**
  String get progressWeeklyVolume;

  /// No description provided for @progressTotalSessions.
  ///
  /// In en, this message translates to:
  /// **'Total sessions'**
  String get progressTotalSessions;

  /// No description provided for @progressWeeklyMinutes.
  ///
  /// In en, this message translates to:
  /// **'Training time this week'**
  String get progressWeeklyMinutes;

  /// No description provided for @progressWeeklyCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories this week'**
  String get progressWeeklyCalories;

  /// No description provided for @progressWeekActivity.
  ///
  /// In en, this message translates to:
  /// **'Calories by day'**
  String get progressWeekActivity;

  /// No description provided for @progressWeekActivityHint.
  ///
  /// In en, this message translates to:
  /// **'Calories burned each day this week'**
  String get progressWeekActivityHint;

  /// No description provided for @progressMonthSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions this month'**
  String get progressMonthSessions;

  /// No description provided for @progressPlannedUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming workouts'**
  String get progressPlannedUpcoming;

  /// No description provided for @progressAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get progressAchievements;

  /// No description provided for @progressSessionHighlights.
  ///
  /// In en, this message translates to:
  /// **'Session highlights'**
  String get progressSessionHighlights;

  /// No description provided for @progressHighlightLongest.
  ///
  /// In en, this message translates to:
  /// **'Longest session'**
  String get progressHighlightLongest;

  /// No description provided for @progressHighlightCalories.
  ///
  /// In en, this message translates to:
  /// **'Peak calories'**
  String get progressHighlightCalories;

  /// No description provided for @progressHighlightMoves.
  ///
  /// In en, this message translates to:
  /// **'Most exercises'**
  String get progressHighlightMoves;

  /// No description provided for @progressHighlightsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log workouts to see your best sessions here.'**
  String get progressHighlightsEmpty;

  /// No description provided for @progressWorkoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Workout history'**
  String get progressWorkoutHistory;

  /// No description provided for @progressHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No completed sessions yet. Finish a workout to see it here.'**
  String get progressHistoryEmpty;

  /// No description provided for @streakDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak details'**
  String get streakDetailsTitle;

  /// No description provided for @streakDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your training consistency'**
  String get streakDetailsSubtitle;

  /// No description provided for @streakDayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String streakDayStreak(int count);

  /// No description provided for @streakMomentum.
  ///
  /// In en, this message translates to:
  /// **'Train today to keep momentum.'**
  String get streakMomentum;

  /// No description provided for @streakTrainTodayStart.
  ///
  /// In en, this message translates to:
  /// **'Train today to start your streak'**
  String get streakTrainTodayStart;

  /// No description provided for @streakBuildingMomentum.
  ///
  /// In en, this message translates to:
  /// **'You are building momentum'**
  String get streakBuildingMomentum;

  /// No description provided for @streakBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get streakBestStreak;

  /// No description provided for @streakThisWeekSessions.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get streakThisWeekSessions;

  /// No description provided for @streakLastWorkout.
  ///
  /// In en, this message translates to:
  /// **'Last workout'**
  String get streakLastWorkout;

  /// No description provided for @streakActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get streakActiveDays;

  /// No description provided for @streakWeeklyCompletion.
  ///
  /// In en, this message translates to:
  /// **'Weekly completion'**
  String get streakWeeklyCompletion;

  /// No description provided for @streakNextMilestone.
  ///
  /// In en, this message translates to:
  /// **'Next milestone'**
  String get streakNextMilestone;

  /// No description provided for @streakDaysShort.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String streakDaysShort(int count);

  /// No description provided for @streakMilestoneDays.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String streakMilestoneDays(int count);

  /// No description provided for @streakThisWeekSection.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get streakThisWeekSection;

  /// Singular workout count label
  ///
  /// In en, this message translates to:
  /// **'{count} workout'**
  String streakWorkoutsThisWeek(int count);

  /// No description provided for @streakWorkoutsThisWeekPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} workouts'**
  String streakWorkoutsThisWeekPlural(int count);

  /// No description provided for @streakCompletionPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String streakCompletionPercent(int percent);

  /// No description provided for @streakNoLastWorkout.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get streakNoLastWorkout;

  /// No description provided for @streakRecentDays.
  ///
  /// In en, this message translates to:
  /// **'Recent training days'**
  String get streakRecentDays;

  /// No description provided for @streakEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete a workout to start your streak.'**
  String get streakEmpty;

  /// No description provided for @streakEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Finish your first session to build momentum here.'**
  String get streakEmptyHint;

  /// No description provided for @streakTipShortSession.
  ///
  /// In en, this message translates to:
  /// **'Even a short session counts.'**
  String get streakTipShortSession;

  /// No description provided for @streakTipSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule tomorrow\'s workout in advance.'**
  String get streakTipSchedule;

  /// No description provided for @streakTipConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency matters more than intensity.'**
  String get streakTipConsistency;

  /// No description provided for @streakOpenProgress.
  ///
  /// In en, this message translates to:
  /// **'Open Progress'**
  String get streakOpenProgress;

  /// No description provided for @streakViewProgress.
  ///
  /// In en, this message translates to:
  /// **'View progress'**
  String get streakViewProgress;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileTabPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get profileTabPhotos;

  /// No description provided for @profileTabAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileTabAbout;

  /// No description provided for @profileTabFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get profileTabFeed;

  /// No description provided for @profileTabSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get profileTabSaved;

  /// No description provided for @profileTabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileTabSettings;

  /// No description provided for @profileEditShort.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profileEditShort;

  /// No description provided for @profileClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get profileClose;

  /// No description provided for @profileNoBio.
  ///
  /// In en, this message translates to:
  /// **'No public bio yet.'**
  String get profileNoBio;

  /// No description provided for @profileAboutEmpty.
  ///
  /// In en, this message translates to:
  /// **'This user has not added information about themselves yet.'**
  String get profileAboutEmpty;

  /// No description provided for @profilePhotosEmpty.
  ///
  /// In en, this message translates to:
  /// **'This user has not added any photos yet.'**
  String get profilePhotosEmpty;

  /// No description provided for @profilePostsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get profilePostsEmpty;

  /// No description provided for @profileSavedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved posts yet'**
  String get profileSavedEmpty;

  /// No description provided for @profilePrivateNotes.
  ///
  /// In en, this message translates to:
  /// **'Private notes'**
  String get profilePrivateNotes;

  /// No description provided for @profilePrivateNotesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add private notes only you can see.'**
  String get profilePrivateNotesEmpty;

  /// No description provided for @profileFitnessSummary.
  ///
  /// In en, this message translates to:
  /// **'Fitness summary'**
  String get profileFitnessSummary;

  /// No description provided for @profileWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get profileWeight;

  /// No description provided for @profileHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get profileHeight;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditProfile;

  /// No description provided for @profileAppPreferences.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get profileAppPreferences;

  /// No description provided for @profileNotificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotificationsSection;

  /// No description provided for @profileRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Training reminders'**
  String get profileRemindersTitle;

  /// No description provided for @profileRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay notified about upcoming sessions'**
  String get profileRemindersSubtitle;

  /// No description provided for @profileLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get profileLogOut;

  /// No description provided for @profileEditSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditSheetTitle;

  /// No description provided for @profileAvatarButton.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get profileAvatarButton;

  /// No description provided for @profileCoverButton.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get profileCoverButton;

  /// No description provided for @profilePublicBioLabel.
  ///
  /// In en, this message translates to:
  /// **'Public bio'**
  String get profilePublicBioLabel;

  /// No description provided for @profilePublicToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Public profile'**
  String get profilePublicToggleTitle;

  /// No description provided for @profilePublicToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visible in Feed and Leaderboard'**
  String get profilePublicToggleSubtitle;

  /// No description provided for @labelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelName;

  /// No description provided for @labelWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get labelWeightKg;

  /// No description provided for @labelHeightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get labelHeightCm;

  /// No description provided for @labelFitnessGoal.
  ///
  /// In en, this message translates to:
  /// **'Fitness goal'**
  String get labelFitnessGoal;

  /// No description provided for @labelMembership.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get labelMembership;

  /// No description provided for @validationProfileName.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get validationProfileName;

  /// No description provided for @validationProfileWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight (use dot or comma as decimal separator).'**
  String get validationProfileWeight;

  /// No description provided for @validationProfileHeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid height (use dot or comma as decimal separator).'**
  String get validationProfileHeight;

  /// No description provided for @membershipFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get membershipFree;

  /// No description provided for @membershipPlus.
  ///
  /// In en, this message translates to:
  /// **'Plus'**
  String get membershipPlus;

  /// No description provided for @membershipPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get membershipPremium;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App display language'**
  String get languageSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get languagePickerTitle;

  /// No description provided for @profilePreferencesSnack.
  ///
  /// In en, this message translates to:
  /// **'Preferences will connect to settings in a future release.'**
  String get profilePreferencesSnack;

  /// No description provided for @profileLogoutSnack.
  ///
  /// In en, this message translates to:
  /// **'Logout will be available when accounts launch.'**
  String get profileLogoutSnack;

  /// No description provided for @profileDefaultGoal.
  ///
  /// In en, this message translates to:
  /// **'Strength and conditioning'**
  String get profileDefaultGoal;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to GymCoach'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your name, weight, and height so workouts and calorie estimates fit you.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @sessionActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Session'**
  String get sessionActiveTitle;

  /// No description provided for @sessionStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to train?'**
  String get sessionStartTitle;

  /// No description provided for @sessionStartBody.
  ///
  /// In en, this message translates to:
  /// **'Start the session when you begin your workout. Duration and calories will be calculated from that moment.'**
  String get sessionStartBody;

  /// No description provided for @sessionStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get sessionStartButton;

  /// No description provided for @sessionStartFirst.
  ///
  /// In en, this message translates to:
  /// **'Start the session before logging exercises.'**
  String get sessionStartFirst;

  /// No description provided for @sessionTimerRunning.
  ///
  /// In en, this message translates to:
  /// **'Timer running'**
  String get sessionTimerRunning;

  /// No description provided for @sessionCurrentExercise.
  ///
  /// In en, this message translates to:
  /// **'Current exercise'**
  String get sessionCurrentExercise;

  /// No description provided for @labelSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get labelSets;

  /// No description provided for @labelReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get labelReps;

  /// No description provided for @labelRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get labelRest;

  /// No description provided for @sessionAllExercises.
  ///
  /// In en, this message translates to:
  /// **'All exercises'**
  String get sessionAllExercises;

  /// No description provided for @sessionExerciseOf.
  ///
  /// In en, this message translates to:
  /// **'Exercise {current} of {total}'**
  String sessionExerciseOf(int current, int total);

  /// No description provided for @sessionCompleteExercise.
  ///
  /// In en, this message translates to:
  /// **'Complete exercise'**
  String get sessionCompleteExercise;

  /// No description provided for @sessionCompleteFinal.
  ///
  /// In en, this message translates to:
  /// **'Complete final exercise'**
  String get sessionCompleteFinal;

  /// No description provided for @sessionNextExercise.
  ///
  /// In en, this message translates to:
  /// **'Next exercise'**
  String get sessionNextExercise;

  /// No description provided for @sessionEndWorkout.
  ///
  /// In en, this message translates to:
  /// **'End workout'**
  String get sessionEndWorkout;

  /// No description provided for @sessionFinishWorkout.
  ///
  /// In en, this message translates to:
  /// **'Finish workout'**
  String get sessionFinishWorkout;

  /// No description provided for @sessionFormTips.
  ///
  /// In en, this message translates to:
  /// **'FORM TIPS'**
  String get sessionFormTips;

  /// No description provided for @sessionBetweenSets.
  ///
  /// In en, this message translates to:
  /// **'Between sets'**
  String get sessionBetweenSets;

  /// No description provided for @sessionChipTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get sessionChipTarget;

  /// No description provided for @sessionChipTempo.
  ///
  /// In en, this message translates to:
  /// **'Tempo'**
  String get sessionChipTempo;

  /// No description provided for @sessionChipEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get sessionChipEquipment;

  /// No description provided for @sessionCommonMistakes.
  ///
  /// In en, this message translates to:
  /// **'COMMON MISTAKES'**
  String get sessionCommonMistakes;

  /// No description provided for @sessionInfoSets.
  ///
  /// In en, this message translates to:
  /// **'How many rounds of this exercise you do.'**
  String get sessionInfoSets;

  /// No description provided for @sessionInfoReps.
  ///
  /// In en, this message translates to:
  /// **'How many repetitions you perform in each set.'**
  String get sessionInfoReps;

  /// No description provided for @sessionInfoRest.
  ///
  /// In en, this message translates to:
  /// **'How long you rest between sets.'**
  String get sessionInfoRest;

  /// No description provided for @sessionInfoTarget.
  ///
  /// In en, this message translates to:
  /// **'Main muscle group trained by this exercise.'**
  String get sessionInfoTarget;

  /// No description provided for @sessionInfoTempo.
  ///
  /// In en, this message translates to:
  /// **'Speed of the movement. Example 2-0-2 means 2 seconds down, no pause, 2 seconds up.'**
  String get sessionInfoTempo;

  /// No description provided for @sessionInfoEquipment.
  ///
  /// In en, this message translates to:
  /// **'What you need to perform this exercise.'**
  String get sessionInfoEquipment;

  /// No description provided for @sessionSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Session summary'**
  String get sessionSummaryTitle;

  /// No description provided for @sessionSummaryDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get sessionSummaryDuration;

  /// No description provided for @sessionSummaryCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get sessionSummaryCalories;

  /// No description provided for @sessionSummaryVolumeLine.
  ///
  /// In en, this message translates to:
  /// **'Exercise volume: {logKcal} kcal · Session total: {totalKcal} kcal'**
  String sessionSummaryVolumeLine(int logKcal, int totalKcal);

  /// No description provided for @sessionDurationSecondsOnly.
  ///
  /// In en, this message translates to:
  /// **'{count}s'**
  String sessionDurationSecondsOnly(int count);

  /// No description provided for @sessionDurationMinutesOnly.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String sessionDurationMinutesOnly(int count);

  /// No description provided for @sessionDurationMinutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String sessionDurationMinutesSeconds(int minutes, int seconds);

  /// No description provided for @sessionCaloriesUnit.
  ///
  /// In en, this message translates to:
  /// **'{count} kcal'**
  String sessionCaloriesUnit(int count);

  /// No description provided for @sessionCaloriesEstimateNote.
  ///
  /// In en, this message translates to:
  /// **'Calorie values are approximate only, not exact. They are estimated from your weight, height, each exercise, sets, reps, and session duration.'**
  String get sessionCaloriesEstimateNote;

  /// No description provided for @sessionValidationSetsReps.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive number of sets and reps to log this exercise.'**
  String get sessionValidationSetsReps;

  /// No description provided for @sessionExerciseAlreadyLogged.
  ///
  /// In en, this message translates to:
  /// **'This exercise is already logged. Select another from the list.'**
  String get sessionExerciseAlreadyLogged;

  /// No description provided for @sessionCameraTrackingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Camera tracking (coming soon)'**
  String get sessionCameraTrackingComingSoon;

  /// No description provided for @sessionCameraTracking.
  ///
  /// In en, this message translates to:
  /// **'Track with camera'**
  String get sessionCameraTracking;

  /// No description provided for @cameraTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera tracking'**
  String get cameraTrackingTitle;

  /// No description provided for @cameraStartTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking'**
  String get cameraStartTracking;

  /// No description provided for @cameraApplyCount.
  ///
  /// In en, this message translates to:
  /// **'Apply count'**
  String get cameraApplyCount;

  /// No description provided for @cameraRepCount.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get cameraRepCount;

  /// No description provided for @cameraHoldSeconds.
  ///
  /// In en, this message translates to:
  /// **'Hold (sec)'**
  String get cameraHoldSeconds;

  /// No description provided for @cameraBodyNotVisible.
  ///
  /// In en, this message translates to:
  /// **'Step into frame so your body is visible'**
  String get cameraBodyNotVisible;

  /// No description provided for @cameraSafetyDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This tool does not replace a qualified trainer. Stop if you feel pain.'**
  String get cameraSafetyDisclaimer;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required for tracking.'**
  String get cameraPermissionDenied;

  /// No description provided for @cameraPlatformUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Camera tracking works on Android and iOS devices.'**
  String get cameraPlatformUnsupported;

  /// No description provided for @cameraManualFallback.
  ///
  /// In en, this message translates to:
  /// **'You can count reps manually on the workout screen.'**
  String get cameraManualFallback;

  /// No description provided for @cameraUseManual.
  ///
  /// In en, this message translates to:
  /// **'Use manual counting'**
  String get cameraUseManual;

  /// No description provided for @cameraOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get cameraOpenSettings;

  /// No description provided for @cameraRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get cameraRetry;

  /// No description provided for @cameraPreviewLoading.
  ///
  /// In en, this message translates to:
  /// **'Starting camera…'**
  String get cameraPreviewLoading;

  /// No description provided for @cameraTrackingLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get cameraTrackingLive;

  /// No description provided for @cameraInvalidAttempts.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get cameraInvalidAttempts;

  /// No description provided for @cameraUnsupportedExercise.
  ///
  /// In en, this message translates to:
  /// **'Camera tracking is not available for this exercise yet.'**
  String get cameraUnsupportedExercise;

  /// No description provided for @cameraInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start the camera. Try again or use manual counting.'**
  String get cameraInitFailed;

  /// No description provided for @cameraFeedbackSaggingHips.
  ///
  /// In en, this message translates to:
  /// **'Keep hips aligned — avoid sagging'**
  String get cameraFeedbackSaggingHips;

  /// No description provided for @cameraFeedbackRaiseHigher.
  ///
  /// In en, this message translates to:
  /// **'Raise arms higher to shoulder level'**
  String get cameraFeedbackRaiseHigher;

  /// No description provided for @cameraFeedbackIncompletePress.
  ///
  /// In en, this message translates to:
  /// **'Full overhead extension required'**
  String get cameraFeedbackIncompletePress;

  /// No description provided for @cameraFeedbackPullHigher.
  ///
  /// In en, this message translates to:
  /// **'Pull higher — chin above hands'**
  String get cameraFeedbackPullHigher;

  /// No description provided for @cameraFeedbackHipsSagging.
  ///
  /// In en, this message translates to:
  /// **'Lift hips — keep body straight'**
  String get cameraFeedbackHipsSagging;

  /// No description provided for @cameraFeedbackAdjustForm.
  ///
  /// In en, this message translates to:
  /// **'Adjust form and try again'**
  String get cameraFeedbackAdjustForm;

  /// No description provided for @cameraAppliedReps.
  ///
  /// In en, this message translates to:
  /// **'Applied {count} reps from camera'**
  String cameraAppliedReps(int count);

  /// No description provided for @cameraAppliedHold.
  ///
  /// In en, this message translates to:
  /// **'Applied {count}s hold from camera'**
  String cameraAppliedHold(int count);

  /// No description provided for @sessionCompletedExercises.
  ///
  /// In en, this message translates to:
  /// **'Completed exercises'**
  String get sessionCompletedExercises;

  /// No description provided for @sessionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get sessionDone;

  /// No description provided for @workoutTypePlannedSession.
  ///
  /// In en, this message translates to:
  /// **'Planned session'**
  String get workoutTypePlannedSession;

  /// No description provided for @logWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log workout'**
  String get logWorkoutTitle;

  /// No description provided for @logWorkoutName.
  ///
  /// In en, this message translates to:
  /// **'Workout name'**
  String get logWorkoutName;

  /// No description provided for @logWorkoutType.
  ///
  /// In en, this message translates to:
  /// **'Workout type'**
  String get logWorkoutType;

  /// No description provided for @logWorkoutTypeDefault.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get logWorkoutTypeDefault;

  /// No description provided for @logDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get logDuration;

  /// No description provided for @logSave.
  ///
  /// In en, this message translates to:
  /// **'Save log'**
  String get logSave;

  /// No description provided for @quickLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log past workout'**
  String get quickLogTitle;

  /// No description provided for @quickLogDate.
  ///
  /// In en, this message translates to:
  /// **'Workout date'**
  String get quickLogDate;

  /// No description provided for @quickLogYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get quickLogYesterday;

  /// No description provided for @quickLogDayBefore.
  ///
  /// In en, this message translates to:
  /// **'2 days ago'**
  String get quickLogDayBefore;

  /// No description provided for @quickLogAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get quickLogAddExercise;

  /// No description provided for @templateFromLabel.
  ///
  /// In en, this message translates to:
  /// **'From template'**
  String get templateFromLabel;

  /// No description provided for @templateSave.
  ///
  /// In en, this message translates to:
  /// **'Save as template'**
  String get templateSave;

  /// No description provided for @templateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get templateSaved;

  /// No description provided for @copyPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule on another day'**
  String get copyPlanTitle;

  /// No description provided for @copyPlanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get copyPlanConfirm;

  /// No description provided for @snackbarPlanCopied.
  ///
  /// In en, this message translates to:
  /// **'Workout copied to calendar'**
  String get snackbarPlanCopied;

  /// No description provided for @sessionManageExercises.
  ///
  /// In en, this message translates to:
  /// **'Manage exercises'**
  String get sessionManageExercises;

  /// No description provided for @sessionAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get sessionAddExercise;

  /// No description provided for @validationLogName.
  ///
  /// In en, this message translates to:
  /// **'Enter a workout name.'**
  String get validationLogName;

  /// No description provided for @historyWorkoutSummary.
  ///
  /// In en, this message translates to:
  /// **'Workout summary'**
  String get historyWorkoutSummary;

  /// No description provided for @historyCompletedOn.
  ///
  /// In en, this message translates to:
  /// **'Completed on'**
  String get historyCompletedOn;

  /// No description provided for @historyExercisesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Exercises completed'**
  String get historyExercisesCompleted;

  /// No description provided for @historySetsRepsDetail.
  ///
  /// In en, this message translates to:
  /// **'{sets} sets · {reps} reps'**
  String historySetsRepsDetail(int sets, int reps);

  /// No description provided for @historyCaloriesEstimateNote.
  ///
  /// In en, this message translates to:
  /// **'Calorie values are approximate only, not an exact measurement.'**
  String get historyCaloriesEstimateNote;

  /// No description provided for @snackbarWorkoutSavedHistory.
  ///
  /// In en, this message translates to:
  /// **'Workout saved to your history'**
  String get snackbarWorkoutSavedHistory;

  /// No description provided for @snackbarPlanUpdated.
  ///
  /// In en, this message translates to:
  /// **'Plan updated'**
  String get snackbarPlanUpdated;

  /// No description provided for @snackbarPlanDeleted.
  ///
  /// In en, this message translates to:
  /// **'Plan deleted'**
  String get snackbarPlanDeleted;

  /// No description provided for @snackbarWorkoutDeleted.
  ///
  /// In en, this message translates to:
  /// **'Workout deleted'**
  String get snackbarWorkoutDeleted;

  /// No description provided for @snackbarWorkoutDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete workout'**
  String get snackbarWorkoutDeleteFailed;

  /// No description provided for @snackbarWorkoutLogged.
  ///
  /// In en, this message translates to:
  /// **'Workout logged'**
  String get snackbarWorkoutLogged;

  /// No description provided for @snackbarCalendarAdded.
  ///
  /// In en, this message translates to:
  /// **'Workout added to your calendar'**
  String get snackbarCalendarAdded;

  /// No description provided for @categorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String categorySubtitle(int count);

  /// No description provided for @catStrengthTitle.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get catStrengthTitle;

  /// No description provided for @catStrengthDesc.
  ///
  /// In en, this message translates to:
  /// **'Heavy compound lifts and accessory work to build power.'**
  String get catStrengthDesc;

  /// No description provided for @catCardioTitle.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get catCardioTitle;

  /// No description provided for @catCardioDesc.
  ///
  /// In en, this message translates to:
  /// **'Intervals and steady sessions to improve endurance.'**
  String get catCardioDesc;

  /// No description provided for @catMobilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobility'**
  String get catMobilityTitle;

  /// No description provided for @catMobilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Joint-friendly flows to improve range of motion.'**
  String get catMobilityDesc;

  /// No description provided for @catCoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get catCoreTitle;

  /// No description provided for @catCoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Bracing and anti-rotation work for a resilient midline.'**
  String get catCoreDesc;

  /// No description provided for @catRecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get catRecoveryTitle;

  /// No description provided for @catRecoveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Low intensity sessions to restore movement quality.'**
  String get catRecoveryDesc;

  /// No description provided for @catSectionExercises.
  ///
  /// In en, this message translates to:
  /// **'Available exercises'**
  String get catSectionExercises;

  /// No description provided for @catSectionExamplePlans.
  ///
  /// In en, this message translates to:
  /// **'Example plans'**
  String get catSectionExamplePlans;

  /// No description provided for @exPushUps.
  ///
  /// In en, this message translates to:
  /// **'Push-ups'**
  String get exPushUps;

  /// No description provided for @exSquats.
  ///
  /// In en, this message translates to:
  /// **'Squats'**
  String get exSquats;

  /// No description provided for @exPlank.
  ///
  /// In en, this message translates to:
  /// **'Plank'**
  String get exPlank;

  /// No description provided for @exLunges.
  ///
  /// In en, this message translates to:
  /// **'Lunges'**
  String get exLunges;

  /// No description provided for @exJumpingJacks.
  ///
  /// In en, this message translates to:
  /// **'Jumping Jacks'**
  String get exJumpingJacks;

  /// No description provided for @exPullUps.
  ///
  /// In en, this message translates to:
  /// **'Pull-ups'**
  String get exPullUps;

  /// No description provided for @exShoulderPress.
  ///
  /// In en, this message translates to:
  /// **'Shoulder Press'**
  String get exShoulderPress;

  /// No description provided for @exRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get exRunning;

  /// No description provided for @exBackSquat.
  ///
  /// In en, this message translates to:
  /// **'Back Squat'**
  String get exBackSquat;

  /// No description provided for @exBenchPress.
  ///
  /// In en, this message translates to:
  /// **'Bench Press'**
  String get exBenchPress;

  /// No description provided for @exDeadlift.
  ///
  /// In en, this message translates to:
  /// **'Deadlift'**
  String get exDeadlift;

  /// No description provided for @exRomanianDeadlift.
  ///
  /// In en, this message translates to:
  /// **'Romanian Deadlift'**
  String get exRomanianDeadlift;

  /// No description provided for @exTempoRun.
  ///
  /// In en, this message translates to:
  /// **'Tempo Run'**
  String get exTempoRun;

  /// No description provided for @exCycleIntervals.
  ///
  /// In en, this message translates to:
  /// **'Cycle Intervals'**
  String get exCycleIntervals;

  /// No description provided for @exRowingSprint.
  ///
  /// In en, this message translates to:
  /// **'Rowing Sprint'**
  String get exRowingSprint;

  /// No description provided for @exJumpRope.
  ///
  /// In en, this message translates to:
  /// **'Jump Rope'**
  String get exJumpRope;

  /// No description provided for @exThoracicRotation.
  ///
  /// In en, this message translates to:
  /// **'Thoracic Rotation'**
  String get exThoracicRotation;

  /// No description provided for @exHipCars.
  ///
  /// In en, this message translates to:
  /// **'Hip CARs'**
  String get exHipCars;

  /// No description provided for @exAnkleMobility.
  ///
  /// In en, this message translates to:
  /// **'Ankle Mobility'**
  String get exAnkleMobility;

  /// No description provided for @exShoulderDislocates.
  ///
  /// In en, this message translates to:
  /// **'Shoulder Dislocates'**
  String get exShoulderDislocates;

  /// No description provided for @exPlankVariations.
  ///
  /// In en, this message translates to:
  /// **'Plank Variations'**
  String get exPlankVariations;

  /// No description provided for @exPallofPress.
  ///
  /// In en, this message translates to:
  /// **'Pallof Press'**
  String get exPallofPress;

  /// No description provided for @exHangingLegRaise.
  ///
  /// In en, this message translates to:
  /// **'Hanging Leg Raise'**
  String get exHangingLegRaise;

  /// No description provided for @exDeadBug.
  ///
  /// In en, this message translates to:
  /// **'Dead Bug'**
  String get exDeadBug;

  /// No description provided for @exLightWalk.
  ///
  /// In en, this message translates to:
  /// **'Light Walk'**
  String get exLightWalk;

  /// No description provided for @exBreathwork.
  ///
  /// In en, this message translates to:
  /// **'Breathwork'**
  String get exBreathwork;

  /// No description provided for @exFoamRolling.
  ///
  /// In en, this message translates to:
  /// **'Foam Rolling'**
  String get exFoamRolling;

  /// No description provided for @exLegPress.
  ///
  /// In en, this message translates to:
  /// **'Leg Press'**
  String get exLegPress;

  /// No description provided for @exCalfRaises.
  ///
  /// In en, this message translates to:
  /// **'Calf Raises'**
  String get exCalfRaises;

  /// No description provided for @exBicycleCrunches.
  ///
  /// In en, this message translates to:
  /// **'Bicycle Crunches'**
  String get exBicycleCrunches;

  /// No description provided for @exRussianTwists.
  ///
  /// In en, this message translates to:
  /// **'Russian Twists'**
  String get exRussianTwists;

  /// No description provided for @exDynamicWarmUp.
  ///
  /// In en, this message translates to:
  /// **'Dynamic Warm-up'**
  String get exDynamicWarmUp;

  /// No description provided for @seedPlanPushDay.
  ///
  /// In en, this message translates to:
  /// **'Push Day'**
  String get seedPlanPushDay;

  /// No description provided for @seedPlanLowerBody.
  ///
  /// In en, this message translates to:
  /// **'Lower Body'**
  String get seedPlanLowerBody;

  /// No description provided for @seedPlanCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio Session'**
  String get seedPlanCardio;

  /// No description provided for @seedPlanCore.
  ///
  /// In en, this message translates to:
  /// **'Core Stability'**
  String get seedPlanCore;

  /// No description provided for @sampleCompletionLegDay.
  ///
  /// In en, this message translates to:
  /// **'Leg Day'**
  String get sampleCompletionLegDay;

  /// No description provided for @sampleCompletionCore.
  ///
  /// In en, this message translates to:
  /// **'Core Session'**
  String get sampleCompletionCore;

  /// No description provided for @sampleCompletionRun.
  ///
  /// In en, this message translates to:
  /// **'Morning Run'**
  String get sampleCompletionRun;

  /// No description provided for @sampleTypeLowerBody.
  ///
  /// In en, this message translates to:
  /// **'Lower body'**
  String get sampleTypeLowerBody;

  /// No description provided for @sampleTypeCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get sampleTypeCore;

  /// No description provided for @sampleTypeOutdoorCardio.
  ///
  /// In en, this message translates to:
  /// **'Outdoor cardio'**
  String get sampleTypeOutdoorCardio;

  /// No description provided for @sampleTypeCustomLog.
  ///
  /// In en, this message translates to:
  /// **'Logged session'**
  String get sampleTypeCustomLog;

  /// No description provided for @planUpperPower.
  ///
  /// In en, this message translates to:
  /// **'Upper Power'**
  String get planUpperPower;

  /// No description provided for @planLowerStrength.
  ///
  /// In en, this message translates to:
  /// **'Lower Strength'**
  String get planLowerStrength;

  /// No description provided for @planFullBodyA.
  ///
  /// In en, this message translates to:
  /// **'Full Body A'**
  String get planFullBodyA;

  /// No description provided for @planHiit20.
  ///
  /// In en, this message translates to:
  /// **'HIIT 20'**
  String get planHiit20;

  /// No description provided for @planSteadyZone2.
  ///
  /// In en, this message translates to:
  /// **'Steady Zone 2'**
  String get planSteadyZone2;

  /// No description provided for @planSprintLadder.
  ///
  /// In en, this message translates to:
  /// **'Sprint Ladder'**
  String get planSprintLadder;

  /// No description provided for @planMorningReset.
  ///
  /// In en, this message translates to:
  /// **'Morning Reset'**
  String get planMorningReset;

  /// No description provided for @planPreTrainingPrep.
  ///
  /// In en, this message translates to:
  /// **'Pre-Training Prep'**
  String get planPreTrainingPrep;

  /// No description provided for @planAbsFinishers.
  ///
  /// In en, this message translates to:
  /// **'Abs Finishers'**
  String get planAbsFinishers;

  /// No description provided for @planAntiRotation.
  ///
  /// In en, this message translates to:
  /// **'Anti-Rotation Block'**
  String get planAntiRotation;

  /// No description provided for @planDeloadWeek.
  ///
  /// In en, this message translates to:
  /// **'Deload Week'**
  String get planDeloadWeek;

  /// No description provided for @planSundayReset.
  ///
  /// In en, this message translates to:
  /// **'Sunday Reset'**
  String get planSundayReset;

  /// No description provided for @badgeFirstSession.
  ///
  /// In en, this message translates to:
  /// **'First session'**
  String get badgeFirstSession;

  /// No description provided for @badgeWeekWarrior.
  ///
  /// In en, this message translates to:
  /// **'Week warrior'**
  String get badgeWeekWarrior;

  /// No description provided for @badgeStreakStarter.
  ///
  /// In en, this message translates to:
  /// **'Streak starter'**
  String get badgeStreakStarter;

  /// No description provided for @badgeConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get badgeConsistency;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @progressWeeklyBarsDow1.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get progressWeeklyBarsDow1;

  /// No description provided for @progressWeeklyBarsDow2.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get progressWeeklyBarsDow2;

  /// No description provided for @progressWeeklyBarsDow3.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get progressWeeklyBarsDow3;

  /// No description provided for @progressWeeklyBarsDow4.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get progressWeeklyBarsDow4;

  /// No description provided for @progressWeeklyBarsDow5.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get progressWeeklyBarsDow5;

  /// No description provided for @progressWeeklyBarsDow6.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get progressWeeklyBarsDow6;

  /// No description provided for @progressWeeklyBarsDow7.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get progressWeeklyBarsDow7;

  /// No description provided for @calendarDow1.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get calendarDow1;

  /// No description provided for @calendarDow2.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get calendarDow2;

  /// No description provided for @calendarDow3.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get calendarDow3;

  /// No description provided for @calendarDow4.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get calendarDow4;

  /// No description provided for @calendarDow5.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get calendarDow5;

  /// No description provided for @calendarDow6.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get calendarDow6;

  /// No description provided for @calendarDow7.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get calendarDow7;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Territory Map'**
  String get mapTitle;

  /// No description provided for @mapLocateMe.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get mapLocateMe;

  /// No description provided for @mapLocating.
  ///
  /// In en, this message translates to:
  /// **'Finding your location...'**
  String get mapLocating;

  /// No description provided for @mapLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not find your location. Turn on GPS and try again.'**
  String get mapLocationUnavailable;

  /// No description provided for @mapLocationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Turn on Location Services to use the map.'**
  String get mapLocationServiceDisabled;

  /// No description provided for @mapLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to show your current position.'**
  String get mapLocationPermissionDenied;

  /// No description provided for @mapSimulatorLocationUnset.
  ///
  /// In en, this message translates to:
  /// **'Set a simulated location in the iOS Simulator (Features > Location) to use the map.'**
  String get mapSimulatorLocationUnset;

  /// No description provided for @mapRetryLocation.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get mapRetryLocation;

  /// No description provided for @mapLocationTimeout.
  ///
  /// In en, this message translates to:
  /// **'GPS is taking too long. Move outdoors and tap My location again.'**
  String get mapLocationTimeout;

  /// No description provided for @mapTilesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Map tiles could not load. Check your internet connection and try again.'**
  String get mapTilesUnavailable;

  /// No description provided for @mapOpenLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get mapOpenLocationSettings;

  /// No description provided for @mapModeMap.
  ///
  /// In en, this message translates to:
  /// **'Map view'**
  String get mapModeMap;

  /// No description provided for @mapModeSatellite.
  ///
  /// In en, this message translates to:
  /// **'Satellite view'**
  String get mapModeSatellite;

  /// No description provided for @mapLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get mapLeaderboard;

  /// No description provided for @mapStartCapture.
  ///
  /// In en, this message translates to:
  /// **'Start Capture'**
  String get mapStartCapture;

  /// No description provided for @mapCaptureActive.
  ///
  /// In en, this message translates to:
  /// **'Capturing route'**
  String get mapCaptureActive;

  /// No description provided for @mapElapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed'**
  String get mapElapsed;

  /// No description provided for @mapDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get mapDistance;

  /// No description provided for @mapEstimatedArea.
  ///
  /// In en, this message translates to:
  /// **'Est. area'**
  String get mapEstimatedArea;

  /// No description provided for @mapGpsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'GPS accuracy'**
  String get mapGpsAccuracy;

  /// No description provided for @mapFinishCapture.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get mapFinishCapture;

  /// No description provided for @mapPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location access needed'**
  String get mapPermissionTitle;

  /// No description provided for @mapPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to show your current position.'**
  String get mapPermissionBody;

  /// No description provided for @mapPermissionServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Turn on Location Services to use the map.'**
  String get mapPermissionServiceDisabled;

  /// No description provided for @mapAllowLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable location'**
  String get mapAllowLocation;

  /// No description provided for @mapOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get mapOpenSettings;

  /// No description provided for @mapPermissionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable location for territory capture'**
  String get mapPermissionDialogTitle;

  /// No description provided for @mapPermissionDialogBody.
  ///
  /// In en, this message translates to:
  /// **'We only use your GPS while you actively capture a route. Your path is sent to the server when you finish a capture.'**
  String get mapPermissionDialogBody;

  /// No description provided for @mapContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get mapContinue;

  /// No description provided for @mapSatelliteUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Satellite view requires an external paid map provider. Standard OpenFreeMap is available for free.'**
  String get mapSatelliteUnavailable;

  /// No description provided for @mapEmptyTerritories.
  ///
  /// In en, this message translates to:
  /// **'No territories captured yet'**
  String get mapEmptyTerritories;

  /// No description provided for @mapGpsAccuracyWarning.
  ///
  /// In en, this message translates to:
  /// **'GPS accuracy is lower than ideal. You can continue, but try moving to open sky for a cleaner capture.'**
  String get mapGpsAccuracyWarning;

  /// No description provided for @mapNameTerritoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Name your territory'**
  String get mapNameTerritoryTitle;

  /// No description provided for @mapTerritoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Territory name'**
  String get mapTerritoryNameLabel;

  /// No description provided for @mapCaptureSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Territory captured'**
  String get mapCaptureSuccessTitle;

  /// No description provided for @mapCaptureSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'{name} is now yours at {area}.'**
  String mapCaptureSuccessBody(String name, String area);

  /// No description provided for @mapDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get mapDone;

  /// No description provided for @mapValidationMinPoints.
  ///
  /// In en, this message translates to:
  /// **'Capture at least 4 valid GPS points before finishing.'**
  String get mapValidationMinPoints;

  /// No description provided for @mapValidationMinArea.
  ///
  /// In en, this message translates to:
  /// **'The captured area is too small. Walk a larger loop and try again.'**
  String get mapValidationMinArea;

  /// No description provided for @mapCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not finish the capture. Try again.'**
  String get mapCaptureFailed;

  /// No description provided for @mapOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get mapOwner;

  /// No description provided for @mapArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get mapArea;

  /// No description provided for @mapCapturedOn.
  ///
  /// In en, this message translates to:
  /// **'Captured'**
  String get mapCapturedOn;

  /// No description provided for @mapZoomToTerritory.
  ///
  /// In en, this message translates to:
  /// **'Zoom to territory'**
  String get mapZoomToTerritory;

  /// No description provided for @mapMyTerritory.
  ///
  /// In en, this message translates to:
  /// **'My territory'**
  String get mapMyTerritory;

  /// No description provided for @mapViewOwnerProfile.
  ///
  /// In en, this message translates to:
  /// **'View owner profile'**
  String get mapViewOwnerProfile;

  /// No description provided for @mapLoopClosed.
  ///
  /// In en, this message translates to:
  /// **'Loop closed — finish capture to claim this area.'**
  String get mapLoopClosed;

  /// No description provided for @mapLeaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Territory leaderboard'**
  String get mapLeaderboardTitle;

  /// No description provided for @mapLeaderboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'No leaderboard data yet.'**
  String get mapLeaderboardEmpty;

  /// No description provided for @mapLeaderboardMeta.
  ///
  /// In en, this message translates to:
  /// **'{area} · {count} territories'**
  String mapLeaderboardMeta(String area, int count);

  /// No description provided for @feedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Progress photos and training updates'**
  String get feedSubtitle;

  /// No description provided for @feedPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get feedPost;

  /// No description provided for @feedPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get feedPublish;

  /// No description provided for @feedDeletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete post'**
  String get feedDeletePost;

  /// No description provided for @feedBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get feedBlockUser;

  /// No description provided for @feedReportPost.
  ///
  /// In en, this message translates to:
  /// **'Report post'**
  String get feedReportPost;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
