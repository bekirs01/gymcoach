// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'GymCoach';

  @override
  String get navHome => 'Главная';

  @override
  String get navPlans => 'Планы';

  @override
  String get navCalendar => 'Календарь';

  @override
  String get navFeed => 'Лента';

  @override
  String get navMap => 'Карта';

  @override
  String get navProgress => 'Прогресс';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navLeaderboard => 'Рейтинг';

  @override
  String get leaderboardSubtitle =>
      'Рейтинг по захваченной территории на карте';

  @override
  String get leaderboardYou => 'Вы';

  @override
  String get closeTooltip => 'Закрыть';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get add => 'Добавить';

  @override
  String get today => 'Сегодня';

  @override
  String get tomorrow => 'Завтра';

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
  String get activityYesterday => 'Вчера';

  @override
  String activityDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get activityToday => 'Сегодня';

  @override
  String get homeWelcomeBack => 'С возвращением';

  @override
  String get homeStayConsistent =>
      'Сохраняйте регулярность и продолжайте двигаться.';

  @override
  String get homeTodaysFocus => 'Фокус на сегодня';

  @override
  String get homeTrainingFocus => 'Тренировочный фокус';

  @override
  String get homeSchedulePlanPrompt =>
      'Запланируйте тренировку, чтобы сохранять регулярность.';

  @override
  String get homeOneWorkoutToday => 'Сегодня запланирована 1 тренировка';

  @override
  String homeNWorkoutsToday(int count) {
    return '$count workouts planned for today';
  }

  @override
  String get homeMetricPlanned => 'Запланированные тренировки';

  @override
  String get homeMetricCompleted => 'Завершенные тренировки';

  @override
  String get homeMetricThisWeek => 'На этой неделе';

  @override
  String get homeNextWorkout => 'Следующая тренировка';

  @override
  String get homeNoneScheduled => 'Ничего не запланировано';

  @override
  String get homeAddWorkoutPlan => 'Добавить план тренировки';

  @override
  String get homeNextWorkoutEmptyHint =>
      'Создайте план, чтобы увидеть здесь следующую тренировку.';

  @override
  String get homeOpenDetails => 'Открыть детали';

  @override
  String get homeViewPlans => 'Посмотреть планы';

  @override
  String get homeQuickActions => 'Быстрые действия';

  @override
  String get homeWeeklyActivity => 'Активность за неделю';

  @override
  String get homeExerciseCategories => 'Категории упражнений';

  @override
  String get homeRecentActivity => 'Недавняя активность';

  @override
  String get homeRecentEmpty =>
      'Пока нет завершенных тренировок. Завершите тренировку, чтобы увидеть ее здесь.';

  @override
  String get homeStartWorkout => 'Начать тренировку';

  @override
  String get homeViewPlanLink => 'Открыть план';

  @override
  String get homeStreakTitle => 'Сохраните серию';

  @override
  String get homeStreakSubtitle =>
      'Завершите одну тренировку сегодня, чтобы не сбить темп.';

  @override
  String get homeQuickCreatePlan => 'Создать план';

  @override
  String get homeQuickLogWorkout => 'Записать тренировку';

  @override
  String get homeQuickStatistics => 'Посмотреть статистику';

  @override
  String get homeNoWorkoutToday => 'На сегодня тренировка не запланирована.';

  @override
  String get homeScreenTitle => 'Тренировки';

  @override
  String get homeTabDashboard => 'Обзор';

  @override
  String get homeTabWorkouts => 'Тренировки';

  @override
  String get homeTabDiet => 'Diet';

  @override
  String get homeBannerCreateHint => 'See how to create new workouts';

  @override
  String get homeBannerStartHint => 'Start by adding a new training day';

  @override
  String get homeMyTraining => 'Мои тренировки';

  @override
  String homeCompletedSessions(int count) {
    return '$count завершённых сессий';
  }

  @override
  String get homeTrainingSchedule => 'Расписание';

  @override
  String get homeMore => 'Ещё';

  @override
  String get homeNoWorkoutsOnDate => 'No workouts scheduled for this date';

  @override
  String get homeFeaturedEmptyTitle => 'Нет планов';

  @override
  String get homeFeaturedEmptySubtitle => 'Создайте первую тренировку';

  @override
  String get plansPageTitle => 'Планы тренировок';

  @override
  String get plansPageSubtitle =>
      'Планируйте тренировки и сохраняйте регулярность.';

  @override
  String get plansCreate => 'Создать план';

  @override
  String get plansSectionYourPlans => 'Ваши планы';

  @override
  String plansTotalCount(int count) {
    return '$count total';
  }

  @override
  String get plansEmptyTitle => 'Планов тренировок пока нет';

  @override
  String get plansEmptyBody =>
      'Создайте первый план и начните формировать регулярность.';

  @override
  String get plansSnackbarCreated => 'План тренировки создан';

  @override
  String get plansSnackbarOnlyPlanned =>
      'Начать живую сессию можно только для запланированных тренировок.';

  @override
  String minutesShort(int count) {
    return '$count мин';
  }

  @override
  String minutesPlanShort(int count) {
    return '$count min plan';
  }

  @override
  String durationMinutesLabel(int count) {
    return '$count мин';
  }

  @override
  String get homeAddWorkout => 'Добавить тренировку';

  @override
  String get workoutListEmptyTitle => 'Список тренировок пуст';

  @override
  String get workoutListEmptyBody =>
      'Создайте тренировку с упражнениями на новый день.';

  @override
  String get workoutAddTrainingDay => 'Добавить день';

  @override
  String get workoutChooseMuscleGroup => 'Выберите группу мышц';

  @override
  String get workoutChooseExercises => 'Выберите упражнения';

  @override
  String get workoutNameYourWorkout => 'Название тренировки';

  @override
  String get workoutScheduleTitle => 'Назначить тренировку';

  @override
  String get workoutScheduleHint =>
      'Выберите дату, время и длительность тренировки.';

  @override
  String get workoutMuscleGroupHint =>
      'Выберите одну или несколько зон для тренировки.';

  @override
  String get workoutContinue => 'Продолжить';

  @override
  String workoutContinueGroups(int count) {
    return 'Продолжить ($count групп)';
  }

  @override
  String get workoutSelectExercises => 'Выберите упражнения';

  @override
  String workoutContinueExercises(int count) {
    return 'Продолжить ($count)';
  }

  @override
  String get workoutSaveWorkout => 'Сохранить тренировку';

  @override
  String workoutExerciseHintSingle(String category) {
    return 'Упражнения для «$category». Нажмите на карточку, чтобы выбрать и прочитать описание.';
  }

  @override
  String get workoutExerciseHintMulti =>
      'Выберите упражнения из выбранных групп мышц.';

  @override
  String get workoutNameHint => 'Введите название…';

  @override
  String get workoutSelected => 'Выбрано';

  @override
  String get workoutBack => 'Назад';

  @override
  String get planRepeatWorkout => 'Повторить тренировку';

  @override
  String get planCustomizeRepeat => 'Настроить и запланировать';

  @override
  String get planCompletedHint =>
      'Тренировка завершена. Повторите в другой день или измените упражнения.';

  @override
  String exercisesCount(int count) {
    return '$count упр.';
  }

  @override
  String get difficultyBeginner => 'Начальный';

  @override
  String get difficultyIntermediate => 'Средний';

  @override
  String get difficultyAdvanced => 'Продвинутый';

  @override
  String get statusPlanned => 'Запланировано';

  @override
  String get statusCompleted => 'Завершено';

  @override
  String get statusMissed => 'Пропущено';

  @override
  String get planCardDetails => 'Детали';

  @override
  String get planCardStart => 'Старт';

  @override
  String get planDetailTitle => 'Детали плана';

  @override
  String get planDetailSchedule => 'Расписание';

  @override
  String get planDetailExercises => 'Упражнения';

  @override
  String get labelDate => 'Дата';

  @override
  String get labelTime => 'Время';

  @override
  String get labelDuration => 'Длительность';

  @override
  String get beginSession => 'Начать сессию';

  @override
  String get editPlan => 'Изменить план';

  @override
  String get planSessionOnlyPlanned =>
      'Новую сессию можно начать только для запланированной тренировки.';

  @override
  String get deletePlanTitle => 'Удалить план';

  @override
  String deletePlanConfirm(String name) {
    return 'Delete \"$name\" permanently?';
  }

  @override
  String get createPlanTitle => 'Создать план';

  @override
  String get editPlanSheetTitle => 'Изменить план';

  @override
  String get savePlan => 'Сохранить план';

  @override
  String get updatePlan => 'Обновить план';

  @override
  String get workoutNameLabel => 'Название тренировки';

  @override
  String get dateLabel => 'Дата';

  @override
  String get timeLabel => 'Время';

  @override
  String get durationLabel => 'Длительность';

  @override
  String get difficultyLabel => 'Сложность';

  @override
  String get exercisesLabel => 'Упражнения';

  @override
  String exercisesSelected(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get validationWorkoutName => 'Введите название тренировки.';

  @override
  String get validationPickExercise => 'Выберите хотя бы одно упражнение.';

  @override
  String chipMinutes(int count) {
    return '$count min';
  }

  @override
  String get calendarTitle => 'Календарь';

  @override
  String calendarWorkoutsOn(String date) {
    return 'Workouts on $date';
  }

  @override
  String get calendarEmptyDay =>
      'В этот день нет тренировок. Добавьте сессию, чтобы держать график.';

  @override
  String get progressTitle => 'Прогресс';

  @override
  String get progressSubtitle => 'Обзор результатов и история';

  @override
  String get progressWeeklySessions => 'Сессии за неделю';

  @override
  String get progressActiveStreak => 'Активная серия';

  @override
  String progressStreakDays(int count) {
    return '$count дн.';
  }

  @override
  String get progressMonthlyConsistency => 'Регулярность за месяц';

  @override
  String get progressMonthlyHint =>
      'Завершенные сессии относительно планов на месяц';

  @override
  String get progressWeeklyVolume => 'Объем за неделю';

  @override
  String get progressTotalSessions => 'Всего сессий';

  @override
  String get progressWeeklyMinutes => 'Время за неделю';

  @override
  String get progressWeeklyCalories => 'Калории за неделю';

  @override
  String get progressWeekActivity => 'Калории по дням';

  @override
  String get progressWeekActivityHint => 'Сожжённые калории по дням недели';

  @override
  String get progressMonthSessions => 'Сессий в месяце';

  @override
  String get progressPlannedUpcoming => 'Предстоящие';

  @override
  String get progressAchievements => 'Достижения';

  @override
  String get progressSessionHighlights => 'Лучшие сессии';

  @override
  String get progressHighlightLongest => 'Самая длинная сессия';

  @override
  String get progressHighlightCalories => 'Максимум калорий';

  @override
  String get progressHighlightMoves => 'Больше всего упражнений';

  @override
  String get progressHighlightsEmpty =>
      'Записывайте тренировки, чтобы увидеть здесь лучшие сессии.';

  @override
  String get progressWorkoutHistory => 'История тренировок';

  @override
  String get progressHistoryEmpty =>
      'Завершенных сессий пока нет. Завершите тренировку, чтобы увидеть ее здесь.';

  @override
  String get streakDetailsTitle => 'Детали серии';

  @override
  String streakDayStreak(int count) {
    return '$count day streak';
  }

  @override
  String get streakMomentum => 'Тренируйтесь сегодня, чтобы сохранить темп.';

  @override
  String get streakRecentDays => 'Последние тренировочные дни';

  @override
  String get streakEmpty => 'Завершите тренировку, чтобы начать серию.';

  @override
  String get streakOpenProgress => 'Открыть прогресс';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileTabPhotos => 'Фото';

  @override
  String get profileTabAbout => 'О себе';

  @override
  String get profileTabFeed => 'Лента';

  @override
  String get profileTabSaved => 'Сохранённое';

  @override
  String get profileTabSettings => 'Настройки';

  @override
  String get profileEditShort => 'Изменить';

  @override
  String get profileClose => 'Закрыть';

  @override
  String get profileNoBio => 'Публичное описание пока пустое.';

  @override
  String get profileAboutEmpty =>
      'Пользователь ещё не добавил информацию о себе.';

  @override
  String get profilePhotosEmpty => 'Пользователь ещё не добавил фото.';

  @override
  String get profilePostsEmpty => 'Пользователь ещё не опубликовал посты.';

  @override
  String get profileSavedEmpty =>
      'Нет сохранённых постов. Нажмите закладку в ленте, чтобы сохранить.';

  @override
  String get profilePrivateNotes => 'Личные заметки';

  @override
  String get profilePrivateNotesEmpty =>
      'Добавьте заметки, видимые только вам.';

  @override
  String get profileFitnessSummary => 'Сводка';

  @override
  String get profileWeight => 'Вес';

  @override
  String get profileHeight => 'Рост';

  @override
  String get profileAccount => 'Аккаунт';

  @override
  String get profileEditProfile => 'Редактировать профиль';

  @override
  String get profileAppPreferences => 'Настройки приложения';

  @override
  String get profileNotificationsSection => 'Уведомления';

  @override
  String get profileRemindersTitle => 'Напоминания о тренировках';

  @override
  String get profileRemindersSubtitle => 'Уведомления о предстоящих занятиях';

  @override
  String get profileLogOut => 'Выйти';

  @override
  String get profileEditSheetTitle => 'Изменить профиль';

  @override
  String get profileAvatarButton => 'Аватар';

  @override
  String get profileCoverButton => 'Обложка';

  @override
  String get profilePublicBioLabel => 'Публичное описание';

  @override
  String get profilePublicToggleTitle => 'Публичный профиль';

  @override
  String get profilePublicToggleSubtitle => 'Виден в ленте и рейтинге';

  @override
  String get labelName => 'Имя';

  @override
  String get labelWeightKg => 'Вес (кг)';

  @override
  String get labelHeightCm => 'Рост (см)';

  @override
  String get labelFitnessGoal => 'Цель тренировок';

  @override
  String get labelMembership => 'Подписка';

  @override
  String get validationProfileName => 'Введите имя.';

  @override
  String get validationProfileWeight =>
      'Введите корректный вес (точка или запятая для дробной части).';

  @override
  String get validationProfileHeight =>
      'Введите корректный рост (точка или запятая для дробной части).';

  @override
  String get membershipFree => 'Базовый';

  @override
  String get membershipPlus => 'Плюс';

  @override
  String get membershipPremium => 'Премиум';

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageSubtitle => 'Язык интерфейса приложения';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languagePickerTitle => 'Выберите язык';

  @override
  String get profilePreferencesSnack =>
      'Настройки будут подключены в будущей версии.';

  @override
  String get profileLogoutSnack =>
      'Выход будет доступен после запуска аккаунтов.';

  @override
  String get profileDefaultGoal => 'Сила и общая подготовка';

  @override
  String get onboardingTitle => 'Добро пожаловать в GymCoach';

  @override
  String get onboardingSubtitle =>
      'Укажите имя, вес и рост — так тренировки и калории будут точнее для вас.';

  @override
  String get onboardingContinue => 'Продолжить';

  @override
  String get sessionActiveTitle => 'Активная сессия';

  @override
  String get sessionStartTitle => 'Готовы тренироваться?';

  @override
  String get sessionStartBody =>
      'Начните сессию, когда приступите к тренировке. Длительность и калории будут считаться с этого момента.';

  @override
  String get sessionStartButton => 'Начать сессию';

  @override
  String get sessionStartFirst =>
      'Сначала начните сессию, затем записывайте упражнения.';

  @override
  String get sessionTimerRunning => 'Таймер идет';

  @override
  String get sessionCurrentExercise => 'Текущее упражнение';

  @override
  String get labelSets => 'Подходы';

  @override
  String get labelReps => 'Повторения';

  @override
  String get labelRest => 'Отдых';

  @override
  String get sessionAllExercises => 'Все упражнения';

  @override
  String get sessionCompleteExercise => 'Завершить упражнение';

  @override
  String get sessionCompleteFinal => 'Завершить последнее упражнение';

  @override
  String get sessionFinishWorkout => 'Завершить тренировку';

  @override
  String get sessionSummaryTitle => 'Итоги сессии';

  @override
  String get sessionSummaryDuration => 'Длительность';

  @override
  String get sessionSummaryCalories => 'Калории';

  @override
  String sessionSummaryVolumeLine(int logKcal, int totalKcal) {
    return 'Объём упражнений: $logKcal ккал · Итого за сессию: $totalKcal ккал';
  }

  @override
  String sessionDurationSecondsOnly(int count) {
    return '$count с';
  }

  @override
  String sessionDurationMinutesOnly(int count) {
    return '$count мин';
  }

  @override
  String sessionDurationMinutesSeconds(int minutes, int seconds) {
    return '$minutes мин $seconds с';
  }

  @override
  String sessionCaloriesUnit(int count) {
    return '$count ккал';
  }

  @override
  String get sessionCaloriesEstimateNote =>
      'Калории — только приблизительная оценка, не точное значение. Учитываются вес, рост, каждое упражнение, подходы, повторения и длительность сессии.';

  @override
  String get sessionValidationSetsReps =>
      'Введите положительное число подходов и повторений.';

  @override
  String get sessionExerciseAlreadyLogged =>
      'Это упражнение уже записано. Выберите другое из списка.';

  @override
  String get sessionCameraTrackingComingSoon => 'Отслеживание камерой (скоро)';

  @override
  String get sessionCameraTracking => 'Отслеживание камерой';

  @override
  String get cameraTrackingTitle => 'Отслеживание камерой';

  @override
  String get cameraStartTracking => 'Начать отслеживание';

  @override
  String get cameraApplyCount => 'Применить счёт';

  @override
  String get cameraRepCount => 'Повторения';

  @override
  String get cameraHoldSeconds => 'Удержание (сек)';

  @override
  String get cameraBodyNotVisible =>
      'Встаньте в кадр так, чтобы тело было видно';

  @override
  String get cameraSafetyDisclaimer =>
      'Это не заменяет тренера. Остановитесь при боли.';

  @override
  String get cameraPermissionDenied =>
      'Для отслеживания нужен доступ к камере.';

  @override
  String get cameraPlatformUnsupported =>
      'Отслеживание камерой работает на Android и iOS.';

  @override
  String get cameraManualFallback =>
      'Можно считать повторения вручную на экране тренировки.';

  @override
  String get cameraUseManual => 'Считать вручную';

  @override
  String get cameraOpenSettings => 'Открыть настройки';

  @override
  String get cameraRetry => 'Попробовать снова';

  @override
  String get cameraPreviewLoading => 'Запуск камеры…';

  @override
  String get cameraTrackingLive => 'В эфире';

  @override
  String get cameraInvalidAttempts => 'Ошибки';

  @override
  String get cameraUnsupportedExercise =>
      'Отслеживание камерой для этого упражнения пока недоступно.';

  @override
  String get cameraInitFailed =>
      'Не удалось запустить камеру. Попробуйте снова или считайте вручную.';

  @override
  String get cameraFeedbackSaggingHips =>
      'Держите бёдра на линии — не провисайте';

  @override
  String get cameraFeedbackRaiseHigher => 'Поднимите руки выше до уровня плеч';

  @override
  String get cameraFeedbackIncompletePress =>
      'Нужно полное разгибание над головой';

  @override
  String get cameraFeedbackPullHigher => 'Тяните выше — подбородок над кистями';

  @override
  String get cameraFeedbackHipsSagging =>
      'Поднимите бёдра — держите тело прямо';

  @override
  String get cameraFeedbackAdjustForm => 'Скорректируйте технику и повторите';

  @override
  String cameraAppliedReps(int count) {
    return 'С камеры: $count повторений';
  }

  @override
  String cameraAppliedHold(int count) {
    return 'С камеры: удержание $count с';
  }

  @override
  String get sessionCompletedExercises => 'Завершенные упражнения';

  @override
  String get sessionDone => 'Готово';

  @override
  String get workoutTypePlannedSession => 'Запланированная сессия';

  @override
  String get logWorkoutTitle => 'Записать тренировку';

  @override
  String get logWorkoutName => 'Название тренировки';

  @override
  String get logWorkoutType => 'Тип тренировки';

  @override
  String get logWorkoutTypeDefault => 'Своя тренировка';

  @override
  String get logDuration => 'Длительность';

  @override
  String get logSave => 'Сохранить запись';

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
  String get copyPlanTitle => 'Запланировать на другой день';

  @override
  String get copyPlanConfirm => 'Запланировать';

  @override
  String get snackbarPlanCopied => 'Тренировка добавлена в календарь';

  @override
  String get sessionManageExercises => 'Manage exercises';

  @override
  String get sessionAddExercise => 'Add exercise';

  @override
  String get validationLogName => 'Введите название тренировки.';

  @override
  String get historyWorkoutSummary => 'Итоги тренировки';

  @override
  String get historyCompletedOn => 'Завершено';

  @override
  String get historyExercisesCompleted => 'Завершенные упражнения';

  @override
  String historySetsRepsDetail(int sets, int reps) {
    return '$sets подх. · $reps повт.';
  }

  @override
  String get historyCaloriesEstimateNote =>
      'Калории — только приблизительная оценка, не точное измерение.';

  @override
  String get snackbarWorkoutSavedHistory => 'Тренировка сохранена в историю';

  @override
  String get snackbarPlanUpdated => 'План обновлен';

  @override
  String get snackbarPlanDeleted => 'План удален';

  @override
  String get snackbarWorkoutLogged => 'Тренировка записана';

  @override
  String get snackbarCalendarAdded => 'Тренировка добавлена в календарь';

  @override
  String categorySubtitle(int count) {
    return '$count exercises';
  }

  @override
  String get catStrengthTitle => 'Сила';

  @override
  String get catStrengthDesc =>
      'Тяжелые базовые и вспомогательные упражнения для развития силы.';

  @override
  String get catCardioTitle => 'Кардио';

  @override
  String get catCardioDesc =>
      'Интервалы и ровные сессии для развития выносливости.';

  @override
  String get catMobilityTitle => 'Мобильность';

  @override
  String get catMobilityDesc => 'Мягкие движения для улучшения амплитуды.';

  @override
  String get catCoreTitle => 'Кор';

  @override
  String get catCoreDesc =>
      'Упражнения на стабилизацию и сопротивление вращению для крепкого корпуса.';

  @override
  String get catRecoveryTitle => 'Восстановление';

  @override
  String get catRecoveryDesc =>
      'Низкоинтенсивные сессии для восстановления качества движений.';

  @override
  String get catSectionExercises => 'Доступные упражнения';

  @override
  String get catSectionExamplePlans => 'Примеры планов';

  @override
  String get exPushUps => 'Отжимания';

  @override
  String get exSquats => 'Приседания';

  @override
  String get exPlank => 'Планка';

  @override
  String get exLunges => 'Выпады';

  @override
  String get exJumpingJacks => 'Прыжки Jumping Jack';

  @override
  String get exPullUps => 'Подтягивания';

  @override
  String get exShoulderPress => 'Жим плечами';

  @override
  String get exRunning => 'Бег';

  @override
  String get exBackSquat => 'Присед со штангой';

  @override
  String get exBenchPress => 'Жим лежа';

  @override
  String get exDeadlift => 'Становая тяга';

  @override
  String get exRomanianDeadlift => 'Румынская тяга';

  @override
  String get exTempoRun => 'Темповый бег';

  @override
  String get exCycleIntervals => 'Велоинтервалы';

  @override
  String get exRowingSprint => 'Спринт на гребле';

  @override
  String get exJumpRope => 'Скакалка';

  @override
  String get exThoracicRotation => 'Ротация грудного отдела';

  @override
  String get exHipCars => 'Hip CARs';

  @override
  String get exAnkleMobility => 'Мобильность голеностопа';

  @override
  String get exShoulderDislocates => 'Плечевая мобилизация';

  @override
  String get exPlankVariations => 'Вариации планки';

  @override
  String get exPallofPress => 'Жим Паллофа';

  @override
  String get exHangingLegRaise => 'Подъем ног в висе';

  @override
  String get exDeadBug => 'Dead Bug';

  @override
  String get exLightWalk => 'Легкая прогулка';

  @override
  String get exBreathwork => 'Дыхательная практика';

  @override
  String get exFoamRolling => 'Миофасциальный ролл';

  @override
  String get exLegPress => 'Жим ногами';

  @override
  String get exCalfRaises => 'Подъемы на носки';

  @override
  String get exBicycleCrunches => 'Велосипедные скручивания';

  @override
  String get exRussianTwists => 'Русские скручивания';

  @override
  String get exDynamicWarmUp => 'Динамическая разминка';

  @override
  String get seedPlanPushDay => 'Жимовой день';

  @override
  String get seedPlanLowerBody => 'Нижняя часть тела';

  @override
  String get seedPlanCardio => 'Кардио-сессия';

  @override
  String get seedPlanCore => 'Стабилизация корпуса';

  @override
  String get sampleCompletionLegDay => 'День ног';

  @override
  String get sampleCompletionCore => 'Сессия на кор';

  @override
  String get sampleCompletionRun => 'Утренний бег';

  @override
  String get sampleTypeLowerBody => 'Нижняя часть тела';

  @override
  String get sampleTypeCore => 'Кор';

  @override
  String get sampleTypeOutdoorCardio => 'Кардио на улице';

  @override
  String get sampleTypeCustomLog => 'Записанная сессия';

  @override
  String get planUpperPower => 'Сила верха';

  @override
  String get planLowerStrength => 'Сила низа';

  @override
  String get planFullBodyA => 'Все тело A';

  @override
  String get planHiit20 => 'HIIT 20';

  @override
  String get planSteadyZone2 => 'Ровная зона 2';

  @override
  String get planSprintLadder => 'Спринтовая лестница';

  @override
  String get planMorningReset => 'Утренний рестарт';

  @override
  String get planPreTrainingPrep => 'Подготовка к тренировке';

  @override
  String get planAbsFinishers => 'Финишеры на пресс';

  @override
  String get planAntiRotation => 'Антиротационный блок';

  @override
  String get planDeloadWeek => 'Разгрузочная неделя';

  @override
  String get planSundayReset => 'Воскресное восстановление';

  @override
  String get badgeFirstSession => 'Первая сессия';

  @override
  String get badgeWeekWarrior => 'Воин недели';

  @override
  String get badgeStreakStarter => 'Начало серии';

  @override
  String get badgeConsistency => 'Регулярность';

  @override
  String get weekdayMon => 'Пн';

  @override
  String get weekdayTue => 'Вт';

  @override
  String get weekdayWed => 'Ср';

  @override
  String get weekdayThu => 'Чт';

  @override
  String get weekdayFri => 'Пт';

  @override
  String get weekdaySat => 'Сб';

  @override
  String get weekdaySun => 'Вс';

  @override
  String get progressWeeklyBarsDow1 => 'П';

  @override
  String get progressWeeklyBarsDow2 => 'В';

  @override
  String get progressWeeklyBarsDow3 => 'С';

  @override
  String get progressWeeklyBarsDow4 => 'Ч';

  @override
  String get progressWeeklyBarsDow5 => 'П';

  @override
  String get progressWeeklyBarsDow6 => 'С';

  @override
  String get progressWeeklyBarsDow7 => 'В';

  @override
  String get calendarDow1 => 'П';

  @override
  String get calendarDow2 => 'В';

  @override
  String get calendarDow3 => 'С';

  @override
  String get calendarDow4 => 'Ч';

  @override
  String get calendarDow5 => 'П';

  @override
  String get calendarDow6 => 'С';

  @override
  String get calendarDow7 => 'В';

  @override
  String get mapTitle => 'Карта территорий';

  @override
  String get mapLocateMe => 'Моё местоположение';

  @override
  String get mapLocating => 'Определяем местоположение…';

  @override
  String get mapLocationUnavailable =>
      'Не удалось найти вас. Включите GPS и попробуйте снова.';

  @override
  String get mapLocationServiceDisabled =>
      'Геолокация выключена. Включите GPS, чтобы видеть себя на карте.';

  @override
  String get mapLocationPermissionDenied =>
      'Нужен доступ к геолокации для отображения на карте.';

  @override
  String get mapLocationTimeout =>
      'GPS отвечает слишком долго. Выйдите на открытое место и нажмите снова.';

  @override
  String get mapOpenLocationSettings => 'Открыть настройки';

  @override
  String get mapModeMap => 'Карта';

  @override
  String get mapModeSatellite => 'Спутник';

  @override
  String get mapLeaderboard => 'Рейтинг';

  @override
  String get mapStartCapture => 'Начать захват';

  @override
  String get mapCaptureActive => 'Запись маршрута';

  @override
  String get mapElapsed => 'Прошло';

  @override
  String get mapDistance => 'Дистанция';

  @override
  String get mapEstimatedArea => 'Площадь (оценка)';

  @override
  String get mapGpsAccuracy => 'Точность GPS';

  @override
  String get mapFinishCapture => 'Завершить';

  @override
  String get mapPermissionTitle => 'Нужен доступ к геолокации';

  @override
  String get mapPermissionBody =>
      'GymCoach использует геолокацию, пока приложение открыто, чтобы показывать вас на карте и записывать маршруты захвата.';

  @override
  String get mapPermissionServiceDisabled =>
      'Включите геолокацию в настройках системы для карты территорий.';

  @override
  String get mapAllowLocation => 'Разрешить геолокацию';

  @override
  String get mapOpenSettings => 'Открыть настройки';

  @override
  String get mapPermissionDialogTitle => 'Включите геолокацию для захвата';

  @override
  String get mapPermissionDialogBody =>
      'GPS используется только во время активного захвата. Маршрут отправляется на сервер после завершения.';

  @override
  String get mapContinue => 'Продолжить';

  @override
  String get mapSatelliteUnavailable =>
      'Спутниковый вид требует платного провайдера карт. Бесплатно доступна стандартная карта OpenFreeMap.';

  @override
  String get mapEmptyTerritories => 'Территории ещё не захвачены';

  @override
  String get mapGpsAccuracyWarning =>
      'Точность GPS ниже нормы. Можно продолжить, но лучше выйти под открытое небо.';

  @override
  String get mapNameTerritoryTitle => 'Назовите территорию';

  @override
  String get mapTerritoryNameLabel => 'Название территории';

  @override
  String get mapCaptureSuccessTitle => 'Территория захвачена';

  @override
  String mapCaptureSuccessBody(String name, String area) {
    return '$name is now yours at $area.';
  }

  @override
  String get mapDone => 'Готово';

  @override
  String get mapValidationMinPoints =>
      'Запишите минимум 4 точки GPS перед завершением.';

  @override
  String get mapValidationMinArea =>
      'Площадь слишком мала. Пройдите больший маршрут и попробуйте снова.';

  @override
  String get mapCaptureFailed =>
      'Не удалось завершить захват. Попробуйте снова.';

  @override
  String get mapOwner => 'Владелец';

  @override
  String get mapArea => 'Площадь';

  @override
  String get mapCapturedOn => 'Захвачено';

  @override
  String get mapZoomToTerritory => 'Показать территорию';

  @override
  String get mapMyTerritory => 'Моя территория';

  @override
  String get mapViewOwnerProfile => 'Профиль владельца';

  @override
  String get mapLoopClosed =>
      'Круг замкнут — завершите захват, чтобы закрепить территорию.';

  @override
  String get mapLeaderboardTitle => 'Рейтинг территорий';

  @override
  String get mapLeaderboardEmpty => 'Данных рейтинга пока нет.';

  @override
  String mapLeaderboardMeta(String area, int count) {
    return '$area · $count territories';
  }

  @override
  String get feedSubtitle => 'Фото прогресса и записи о тренировках';

  @override
  String get feedPost => 'Пост';

  @override
  String get feedPublish => 'Опубликовать';

  @override
  String get feedDeletePost => 'Удалить пост';

  @override
  String get feedBlockUser => 'Заблокировать';

  @override
  String get feedReportPost => 'Пожаловаться';
}
