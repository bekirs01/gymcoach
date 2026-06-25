import 'package:gym/l10n/app_localizations.dart';

abstract final class SettingsInfoContentL10n {
  static List<String> privacyPolicy(AppLocalizations l10n) {
    if (!l10n.localeName.startsWith('ru')) return _privacyEn;
    return _privacyRu;
  }

  static List<String> termsOfService(AppLocalizations l10n) {
    if (!l10n.localeName.startsWith('ru')) return _termsEn;
    return _termsRu;
  }

  static List<String> contactSupport(AppLocalizations l10n) {
    if (!l10n.localeName.startsWith('ru')) return _contactEn;
    return _contactRu;
  }

  static List<String> aboutApp(AppLocalizations l10n) {
    if (!l10n.localeName.startsWith('ru')) return _aboutEn;
    return _aboutRu;
  }

  static List<String> dataAndPermissions(AppLocalizations l10n) {
    if (!l10n.localeName.startsWith('ru')) return _dataEn;
    return _dataRu;
  }

  static const _privacyEn = [
    'GymCoach respects your privacy and processes only the data needed to deliver training, social, and map features.',
    'Workout history, profile details, and preferences are stored securely and tied to your account.',
    'We do not sell personal data. You can review permissions and notification preferences at any time in Settings.',
  ];

  static const _privacyRu = [
    'GymCoach уважает вашу конфиденциальность и обрабатывает только данные, необходимые для тренировок, социальных функций и карты.',
    'История тренировок, данные профиля и настройки хранятся безопасно и привязаны к вашему аккаунту.',
    'Мы не продаём персональные данные. Разрешения и уведомления можно изменить в любой момент в настройках.',
  ];

  static const _termsEn = [
    'By using GymCoach you agree to train responsibly and use the app in compliance with local laws.',
    'Shared workouts, stories, and messages must follow community standards and must not include harmful content.',
    'GymCoach may update these terms as features evolve. Continued use means acceptance of the latest version.',
  ];

  static const _termsRu = [
    'Используя GymCoach, вы соглашаетесь тренироваться ответственно и соблюдать местное законодательство.',
    'Общие тренировки, сторис и сообщения должны соответствовать правилам сообщества и не содержать вредоносного контента.',
    'GymCoach может обновлять условия по мере развития функций. Продолжение использования означает принятие актуальной версии.',
  ];

  static const _contactEn = [
    'Need help with workouts, account access, or permissions?',
    'Our support team can help with onboarding, profile issues, reminders, and technical troubleshooting.',
    'Email: support@gymcoach.app',
    'Typical response time: within one business day.',
  ];

  static const _contactRu = [
    'Нужна помощь с тренировками, доступом к аккаунту или разрешениями?',
    'Команда поддержки поможет с онбордингом, профилем, напоминаниями и техническими вопросами.',
    'Email: support@gymcoach.app',
    'Обычное время ответа: в течение одного рабочего дня.',
  ];

  static const _aboutEn = [
    'GymCoach helps you plan workouts, track progress, share results, and explore territory capture on the map.',
    'Version 1.0.0',
    'Built for focused training with a premium dark experience on iPhone.',
  ];

  static const _aboutRu = [
    'GymCoach помогает планировать тренировки, отслеживать прогресс, делиться результатами и захватывать территории на карте.',
    'Версия 1.0.0',
    'Создано для сфокусированных тренировок с премиальным тёмным интерфейсом.',
  ];

  static const _dataEn = [
    'Notifications power workout reminders and important account updates.',
    'Camera and microphone are used for exercise capture, stories, and voice messages.',
    'Photos access lets you upload posts, stories, and profile media.',
    'Location is used for map positioning and live territory capture while the app is open.',
    'You can review or change any permission in Settings or iOS system settings.',
  ];

  static const _dataRu = [
    'Уведомления используются для напоминаний о тренировках и важных обновлений аккаунта.',
    'Камера и микрофон нужны для записи упражнений, сторис и голосовых сообщений.',
    'Доступ к фото позволяет загружать посты, сторис и медиа профиля.',
    'Геолокация используется для карты и захвата территории, пока приложение открыто.',
    'Любое разрешение можно изменить в настройках приложения или в системных настройках iOS.',
  ];
}
