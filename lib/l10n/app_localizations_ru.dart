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
  String get homeStayConsistent => 'Тренируйся регулярно и двигайся вперёд.';

  @override
  String get homeTodaysFocus => 'Фокус на сегодня';

  @override
  String get homeTrainingFocus => 'Фокус тренировок';

  @override
  String get homeSchedulePlanPrompt =>
      'Запланируй тренировку для стабильности.';

  @override
  String get homeOneWorkoutToday => 'На сегодня запланирована 1 тренировка';

  @override
  String homeNWorkoutsToday(int count) {
    return 'На сегодня запланировано тренировок: $count';
  }

  @override
  String get homeMetricPlanned => 'Запланировано';

  @override
  String get homeMetricCompleted => 'Завершено';

  @override
  String get homeMetricThisWeek => 'На этой неделе';

  @override
  String get homeNextWorkout => 'Следующая тренировка';

  @override
  String get homeNoneScheduled => 'Не запланировано';

  @override
  String get homeAddWorkoutPlan => 'Добавить план';

  @override
  String get homeNextWorkoutEmptyHint =>
      'Создай план, чтобы увидеть следующую сессию.';

  @override
  String get homeOpenDetails => 'Подробности';

  @override
  String get homeViewPlans => 'К планам';

  @override
  String get homeQuickActions => 'Быстрые действия';

  @override
  String get homeWeeklyActivity => 'Неделя';

  @override
  String get homeExerciseCategories => 'Категории упражнений';

  @override
  String get homeRecentActivity => 'Недавняя активность';

  @override
  String get homeRecentEmpty =>
      'Пока нет сессий. Завершите тренировку — она появится здесь.';

  @override
  String get homeStartWorkout => 'Начать тренировку';

  @override
  String get homeViewPlanLink => 'Смотреть план';

  @override
  String get homeStreakTitle => 'Поддержи серию';

  @override
  String get homeStreakSubtitle =>
      'Сделай тренировку сегодня, чтобы не сбиться.';

  @override
  String get homeQuickCreatePlan => 'Создать план';

  @override
  String get homeQuickLogWorkout => 'Записать тренировку';

  @override
  String get homeQuickStatistics => 'Статистика';

  @override
  String get homeNoWorkoutToday => 'На сегодня нет запланированной тренировки.';

  @override
  String get plansPageTitle => 'Планы тренировок';

  @override
  String get plansPageSubtitle => 'Планируй нагрузку и будь стабильнее.';

  @override
  String get plansCreate => 'Создать план';

  @override
  String get plansSectionYourPlans => 'Ваши планы';

  @override
  String plansTotalCount(int count) {
    return 'Всего: $count';
  }

  @override
  String get plansEmptyTitle => 'Пока нет планов';

  @override
  String get plansEmptyBody => 'Создай первый план и задай темп.';

  @override
  String get plansSnackbarCreated => 'План создан';

  @override
  String get plansSnackbarOnlyPlanned =>
      'Запустить можно только запланированную тренировку.';

  @override
  String minutesShort(int count) {
    return '$count мин';
  }

  @override
  String minutesPlanShort(int count) {
    return 'План $count мин';
  }

  @override
  String durationMinutesLabel(int count) {
    return '$count минут';
  }

  @override
  String exercisesCount(int count) {
    return '$count упражнений';
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
  String get statusCompleted => 'Выполнено';

  @override
  String get statusMissed => 'Пропущено';

  @override
  String get planCardDetails => 'Детали';

  @override
  String get planCardStart => 'Старт';

  @override
  String get planDetailTitle => 'План';

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
      'Новую сессию можно начать только из запланированной тренировки.';

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
  String get workoutNameLabel => 'Название';

  @override
  String get workoutNameHint => 'Например: Верх силовой';

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
    return 'Тренировки $date';
  }

  @override
  String get calendarEmptyDay => 'В этот день нет тренировок. Добавьте сессию.';

  @override
  String get progressTitle => 'Прогресс';

  @override
  String get progressSubtitle => 'Обзор и история';

  @override
  String get progressWeeklySessions => 'Сессий за неделю';

  @override
  String get progressActiveStreak => 'Серия дней';

  @override
  String progressStreakDays(int count) {
    return '$count дн.';
  }

  @override
  String get progressMonthlyConsistency => 'Стабильность за месяц';

  @override
  String get progressMonthlyHint => 'Условная метрика (демо)';

  @override
  String get progressWeeklyVolume => 'Нагрузка по неделям';

  @override
  String get progressAchievements => 'Достижения';

  @override
  String get progressPersonalRecords => 'Личные рекорды';

  @override
  String get progressWorkoutHistory => 'История тренировок';

  @override
  String get progressHistoryEmpty => 'Завершённых сессий пока нет.';

  @override
  String get streakDetailsTitle => 'Серия';

  @override
  String streakDayStreak(int count) {
    return 'Серия: $count дн.';
  }

  @override
  String get streakMomentum => 'Потренируйся сегодня, чтобы не потерять темп.';

  @override
  String get streakRecentDays => 'Недавние дни с тренировками';

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
  String get profileEditProfile => 'Редактировать профиль';

  @override
  String get profileAppPreferences => 'Настройки приложения';

  @override
  String get profileNotificationsSection => 'Уведомления';

  @override
  String get profileRemindersTitle => 'Напоминания о тренировках';

  @override
  String get profileRemindersSubtitle =>
      'Получайте напоминания о предстоящих сессиях';

  @override
  String get profileLogOut => 'Выйти';

  @override
  String get profileEditSheetTitle => 'Редактирование';

  @override
  String get labelName => 'Имя';

  @override
  String get labelWeightKg => 'Вес (кг)';

  @override
  String get labelHeightCm => 'Рост (см)';

  @override
  String get labelFitnessGoal => 'Цель';

  @override
  String get labelMembership => 'Подписка';

  @override
  String get validationProfileName => 'Укажите имя.';

  @override
  String get validationProfileWeight =>
      'Укажите корректный вес (точка или запятая).';

  @override
  String get validationProfileHeight =>
      'Укажите корректный рост (точка или запятая).';

  @override
  String get membershipFree => 'Free';

  @override
  String get membershipPlus => 'Plus';

  @override
  String get membershipPremium => 'Premium';

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageSubtitle => 'Язык интерфейса';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languagePickerTitle => 'Выберите язык';

  @override
  String get profilePreferencesSnack =>
      'Настройки появятся в будущем обновлении.';

  @override
  String get profileLogoutSnack => 'Выход появится после запуска аккаунтов.';

  @override
  String get profileDefaultGoal => 'Сила и функциональная подготовка';

  @override
  String get sessionActiveTitle => 'Текущая сессия';

  @override
  String get sessionCurrentExercise => 'Текущее упражнение';

  @override
  String get labelSets => 'Подходы';

  @override
  String get labelReps => 'Повторы';

  @override
  String get sessionAllExercises => 'Все упражнения';

  @override
  String get sessionCompleteExercise => 'Упражнение выполнено';

  @override
  String get sessionCompleteFinal => 'Завершить последнее';

  @override
  String get sessionFinishWorkout => 'Завершить тренировку';

  @override
  String get sessionSummaryTitle => 'Итог сессии';

  @override
  String get sessionSummaryDuration => 'Длительность';

  @override
  String get sessionSummaryCalories => 'Ккал';

  @override
  String sessionCaloriesUnit(int count) {
    return '$count ккал';
  }

  @override
  String get sessionCompletedExercises => 'Выполнено упражнений';

  @override
  String get sessionDone => 'Готово';

  @override
  String get workoutTypePlannedSession => 'По плану';

  @override
  String get logWorkoutTitle => 'Записать тренировку';

  @override
  String get logWorkoutName => 'Название';

  @override
  String get logWorkoutType => 'Тип';

  @override
  String get logWorkoutTypeDefault => 'Свой';

  @override
  String get logDuration => 'Длительность';

  @override
  String get logSave => 'Сохранить запись';

  @override
  String get validationLogName => 'Введите название.';

  @override
  String get historyWorkoutSummary => 'Итог тренировки';

  @override
  String get historyCompletedOn => 'Завершено';

  @override
  String get historyExercisesCompleted => 'Упражнения';

  @override
  String get snackbarWorkoutSavedHistory => 'Тренировка сохранена в историю';

  @override
  String get snackbarPlanUpdated => 'План обновлён';

  @override
  String get snackbarPlanDeleted => 'План удалён';

  @override
  String get snackbarWorkoutLogged => 'Запись добавлена';

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
      'Базовые движения и аксессуарная работа для силы.';

  @override
  String get catCardioTitle => 'Кардио';

  @override
  String get catCardioDesc => 'Интервалы и длительные сессии для выносливости.';

  @override
  String get catMobilityTitle => 'Мобильность';

  @override
  String get catMobilityDesc => 'Мягкие связки для амплитуды движений.';

  @override
  String get catCoreTitle => 'Кор';

  @override
  String get catCoreDesc => 'Стабилизация и антивращение для кора.';

  @override
  String get catRecoveryTitle => 'Восстановление';

  @override
  String get catRecoveryDesc => 'Лёгкие сессии для восстановления.';

  @override
  String get catSectionExercises => 'Упражнения';

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
  String get exJumpingJacks => 'Прыжки с разведением рук';

  @override
  String get exPullUps => 'Подтягивания';

  @override
  String get exShoulderPress => 'Жим стоя';

  @override
  String get exRunning => 'Бег';

  @override
  String get exBackSquat => 'Присед со штангой';

  @override
  String get exBenchPress => 'Жим лёжа';

  @override
  String get exDeadlift => 'Становая тяга';

  @override
  String get exRomanianDeadlift => 'Румынская тяга';

  @override
  String get exTempoRun => 'Темповый бег';

  @override
  String get exCycleIntervals => 'Велоинтервалы';

  @override
  String get exRowingSprint => 'Гребной спринт';

  @override
  String get exJumpRope => 'Скакалка';

  @override
  String get exThoracicRotation => 'Ротация грудного отдела';

  @override
  String get exHipCars => 'HIP CARs';

  @override
  String get exAnkleMobility => 'Мобильность голеностопа';

  @override
  String get exShoulderDislocates => 'Разведения для плеч';

  @override
  String get exPlankVariations => 'Варианты планки';

  @override
  String get exPallofPress => 'Жим Паллофа';

  @override
  String get exHangingLegRaise => 'Подъём ног в висе';

  @override
  String get exDeadBug => 'Мёртвый жук';

  @override
  String get exLightWalk => 'Лёгкая прогулка';

  @override
  String get exBreathwork => 'Дыхательные практики';

  @override
  String get exFoamRolling => 'Массаж роллом';

  @override
  String get exLegPress => 'Жим ногами';

  @override
  String get exCalfRaises => 'Подъёмы на носки';

  @override
  String get exBicycleCrunches => 'Велосипед';

  @override
  String get exRussianTwists => 'Русские скручивания';

  @override
  String get exDynamicWarmUp => 'Динамическая разминка';

  @override
  String get seedPlanPushDay => 'День отжиманий/жима';

  @override
  String get seedPlanLowerBody => 'Нижняя часть тела';

  @override
  String get seedPlanCardio => 'Кардио-сессия';

  @override
  String get seedPlanCore => 'Стабильность кора';

  @override
  String get sampleCompletionLegDay => 'День ног';

  @override
  String get sampleCompletionCore => 'Кор';

  @override
  String get sampleCompletionRun => 'Утренний бег';

  @override
  String get sampleTypeLowerBody => 'Ноги';

  @override
  String get sampleTypeCore => 'Кор';

  @override
  String get sampleTypeOutdoorCardio => 'Бег на улице';

  @override
  String get sampleTypeCustomLog => 'Ручная запись';

  @override
  String get planUpperPower => 'Верх: сила';

  @override
  String get planLowerStrength => 'Низ: сила';

  @override
  String get planFullBodyA => 'Все тело А';

  @override
  String get planHiit20 => 'ВИИТ 20';

  @override
  String get planSteadyZone2 => 'Зона 2 ровно';

  @override
  String get planSprintLadder => 'Спринт-лестница';

  @override
  String get planMorningReset => 'Утренний сброс';

  @override
  String get planPreTrainingPrep => 'Разминка перед тренировкой';

  @override
  String get planAbsFinishers => 'Финиш на пресс';

  @override
  String get planAntiRotation => 'Антивращение';

  @override
  String get planDeloadWeek => 'Неделя разгрузки';

  @override
  String get planSundayReset => 'Воскресный ресет';

  @override
  String get badgeFirstSession => 'Первая сессия';

  @override
  String get badgeWeekWarrior => 'Воин недели';

  @override
  String get badgeStreakStarter => 'Старт серии';

  @override
  String get badgeConsistency => 'Стабильность';

  @override
  String get prBackSquat => 'Присед со штангой';

  @override
  String get pr5kRun => '5 км';

  @override
  String get prPullUps => 'Подтягивания';

  @override
  String get prMockSquatValue => '110 кг';

  @override
  String get prMock5kValue => '22:40';

  @override
  String get prMockPullValue => '12 повторений';

  @override
  String get prMockSquatDate => 'апр. 2026';

  @override
  String get prMock5kDate => 'мар. 2026';

  @override
  String get prMockPullDate => 'фев. 2026';

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
