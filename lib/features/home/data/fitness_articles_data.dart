import '../domain/fitness_article.dart';

abstract final class FitnessArticlesData {
  static const articles = [
    FitnessArticle(
      id: 'article_weight_loss',
      imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=900&q=80',
      english: ArticleContent(
        title: 'Healthy weight loss',
        subtitle: 'Lose fat without sacrificing muscle or energy.',
        category: 'Nutrition',
        readTime: '4 min read',
        body:
            'Focus on a moderate calorie deficit, keep protein high, and continue strength training two or three times per week. '
            'Aim for steady weekly progress instead of extreme cuts. '
            'Balanced meals, enough water, and regular movement help you lose fat while protecting muscle and daily energy.',
      ),
      russian: ArticleContent(
        title: 'Здоровое похудение',
        subtitle: 'Снижайте жир без потери мышц и энергии.',
        category: 'Питание',
        readTime: '4 мин чтения',
        body:
            'Создайте умеренный дефицит калорий, сохраняйте высокий уровень белка и продолжайте силовые тренировки два-три раза в неделю. '
            'Стремитесь к стабильному прогрессу, а не к резким ограничениям. '
            'Сбалансированное питание, вода и регулярная активность помогают терять жир, сохраняя мышцы и бодрость.',
      ),
    ),
    FitnessArticle(
      id: 'article_weekly_routine',
      imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=900&q=80',
      english: ArticleContent(
        title: 'Build your weekly routine',
        subtitle: 'A simple structure for balanced training.',
        category: 'Training',
        readTime: '5 min read',
        body:
            'Split the week into push, pull, legs, and one optional cardio or mobility day. '
            'Keep sessions focused on compound lifts, progressive overload, and enough rest between hard days. '
            'A clear weekly plan makes it easier to show up consistently and track improvement.',
      ),
      russian: ArticleContent(
        title: 'Недельный план тренировок',
        subtitle: 'Простая структура для сбалансированных занятий.',
        category: 'Тренировки',
        readTime: '5 мин чтения',
        body:
            'Разделите неделю на дни для жима, тяги, ног и один дополнительный день для кардио или мобильности. '
            'Сосредоточьтесь на базовых упражнениях, прогрессии нагрузки и достаточном отдыхе между тяжёлыми днями. '
            'Чёткий план помогает тренироваться регулярно и видеть прогресс.',
      ),
    ),
    FitnessArticle(
      id: 'article_protein',
      imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=900&q=80',
      english: ArticleContent(
        title: 'Protein basics',
        subtitle: 'How much protein you need and when to eat it.',
        category: 'Nutrition',
        readTime: '3 min read',
        body:
            'Most active people benefit from roughly 1.6 to 2.2 grams of protein per kilogram of body weight. '
            'Spread intake across meals with lean meat, fish, eggs, dairy, legumes, or protein-rich snacks. '
            'Protein supports recovery, appetite control, and muscle maintenance during training phases.',
      ),
      russian: ArticleContent(
        title: 'Основы белка',
        subtitle: 'Сколько белка нужно и когда его есть.',
        category: 'Питание',
        readTime: '3 мин чтения',
        body:
            'Большинству активных людей полезно около 1,6–2,2 г белка на килограмм веса. '
            'Распределяйте белок между приёмами пищи: нежирное мясо, рыба, яйца, молочные продукты, бобовые. '
            'Белок поддерживает восстановление, контроль аппетита и сохранение мышц во время тренировок.',
      ),
    ),
    FitnessArticle(
      id: 'article_pre_workout_food',
      imageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd84624f598?w=900&q=80',
      english: ArticleContent(
        title: 'Pre-workout food',
        subtitle: 'What to eat before training for better energy.',
        category: 'Diet',
        readTime: '4 min read',
        body:
            'Eat a balanced meal with carbs and protein about two to three hours before training. '
            'If you train sooner, choose something light like yogurt, fruit, or toast with nut butter. '
            'After training, combine protein and carbohydrates to refill energy and support recovery.',
      ),
      russian: ArticleContent(
        title: 'Еда до тренировки',
        subtitle: 'Что есть перед занятием для большей энергии.',
        category: 'Диета',
        readTime: '4 мин чтения',
        body:
            'За два-три часа до тренировки съешьте сбалансированный приём пищи с углеводами и белком. '
            'Если тренировка скоро, выберите лёгкий перекус: йогурт, фрукты или тост с ореховой пастой. '
            'После занятия сочетайте белок и углеводы, чтобы восстановить энергию и поддержать восстановление.',
      ),
    ),
    FitnessArticle(
      id: 'article_consistency',
      imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=900&q=80',
      english: ArticleContent(
        title: 'Stay consistent',
        subtitle: 'Small habits that make training easier.',
        category: 'Habits',
        readTime: '3 min read',
        body:
            'Schedule workouts like appointments, prepare gym clothes in advance, and start with realistic session lengths. '
            'Track small wins instead of waiting for perfect weeks. '
            'Consistency grows when the plan feels manageable on busy days too.',
      ),
      russian: ArticleContent(
        title: 'Будьте последовательны',
        subtitle: 'Небольшие привычки упрощают тренировки.',
        category: 'Привычки',
        readTime: '3 мин чтения',
        body:
            'Планируйте тренировки как встречи, готовьте форму заранее и начинайте с реалистичной длительности занятий. '
            'Отмечайте маленькие победы, а не ждите идеальных недель. '
            'Последовательность появляется, когда план выполним даже в загруженные дни.',
      ),
    ),
    FitnessArticle(
      id: 'article_cardio_strength',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=900&q=80',
      english: ArticleContent(
        title: 'Cardio or strength?',
        subtitle: 'Choose the right balance for fat loss.',
        category: 'Training',
        readTime: '5 min read',
        body:
            'Strength training preserves muscle and supports metabolism, while cardio improves heart health and calorie burn. '
            'For fat loss, combine both: prioritize resistance work and add moderate cardio two or three times weekly. '
            'The best plan is the one you can repeat consistently.',
      ),
      russian: ArticleContent(
        title: 'Кардио или силовые?',
        subtitle: 'Выберите правильный баланс для снижения жира.',
        category: 'Тренировки',
        readTime: '5 мин чтения',
        body:
            'Силовые тренировки сохраняют мышцы и поддерживают обмен веществ, кардио улучшает работу сердца и расход калорий. '
            'Для снижения жира сочетайте оба формата: в приоритете силовые и умеренное кардио два-три раза в неделю. '
            'Лучший план — тот, который можно повторять регулярно.',
      ),
    ),
    FitnessArticle(
      id: 'article_recovery',
      imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=900&q=80',
      english: ArticleContent(
        title: 'Sleep and recovery',
        subtitle: 'Why progress depends on rest too.',
        category: 'Recovery',
        readTime: '4 min read',
        body:
            'Muscles adapt during rest, not only during workouts. Aim for seven to nine hours of sleep when possible. '
            'Light walking, stretching, and hydration on rest days support recovery. '
            'Better sleep and recovery often improve performance more than adding extra training volume.',
      ),
      russian: ArticleContent(
        title: 'Сон и восстановление',
        subtitle: 'Почему прогресс зависит и от отдыха.',
        category: 'Восстановление',
        readTime: '4 мин чтения',
        body:
            'Мышцы адаптируются во время отдыха, а не только на тренировке. Стремитесь к семи-девяти часам сна, когда это возможно. '
            'Лёгкая прогулка, растяжка и вода в дни отдыха поддерживают восстановление. '
            'Хороший сон и отдых часто улучшают результат сильнее, чем лишний объём тренировок.',
      ),
    ),
    FitnessArticle(
      id: 'article_beginner_mistakes',
      imageUrl: 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=900&q=80',
      english: ArticleContent(
        title: 'Beginner gym mistakes',
        subtitle: 'Avoid the most common early training errors.',
        category: 'Guide',
        readTime: '4 min read',
        body:
            'Common mistakes include skipping warm-ups, adding weight too quickly, copying advanced programs, and training every day without recovery. '
            'Start with simple movements, learn proper form, and progress gradually. '
            'A sustainable beginner plan beats an aggressive one you cannot maintain.',
      ),
      russian: ArticleContent(
        title: 'Ошибки новичков в зале',
        subtitle: 'Избегайте самых частых ошибок в начале пути.',
        category: 'Гид',
        readTime: '4 мин чтения',
        body:
            'Частые ошибки: пропуск разминки, слишком быстрый рост веса, копирование продвинутых программ и ежедневные тренировки без восстановления. '
            'Начните с простых движений, отработайте технику и прогрессируйте постепенно. '
            'Устойчивый план для новичка лучше агрессивного, который невозможно поддерживать.',
      ),
    ),
  ];
}
