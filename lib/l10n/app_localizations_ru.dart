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
  String get navProgress => 'Прогресс';

  @override
  String get navProfile => 'Профиль';

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
    return 'Сегодня · $time';
  }

  @override
  String scheduleTomorrow(String time) {
    return 'Завтра · $time';
  }

  @override
  String scheduleDateTime(String date, String time) {
    return '$date · $time';
  }

  @override
  String get activityYesterday => 'Вчера';

  @override
  String activityDaysAgo(int count) {
    return '$count дн. назад';
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
    return 'Сегодня запланировано тренировок: $count';
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
    return 'Всего: $count';
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
    return 'План на $count мин';
  }

  @override
  String durationMinutesLabel(int count) {
    return '$count минут';
  }

  @override
  String exercisesCount(int count) {
    return 'Упражнений: $count';
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
    return 'Удалить «$name» навсегда?';
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
  String get workoutNameHint => 'Например: силовая на верх';

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
    return '$count мин';
  }

  @override
  String get calendarTitle => 'Календарь';

  @override
  String calendarWorkoutsOn(String date) {
    return 'Тренировки на $date';
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
    return 'Серия: $count дн.';
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
  String get profileWeight => 'Вес';

  @override
  String get profileHeight => 'Рост';

  @override
  String get profileAccount => 'Аккаунт';

  @override
  String get profileEditProfile => 'Изменить профиль';

  @override
  String get profileAppPreferences => 'Настройки приложения';

  @override
  String get profileNotificationsSection => 'Уведомления';

  @override
  String get profileRemindersTitle => 'Напоминания о тренировках';

  @override
  String get profileRemindersSubtitle =>
      'Получайте уведомления о предстоящих сессиях';

  @override
  String get profileLogOut => 'Выйти';

  @override
  String get profileEditSheetTitle => 'Изменить профиль';

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
  String sessionCaloriesUnit(int count) {
    return '$count ккал';
  }

  @override
  String get sessionCaloriesEstimateNote =>
      'Калории рассчитаны примерно на основе веса в профиле, типа упражнения, подходов, повторений и длительности сессии.';

  @override
  String get sessionValidationSetsReps =>
      'Введите положительное число подходов и повторений.';

  @override
  String get sessionExerciseAlreadyLogged =>
      'Это упражнение уже записано. Выберите другое из списка.';

  @override
  String get sessionCameraTrackingComingSoon => 'Отслеживание камерой (скоро)';

  @override
  String get sessionCameraTracking => 'Отслеживать камерой';

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
  String get cameraTrackingLive => 'Live';

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
    return 'Применено $count повторений с камеры';
  }

  @override
  String cameraAppliedHold(int count) {
    return 'Применено $count сек удержания с камеры';
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
  String get validationLogName => 'Введите название тренировки.';

  @override
  String get historyWorkoutSummary => 'Итоги тренировки';

  @override
  String get historyCompletedOn => 'Завершено';

  @override
  String get historyExercisesCompleted => 'Завершенные упражнения';

  @override
  String historySetsRepsDetail(int sets, int reps) {
    return '$sets подходов · $reps повторений';
  }

  @override
  String get historyCaloriesEstimateNote =>
      'Калории рассчитаны примерно на основе записанной сессии.';

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
    return 'Упражнений: $count';
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
}
