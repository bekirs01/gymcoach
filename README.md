# GymCoach

Фитнес-приложение на Flutter с планами тренировок, подсчётом повторений через камеру, отслеживанием прогресса и GPS-картой территорий.

**Репозиторий:** [bekirs01/gymcoach](https://github.com/bekirs01/gymcoach)

## Возможности

- **Главный экран** — дневная сводка, категории и ближайшие тренировки
- **Планы тренировок** — создание, редактирование и проведение сессий
- **Камера и pose detection** — подсчёт повторений (squat, deadlift, plank и др.) через ML Kit
- **Прогресс и календарь** — завершённые тренировки, серии (streak) и статистика
- **Territory Map** — захват территорий по GPS на карте MapLibre
- **Supabase** — хранение тренировок и backend территорий (PostGIS RPC)
- **Мультиязычность** — английский и русский (EN / RU)

## Технологии

| Слой | Стек |
|------|------|
| UI | Flutter 3.x, Material 3 |
| Backend | Supabase (PostgreSQL + PostGIS) |
| Карта | MapLibre GL, Geolocator |
| Pose | Google ML Kit Pose Detection |
| Состояние | `shared_preferences`, `flutter_dotenv` |

## Требования

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ^3.11)
- Xcode (iOS) и/или Android Studio (Android)
- CocoaPods (iOS): `sudo gem install cocoapods`
- Аккаунт Supabase (для territory и удалённого хранения данных)

## Установка

```bash
git clone https://github.com/bekirs01/gymcoach.git
cd gymcoach
flutter pub get
```

### Переменные окружения

Создай файл `.env` в корне проекта (можно скопировать из `.env.example`):

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# true = только локальный mock API, false = реальный Supabase RPC
TERRITORY_USE_MOCK=false
```

> `.env` не добавляется в git. Приложение сначала загружает `.env`, если его нет — `.env.example`.

### Supabase (опционально)

SQL-файлы для territory и удалённых тренировок находятся в папке `supabase/`:

- `supabase/setup.sql` — базовая настройка
- `supabase/migrations/` — миграции
- `supabase/seed/territory_demo.sql` — демо-данные

## Запуск

```bash
# Список подключённых устройств
flutter devices

# Запуск в debug-режиме
flutter run

# На конкретном устройстве
flutter run -d <device-id>
```

### Установка на физическое iOS-устройство (release)

```bash
flutter build ios --release
flutter install --release -d <device-id>
```

При первом запуске может понадобиться доверие сертификату разработчика: **Настройки → Основные → VPN и управление устройством**.

> ML Kit pose detection работает на физическом устройстве. Для iOS-симулятора в Podfile применён workaround для ML Kit.

## Структура проекта

```
lib/
├── app/              # Тема, корневой виджет приложения
├── core/             # Supabase config, утилиты статистики
├── features/
│   ├── home/         # Главный экран
│   ├── plans/        # Планы тренировок
│   ├── workout/      # Сессия тренировки
│   ├── camera_validation/  # Камера и pose tracking
│   ├── territory_map/      # Карта и захват территорий
│   ├── progress/     # Прогресс и серии
│   ├── calendar/     # Календарь
│   └── profile/      # Профиль и язык
├── data/             # Локальное и удалённое хранение
└── l10n/             # Локализация (EN, RU)

supabase/             # SQL migration, seed, test
ios/ / android/       # Платформенные проекты
```

## Разработка

```bash
# Перегенерировать файлы локализации
flutter gen-l10n

# Анализ кода
flutter analyze

# Тесты
flutter test
```

## Лицензия

Проект для частного использования (`publish_to: none`).
