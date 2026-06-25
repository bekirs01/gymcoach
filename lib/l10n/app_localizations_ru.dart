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
    return 'На сегодня запланировано: $count тренировок';
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
  String get homeTabDiet => 'Питание';

  @override
  String get homeBannerCreateHint => 'Узнайте, как создавать новые тренировки';

  @override
  String get homeBannerStartHint =>
      'Начните с добавления нового тренировочного дня';

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
  String get homeArticles => 'Статьи';

  @override
  String get homeViewAll => 'Все';

  @override
  String get homeNoWorkoutsOnDate => 'На эту дату тренировки не запланированы';

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
  String get workoutNameHint => 'Например: силовая верха тела';

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
    return 'Удалить «$name» навсегда?';
  }

  @override
  String get deleteWorkoutTitle => 'Удалить тренировку?';

  @override
  String deleteWorkoutSubtitle(String name) {
    return 'Это навсегда удалит \"$name\" и её упражнения.';
  }

  @override
  String get deleteWorkoutWarning => 'Это действие нельзя отменить.';

  @override
  String get deleteWorkoutConfirm => 'Удалить тренировку';

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
  String get progressSubtitle => 'Обзор результатов и аналитика тренировок';

  @override
  String get progressStatusStrong => 'Сильно';

  @override
  String get progressStatusHot => 'Горячо';

  @override
  String progressCompletedVsPlanned(int completed, int planned) {
    return '$completed/$planned Выполнено из запланированных';
  }

  @override
  String get progressSessionsByDay => 'Сессии по дням';

  @override
  String get progressSessionsByDayHint =>
      'Завершенные тренировки по дням недели';

  @override
  String get progressPerformanceInsights => 'Аналитика результатов';

  @override
  String get progressPerformanceInsightsHint =>
      'Ключевые метрики ваших недавних сессий';

  @override
  String get progressMostTrainedGroup => 'Самая тренируемая группа';

  @override
  String get progressAvgDuration => 'Средняя длительность';

  @override
  String get progressAvgCalories => 'Средние калории сессии';

  @override
  String get progressCompletionRate => 'Процент выполнения';

  @override
  String get progressStrengthVolume => 'Сила и объем';

  @override
  String get progressSetsThisWeek => 'Подходы за неделю';

  @override
  String get progressRepsThisWeek => 'Повторы за неделю';

  @override
  String get progressEstVolume => 'Оцен. объем';

  @override
  String get progressMuscleDistribution => 'Распределение по группам';

  @override
  String get progressMuscleDistributionHint =>
      'Доля завершенных сессий по зонам';

  @override
  String get progressCompleted => 'Завершено';

  @override
  String progressVolumeK(String value) {
    return '$value тыс.';
  }

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
  String get progressHighlightLongest => 'Самая длинная тренировка';

  @override
  String get progressHighlightCalories => 'Максимум калорий';

  @override
  String get progressHighlightIntense => 'Самая интенсивная сессия';

  @override
  String get progressHighlightLatest => 'Последняя завершенная';

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
  String get streakDetailsSubtitle => 'Отслеживайте регулярность тренировок';

  @override
  String streakDayStreak(int count) {
    return 'Серия: $count дн.';
  }

  @override
  String get streakMomentum => 'Тренируйтесь сегодня, чтобы сохранить темп.';

  @override
  String get streakTrainTodayStart =>
      'Тренируйтесь сегодня, чтобы начать серию';

  @override
  String get streakBuildingMomentum => 'Вы набираете темп';

  @override
  String get streakBestStreak => 'Лучшая серия';

  @override
  String get streakThisWeekSessions => 'На этой неделе';

  @override
  String get streakLastWorkout => 'Последняя тренировка';

  @override
  String get streakActiveDays => 'Активные дни';

  @override
  String get streakWeeklyCompletion => 'Выполнение за неделю';

  @override
  String get streakNextMilestone => 'Следующая цель';

  @override
  String streakDaysShort(int count) {
    return '$count дн.';
  }

  @override
  String streakMilestoneDays(int count) {
    return 'Серия $count дн.';
  }

  @override
  String get streakThisWeekSection => 'Эта неделя';

  @override
  String streakWorkoutsThisWeek(int count) {
    return '$count тренировка';
  }

  @override
  String streakWorkoutsThisWeekPlural(int count) {
    return '$count тренировок';
  }

  @override
  String streakCompletionPercent(int percent) {
    return '$percent%';
  }

  @override
  String get streakNoLastWorkout => 'Пока нет тренировок';

  @override
  String get streakRecentDays => 'Последние тренировочные дни';

  @override
  String get streakEmpty => 'Завершите тренировку, чтобы начать серию.';

  @override
  String get streakEmptyHint =>
      'Завершите первую тренировку, чтобы увидеть прогресс здесь.';

  @override
  String get streakTipShortSession => 'Даже короткая тренировка засчитывается.';

  @override
  String get streakTipSchedule => 'Запланируйте завтрашнюю тренировку заранее.';

  @override
  String get streakTipConsistency => 'Регулярность важнее интенсивности.';

  @override
  String get streakOpenProgress => 'Открыть прогресс';

  @override
  String get streakViewProgress => 'Смотреть прогресс';

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
  String get profilePostsEmpty => 'Пока нет постов';

  @override
  String get profileSavedEmpty => 'Нет сохранённых постов';

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
  String get languageTurkish => 'Турецкий';

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
  String sessionExerciseOf(int current, int total) {
    return 'Упражнение $current из $total';
  }

  @override
  String get sessionCompleteExercise => 'Завершить упражнение';

  @override
  String get sessionCompleteFinal => 'Завершить последнее упражнение';

  @override
  String get sessionNextExercise => 'Следующее упражнение';

  @override
  String get sessionEndWorkout => 'Завершить досрочно';

  @override
  String get sessionFinishWorkout => 'Завершить тренировку';

  @override
  String get sessionFormTips => 'СОВЕТЫ ПО ТЕХНИКЕ';

  @override
  String get sessionBetweenSets => 'Между подходами';

  @override
  String get sessionChipTarget => 'Цель';

  @override
  String get sessionChipTempo => 'Темп';

  @override
  String get sessionChipEquipment => 'Инвентарь';

  @override
  String get sessionCommonMistakes => 'ЧАСТЫЕ ОШИБКИ';

  @override
  String get sessionInfoSets =>
      'Сколько подходов вы выполняете в этом упражнении.';

  @override
  String get sessionInfoReps => 'Сколько повторений в каждом подходе.';

  @override
  String get sessionInfoRest => 'Сколько отдыхаете между подходами.';

  @override
  String get sessionInfoTarget =>
      'Основная мышечная группа, которую нагружает упражнение.';

  @override
  String get sessionInfoTempo =>
      'Скорость движения. Например, 2-0-2 — 2 секунды вниз, без паузы, 2 секунды вверх.';

  @override
  String get sessionInfoEquipment => 'Что нужно для выполнения упражнения.';

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
  String get quickLogTitle => 'Записать прошлую тренировку';

  @override
  String get quickLogDate => 'Дата тренировки';

  @override
  String get quickLogYesterday => 'Вчера';

  @override
  String get quickLogDayBefore => '2 дня назад';

  @override
  String get quickLogAddExercise => 'Добавить упражнение';

  @override
  String get templateFromLabel => 'Из шаблона';

  @override
  String get templateSave => 'Сохранить как шаблон';

  @override
  String get templateSaved => 'Шаблон сохранён';

  @override
  String get copyPlanTitle => 'Запланировать на другой день';

  @override
  String get copyPlanConfirm => 'Запланировать';

  @override
  String get snackbarPlanCopied => 'Тренировка добавлена в календарь';

  @override
  String get sessionManageExercises => 'Управление упражнениями';

  @override
  String get sessionAddExercise => 'Добавить упражнение';

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
  String get snackbarWorkoutDeleted => 'Тренировка удалена';

  @override
  String get snackbarWorkoutDeleteFailed => 'Не удалось удалить тренировку';

  @override
  String get snackbarWorkoutLogged => 'Тренировка записана';

  @override
  String get snackbarCalendarAdded => 'Тренировка добавлена в календарь';

  @override
  String categorySubtitle(int count) {
    return '$count упражнений';
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
  String get exJumpingJacks => 'Прыжки с разведением рук и ног';

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
  String get exHipCars => 'Круговые движения в тазобедренном суставе';

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
  String get exDeadBug => 'Мёртвый жук';

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
  String get planFullBodyA => 'Всё тело А';

  @override
  String get planHiit20 => 'ВИИТ 20';

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
  String get badgeThreeDayStreak => '3 дня подряд';

  @override
  String get badgeFiveSessions => '5 сессий';

  @override
  String get badgeWeeklyWarrior => 'Воин недели';

  @override
  String get badgeConsistencyBadge => 'Значок регулярности';

  @override
  String get badgeMonthlyGrind => 'Месячный ритм';

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
      'Включите службы геолокации, чтобы использовать карту.';

  @override
  String get mapLocationPermissionDenied =>
      'Для отображения вашего местоположения нужен доступ к геолокации.';

  @override
  String get mapSimulatorLocationUnset =>
      'Задайте симулированное местоположение в iOS Simulator (Features > Location), чтобы использовать карту.';

  @override
  String get mapRetryLocation => 'Повторить';

  @override
  String get mapLocationTimeout =>
      'GPS отвечает слишком долго. Выйдите на открытое место и нажмите снова.';

  @override
  String get mapTilesUnavailable =>
      'Не удалось загрузить карту. Проверьте интернет и попробуйте снова.';

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
      'Для отображения вашего местоположения нужен доступ к геолокации.';

  @override
  String get mapPermissionServiceDisabled =>
      'Включите службы геолокации, чтобы использовать карту.';

  @override
  String get mapAllowLocation => 'Включить геолокацию';

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
    return '«$name» теперь ваша — площадь $area.';
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
    return '$area · $count террит.';
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

  @override
  String get chatMessagesTitle => 'Сообщения';

  @override
  String get chatSearch => 'Поиск';

  @override
  String get chatNoConversations => 'Беседы не найдены';

  @override
  String get chatStartConversation => 'Начните разговор';

  @override
  String get chatCouldNotLoadConversation => 'Не удалось загрузить чат';

  @override
  String get chatRetry => 'Повторить';

  @override
  String get chatVoiceMessage => 'Голосовое сообщение';

  @override
  String get chatPhoto => 'Фото';

  @override
  String get chatMessageDeleted => 'Сообщение удалено';

  @override
  String get chatFailedToSend => 'Не удалось отправить';

  @override
  String get chatEdited => 'изменено';

  @override
  String get chatYou => 'Вы';

  @override
  String get chatEditingMessage => 'Редактирование сообщения';

  @override
  String get chatCopy => 'Копировать';

  @override
  String get chatCopyCaption => 'Копировать подпись';

  @override
  String get chatReply => 'Ответить';

  @override
  String get chatShare => 'Поделиться';

  @override
  String get chatSave => 'Сохранить';

  @override
  String get chatDeleteMessage => 'Удалить сообщение';

  @override
  String get chatDeleteForEveryone => 'Удалить у всех';

  @override
  String get chatDeleteForMe => 'Удалить у меня';

  @override
  String get chatDeletePrompt => 'Удалить сообщение?';

  @override
  String get chatDetails => 'Подробности';

  @override
  String get chatRemove => 'Удалить';

  @override
  String get chatCopied => 'Скопировано';

  @override
  String get chatSaved => 'Сохранено';

  @override
  String get chatMessageDetails => 'Сведения о сообщении';

  @override
  String get chatDetailFrom => 'От';

  @override
  String get chatDetailSent => 'Отправлено';

  @override
  String get chatDetailType => 'Тип';

  @override
  String get chatDetailStatus => 'Статус';

  @override
  String get chatEditMessage => 'Редактировать';

  @override
  String get chatMicrophoneRequired => 'Нужен доступ к микрофону';

  @override
  String get settingsDone => 'Готово';

  @override
  String get settingsClear => 'Очистить';

  @override
  String get settingsPreferences => 'Настройки';

  @override
  String get settingsUnits => 'Единицы';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsPermissions => 'Разрешения';

  @override
  String get settingsPermissionsFooter =>
      'Статусы отражают настройки устройства и обновляются при возврате в приложение.';

  @override
  String get settingsNotificationsSection => 'Уведомления и напоминания';

  @override
  String get settingsReminderTime => 'Время напоминания';

  @override
  String get settingsReminderDays => 'Дни напоминаний';

  @override
  String get settingsPrivacySupport => 'Конфиденциальность и поддержка';

  @override
  String get settingsPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get settingsTermsOfService => 'Условия использования';

  @override
  String get settingsContactSupport => 'Связаться с поддержкой';

  @override
  String get settingsAboutApp => 'О приложении';

  @override
  String get settingsDataPermissions => 'Данные и разрешения';

  @override
  String get settingsAccountSection => 'Аккаунт';

  @override
  String get settingsSignOutSubtitle => 'Выйти с этого устройства';

  @override
  String get settingsCouldNotOpenSettings => 'Не удалось открыть настройки';

  @override
  String get settingsMeasurementUnits => 'Единицы измерения';

  @override
  String get settingsSelectDays => 'Выберите дни';

  @override
  String get settingsRecommendedSchedule => 'Рекомендуемый график';

  @override
  String get settingsPickSpecificDays => 'Выбрать конкретные дни';

  @override
  String get settingsPermissionNotifications => 'Уведомления';

  @override
  String get settingsPermissionNotificationsDesc =>
      'Напоминания о тренировках и важные обновления';

  @override
  String get settingsPermissionCamera => 'Камера';

  @override
  String get settingsPermissionCameraDesc =>
      'Сторис, посты и запись упражнений';

  @override
  String get settingsPermissionMicrophone => 'Микрофон';

  @override
  String get settingsPermissionMicrophoneDesc => 'Голосовые сообщения в чате';

  @override
  String get settingsPermissionPhotos => 'Фото';

  @override
  String get settingsPermissionPhotosDesc =>
      'Загрузка постов, сторис и медиа профиля';

  @override
  String get settingsPermissionLocation => 'Геолокация';

  @override
  String get settingsPermissionLocationDesc =>
      'Карта и захват территории в реальном времени';

  @override
  String get settingsPermissionAllowed => 'Разрешено';

  @override
  String get settingsPermissionNotAllowed => 'Не разрешено';

  @override
  String get settingsPermissionLimited => 'Ограничено';

  @override
  String get settingsPermissionRestricted => 'Запрещено';

  @override
  String get settingsChecking => 'Проверка…';

  @override
  String get unitsMetric => 'Метрическая';

  @override
  String get unitsImperial => 'Имперская';

  @override
  String get unitsMetricSubtitle => 'Килограммы, сантиметры';

  @override
  String get unitsImperialSubtitle => 'Фунты, футы и дюймы';

  @override
  String get reminderEveryDay => 'Каждый день';

  @override
  String get reminderWeekdays => 'Будни';

  @override
  String get reminderCustom => 'Своё расписание';

  @override
  String get profileBasicInfo => 'Основная информация';

  @override
  String get profileBodyMetrics => 'Параметры тела';

  @override
  String get profileGoalsSection => 'Цели';

  @override
  String get profileTargetWeight => 'Целевой вес';

  @override
  String get profileTrainingFocus => 'Тренировочный фокус';

  @override
  String get profileExperienceLevel => 'Уровень подготовки';

  @override
  String get profileActivityLevel => 'Уровень активности';

  @override
  String get profileWeeklyTarget => 'Цель на неделю';

  @override
  String get profileWeeklyWorkoutTarget => 'Тренировок в неделю';

  @override
  String get profileVisibilitySection => 'Видимость профиля';

  @override
  String get profileLocation => 'Местоположение';

  @override
  String get profileUpdatedSnack => 'Профиль обновлён';

  @override
  String get profileCouldNotSave => 'Не удалось сохранить профиль';

  @override
  String get profileAvatarUploadSoon => 'Загрузка аватара скоро будет доступна';

  @override
  String get profileCoverUploadSoon => 'Загрузка обложки скоро будет доступна';

  @override
  String get profilePrivateNotesHelper => 'Видите только вы.';

  @override
  String get profileAge => 'Возраст';

  @override
  String get profileJoined => 'Дата регистрации';

  @override
  String get profileExperience => 'Опыт';

  @override
  String get profileFavoriteTraining => 'Любимая тренировка';

  @override
  String get profileFocus => 'Фокус';

  @override
  String get profileGoal => 'Цель';

  @override
  String get goalBuildMuscle => 'Набрать мышечную массу';

  @override
  String get goalLoseFat => 'Снизить жир';

  @override
  String get goalImproveStrength => 'Улучшить силу';

  @override
  String get goalImproveEndurance => 'Улучшить выносливость';

  @override
  String get goalStayConsistent => 'Сохранять регулярность';

  @override
  String get goalMobilityRecovery => 'Мобильность и восстановление';

  @override
  String get activityLow => 'Низкая';

  @override
  String get activityModerate => 'Умеренная';

  @override
  String get activityHigh => 'Высокая';

  @override
  String get activityAthlete => 'Спортсмен';

  @override
  String weeklyTargetN(int count) {
    return '$count тренировок / нед.';
  }

  @override
  String get feedWorkoutShared => 'Тренировка отправлена';

  @override
  String get feedWorkoutAdded => 'Тренировка добавлена в ваш список';

  @override
  String get feedWorkoutAlreadyAdded => 'Эта тренировка уже в вашем списке';

  @override
  String get feedNoPostsTitle => 'Пока нет постов';

  @override
  String get feedPostOptions => 'Действия с постом';

  @override
  String get feedNewPost => 'Новый пост';

  @override
  String get feedNewPostSubtitle => 'Поделитесь фото или записью в ленте';

  @override
  String get feedNewStory => 'Новая сторис';

  @override
  String get feedNewStorySubtitle => 'Быстрая сторис на 24 часа';

  @override
  String get feedStoryTitle => 'Новая сторис';

  @override
  String get feedStoryHint => 'Выберите одно фото для сторис.';

  @override
  String get feedGallery => 'Галерея';

  @override
  String get feedCamera => 'Камера';

  @override
  String get feedShareStory => 'Опубликовать сторис';

  @override
  String get feedOpeningGallery => 'Открываем галерею…';

  @override
  String get feedTapAddPhoto => 'Нажмите, чтобы добавить фото';

  @override
  String get feedShareHint => 'Поделитесь тренировкой, прогрессом или мыслями…';

  @override
  String get feedAddComment => 'Добавить комментарий…';

  @override
  String get feedAddCaption => 'Добавить подпись…';

  @override
  String get feedReportSent => 'Жалоба отправлена';

  @override
  String get feedReportProfile => 'Пожаловаться на профиль';

  @override
  String get feedYourStory => 'Ваша сторис';

  @override
  String get chatMessageHint => 'Сообщение…';

  @override
  String get chatCouldNotDelete => 'Не удалось удалить сообщение';

  @override
  String get chatCouldNotUpdate => 'Не удалось изменить сообщение';

  @override
  String get chatMessageDeletedFallback => 'Это сообщение было удалено';

  @override
  String get chatImageWithCaption => 'Изображение с подписью';

  @override
  String get chatDetailFileType => 'Тип файла';

  @override
  String get chatDetailSize => 'Размер';

  @override
  String get chatDetailDuration => 'Длительность';

  @override
  String get chatDetailDimensions => 'Размеры';

  @override
  String get chatChooseGallery => 'Выбрать из галереи';

  @override
  String get chatTakePhoto => 'Сделать фото';

  @override
  String get chatOnline => 'В сети';

  @override
  String get mapLabelGps => 'GPS';

  @override
  String get mapLabelPoints => 'Точки';

  @override
  String shareExercisesCount(int count) {
    return '$count упражнений';
  }

  @override
  String shareMinutesCount(int count) {
    return '$count мин';
  }

  @override
  String get feedCreateTitle => 'Создать';

  @override
  String get feedCreateSubtitle => 'Выберите, чем хотите поделиться';

  @override
  String get profileOptional => 'Необязательно';

  @override
  String get profileAvatarSection => 'Аватар';

  @override
  String get feedNoPostsBody =>
      'Скоро здесь появятся новые тренировки и записи.';

  @override
  String get feedRefresh => 'Обновить';

  @override
  String get chatTypeText => 'Текст';

  @override
  String get chatStatusSending => 'Отправка';

  @override
  String get shareWorkoutTitle => 'Поделиться тренировкой';

  @override
  String get shareWorkoutPublish => 'Поделиться';

  @override
  String get shareWorkoutPublishFeed => 'Поделиться в ленте';
}
