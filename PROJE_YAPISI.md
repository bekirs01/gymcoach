# GymCoach - Proje Yapısı

## Klasör Yapısı

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── providers/
│   │   ├── main_nav_provider.dart
│   │   ├── providers.dart
│   │   └── theme_provider.dart
│   ├── router/
│   │   └── app_router.dart
│   └── theme/
│       └── app_theme.dart
├── data/
│   ├── mock/
│   │   ├── mock_exercises.dart
│   │   ├── mock_guide_articles.dart
│   │   └── mock_meals.dart
│   └── repositories/
│       ├── daily_stats_repository.dart
│       ├── daily_stats_repository_impl.dart
│       ├── exercise_repository.dart
│       ├── exercise_repository_impl.dart
│       ├── guide_repository.dart
│       ├── guide_repository_impl.dart
│       ├── user_repository.dart
│       ├── user_repository_impl.dart
│       ├── workout_plan_repository.dart
│       └── workout_plan_repository_impl.dart
├── domain/
│   └── models/
│       ├── daily_stats.dart
│       ├── exercise.dart
│       ├── guide_article.dart
│       ├── meal.dart
│       ├── user_profile.dart
│       └── workout_plan.dart
└── presentation/
    ├── screens/
    │   ├── exercises/
    │   │   ├── exercise_detail_screen.dart
    │   │   └── exercises_screen.dart
    │   ├── guide/
    │   │   ├── guide_article_detail_screen.dart
    │   │   └── guide_screen.dart
    │   ├── home/
    │   │   └── home_screen.dart
    │   ├── initial_redirect.dart
    │   ├── main/
    │   │   └── main_shell.dart
    │   ├── nutrition/
    │   │   └── nutrition_screen.dart
    │   ├── onboarding/
    │   │   ├── onboarding_flow_screen.dart
    │   │   └── onboarding_state.dart
    │   ├── plan/
    │   │   ├── create_plan_screen.dart
    │   │   ├── plan_detail_screen.dart
    │   │   └── plans_screen.dart
    │   └── profile/
    │       ├── profile_screen.dart
    │       └── settings_screen.dart
    └── widgets/
        └── common/
            ├── primary_button.dart
            └── selection_card.dart
```

## Çalıştırma Komutları

```bash
# Bağımlılıkları yükle
flutter pub get

# iOS simülatörde çalıştır
flutter run -d ios

# Android emülatörde çalıştır
flutter run -d android

# macOS'ta çalıştır
flutter run -d macos

# Build (release)
flutter build apk        # Android
flutter build ios        # iOS
flutter build macos      # macOS
```

## Özellikler

- **Onboarding**: Cinsiyet, yaş/boy/kilo, hedef, aktivite seviyesi
- **Ana Sayfa**: Karşılama, günün hedefi, istatistikler, önerilen egzersizler
- **Egzersizler**: 7 kategori (Kol, Bacak, Göğüs, Sırt, Omuz, Karın, Full Body)
- **Planım**: Kendi antrenman planı oluşturma
- **Beslenme**: Hedefe göre öğün önerileri
- **Bilgi Merkezi**: Rehber makaleler
- **Profil**: Kullanıcı bilgileri, ayarlar
- **Tema**: Light/Dark mode

## Supabase Entegrasyonu İçin

Repository interface'leri hazır. Supabase eklerken:
1. `UserRepositoryImpl` → Supabase auth + profiles tablosu
2. `ExerciseRepositoryImpl` → Supabase exercises tablosu
3. `WorkoutPlanRepositoryImpl` → Supabase plans tablosu
4. `DailyStatsRepositoryImpl` → Supabase daily_stats tablosu
