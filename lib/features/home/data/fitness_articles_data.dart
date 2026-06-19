import '../domain/fitness_article.dart';

abstract final class FitnessArticlesData {
  static const articles = [
    FitnessArticle(
      id: 'article_weight_loss',
      imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba34261?w=900&q=80',
      english: ArticleContent(
        title: 'Healthy weight loss',
        subtitle: 'Lose fat without sacrificing muscle or energy.',
        category: 'Nutrition',
        readTime: '5 min read',
        intro:
            'Sustainable fat loss is about eating slightly less than you burn while keeping your training, protein intake, and daily energy stable. '
            'Crash diets may show fast scale changes, but they often cost muscle, mood, and long-term consistency.',
        sections: [
          ArticleSection(
            title: 'Understand a calorie deficit',
            body:
                'Fat loss happens when you consume a little less energy than your body uses over time. '
                'A moderate deficit is usually easier to maintain than extreme restriction.',
            bullets: [
              'Aim for slow progress rather than rapid weekly drops.',
              'Track portions and protein first before cutting everything.',
              'Use the scale as one signal, not the only measure of success.',
            ],
          ),
          ArticleSection(
            title: 'Protect muscle with protein and strength work',
            body:
                'Muscle supports strength, posture, and metabolism. During fat loss, protein and resistance training help you keep it.',
            bullets: [
              'Include protein at most meals.',
              'Train with weights two or three times per week.',
              'Prioritize compound movements you can repeat with good form.',
            ],
          ),
          ArticleSection(
            title: 'Build habits you can repeat',
            body: 'The best fat-loss plan is the one you can follow on busy weeks.',
            bullets: [
              'Prepare simple balanced meals in advance when possible.',
              'Drink enough water and keep sleep consistent.',
              'Avoid all-or-nothing thinking after one off-plan meal.',
            ],
          ),
          ArticleSection(
            title: 'What to avoid early on',
            bullets: [
              'Very low calorie diets that leave you exhausted.',
              'Cutting protein to speed up short-term scale drops.',
              'Doing excessive cardio without recovery or strength work.',
            ],
          ),
        ],
        takeaway:
            'Lose fat slowly while keeping muscle, energy, and training quality. Consistency beats extreme shortcuts.',
      ),
      russian: ArticleContent(
        title: 'Здоровое похудение',
        subtitle: 'Снижайте жир без потери мышц и энергии.',
        category: 'Питание',
        readTime: '5 мин чтения',
        takeawayHeading: 'Главный вывод',
        intro:
            'Устойчивая потеря жира — это небольшой дефицит калорий при сохранении тренировок, белка и ежедневной энергии. '
            'Жёсткие диеты могут быстро менять вес на весах, но часто забирают мышцы, настроение и регулярность.',
        sections: [
          ArticleSection(
            title: 'Поймите дефицит калорий',
            body:
                'Жир уходит, когда вы со временем потребляете чуть меньше энергии, чем тратите. '
                'Умеренный дефицит обычно проще поддерживать, чем резкие ограничения.',
            bullets: [
              'Стремитесь к медленному прогрессу, а не к резким недельным падениям.',
              'Сначала контролируйте порции и белок, а не режьте всё сразу.',
              'Весы — лишь один из показателей, не единственный.',
            ],
          ),
          ArticleSection(
            title: 'Сохраняйте мышцы с белком и силовыми',
            body:
                'Мышцы поддерживают силу, осанку и обмен веществ. При снижении жира белок и силовые тренировки помогают их сохранить.',
            bullets: [
              'Добавляйте белок в большинство приёмов пищи.',
              'Тренируйтесь с весами два-три раза в неделю.',
              'Делайте упор на базовые движения с хорошей техникой.',
            ],
          ),
          ArticleSection(
            title: 'Формируйте повторяемые привычки',
            body: 'Лучший план похудения — тот, который выдерживает загруженные недели.',
            bullets: [
              'Готовьте простые сбалансированные блюда заранее, когда возможно.',
              'Пейте достаточно воды и высыпайтесь регулярно.',
              'Не впадайте в крайности после одного срыва в питании.',
            ],
          ),
          ArticleSection(
            title: 'Чего лучше избегать в начале',
            bullets: [
              'Очень низкокалорийных диет, после которых нет сил.',
              'Сокращения белка ради быстрого результата на весах.',
              'Избыточного кардио без восстановления и силовых.',
            ],
          ),
        ],
        takeaway:
            'Теряйте жир медленно, сохраняя мышцы, энергию и качество тренировок. Регулярность важнее экстремальных методов.',
      ),
    ),
    FitnessArticle(
      id: 'article_weekly_routine',
      imageUrl: 'https://images.unsplash.com/photo-1483721310020-03333e577078?w=900&q=80',
      english: ArticleContent(
        title: 'Build your weekly routine',
        subtitle: 'A simple structure for balanced training.',
        category: 'Training',
        readTime: '6 min read',
        intro:
            'A clear weekly plan removes guesswork and makes it easier to train consistently. '
            'You do not need a complicated split to make progress — you need structure, recovery, and repeatable sessions.',
        sections: [
          ArticleSection(
            title: 'Start with a simple weekly split',
            body: 'Most beginners do well with a balanced mix of pushing, pulling, legs, and optional cardio or mobility.',
            bullets: [
              'Push day: chest, shoulders, triceps.',
              'Pull day: back, biceps, rear shoulders.',
              'Legs day: quads, glutes, hamstrings, calves.',
              'Optional fourth day: light cardio, walking, or mobility.',
            ],
          ),
          ArticleSection(
            title: 'Keep sessions focused',
            body: 'Quality beats random volume. Choose a few compound lifts and progress them over time.',
            bullets: [
              'Warm up for five to ten minutes before heavier sets.',
              'Use two to four main exercises per session.',
              'Leave one or two reps in reserve on most working sets.',
            ],
          ),
          ArticleSection(
            title: 'Plan recovery between hard days',
            body: 'Muscles adapt when training and rest are balanced.',
            bullets: [
              'Avoid training the same muscle group hard on back-to-back days.',
              'Sleep seven to nine hours when possible.',
              'Use rest days for walking, stretching, or easy movement.',
            ],
          ),
          ArticleSection(
            title: 'Track what matters',
            bullets: [
              'Log exercises, sets, reps, and load.',
              'Review progress every few weeks, not every session.',
              'Adjust volume only when recovery and form stay solid.',
            ],
          ),
        ],
        takeaway:
            'A simple weekly structure with push, pull, legs, and recovery days helps you show up consistently and improve steadily.',
      ),
      russian: ArticleContent(
        title: 'Недельный план тренировок',
        subtitle: 'Простая структура для сбалансированных занятий.',
        category: 'Тренировки',
        readTime: '6 мин чтения',
        takeawayHeading: 'Главный вывод',
        intro:
            'Чёткий недельный план убирает хаос и упрощает регулярные тренировки. '
            'Для прогресса не нужна сложная схема — нужны структура, восстановление и повторяемые занятия.',
        sections: [
          ArticleSection(
            title: 'Начните с простого недельного деления',
            body: 'Большинству новичков подходит баланс жима, тяги, ног и опционального кардио или мобильности.',
            bullets: [
              'День жима: грудь, плечи, трицепс.',
              'День тяги: спина, бицепс, задние дельты.',
              'День ног: квадрицепсы, ягодицы, бицепс бедра, икры.',
              'Четвёртый день по желанию: лёгкое кардио, ходьба или мобильность.',
            ],
          ),
          ArticleSection(
            title: 'Держите занятия сфокусированными',
            body: 'Качество важнее случайного объёма. Выберите несколько базовых упражнений и прогрессируйте их.',
            bullets: [
              'Разминайтесь пять-десять минут перед тяжёлыми подходами.',
              'Используйте два-четыре основных упражнения за сессию.',
              'В большинстве рабочих подходов оставляйте один-два повтора в запасе.',
            ],
          ),
          ArticleSection(
            title: 'Планируйте восстановление между тяжёлыми днями',
            body: 'Мышцы адаптируются, когда тренировки и отдых сбалансированы.',
            bullets: [
              'Не нагружайте одну группу мышц тяжело два дня подряд.',
              'Спите семь-девять часов, когда это возможно.',
              'В дни отдыха выбирайте прогулки, растяжку или лёгкое движение.',
            ],
          ),
          ArticleSection(
            title: 'Отслеживайте важное',
            bullets: [
              'Записывайте упражнения, подходы, повторения и вес.',
              'Оценивайте прогресс раз в несколько недель, а не каждую тренировку.',
              'Меняйте объём только если восстановление и техника остаются стабильными.',
            ],
          ),
        ],
        takeaway:
            'Простая недельная структура с днями жима, тяги, ног и восстановления помогает тренироваться регулярно и расти стабильно.',
      ),
    ),
    FitnessArticle(
      id: 'article_protein',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a1e63c?w=900&q=80',
      english: ArticleContent(
        title: 'Protein basics',
        subtitle: 'How much protein you need and when to eat it.',
        category: 'Nutrition',
        readTime: '5 min read',
        intro:
            'Protein supports muscle repair, appetite control, and recovery between workouts. '
            'You do not need perfect timing — consistent daily intake matters more.',
        sections: [
          ArticleSection(
            title: 'Why protein matters',
            body:
                'Training creates stress on muscle tissue. Protein provides amino acids that help repair and maintain that tissue over time.',
            bullets: [
              'Supports recovery after resistance training.',
              'Helps preserve muscle during fat-loss phases.',
              'Can improve fullness between meals.',
            ],
          ),
          ArticleSection(
            title: 'How much to aim for',
            body: 'Most active people benefit from a steady daily range rather than one huge protein meal.',
            bullets: [
              'A common range is about 1.6 to 2.2 g per kg of body weight.',
              'Beginners can start near the lower end and adjust based on recovery and appetite.',
              'Spread intake across three to four meals when possible.',
            ],
          ),
          ArticleSection(
            title: 'Simple protein sources',
            bullets: [
              'Eggs, Greek yogurt, cottage cheese, and milk.',
              'Chicken, turkey, fish, and lean beef.',
              'Tofu, lentils, beans, and protein-rich snacks.',
            ],
          ),
          ArticleSection(
            title: 'Timing without overthinking',
            body: 'Total daily protein usually matters more than eating at exact minutes around training.',
            bullets: [
              'Include protein within a few hours before or after workouts.',
              'Add protein to breakfast if you often under-eat early in the day.',
              'Consistency across the week beats perfect meal timing.',
            ],
          ),
        ],
        takeaway:
            'Hit a steady daily protein target with simple whole foods. Consistency across meals matters more than perfect timing.',
      ),
      russian: ArticleContent(
        title: 'Основы белка',
        subtitle: 'Сколько белка нужно и когда его есть.',
        category: 'Питание',
        readTime: '5 мин чтения',
        takeawayHeading: 'Главный вывод',
        intro:
            'Белок поддерживает восстановление мышц, контроль аппетита и отдых между тренировками. '
            'Идеальное время приёма не так важно — важнее стабильное количество в течение дня.',
        sections: [
          ArticleSection(
            title: 'Зачем нужен белок',
            body:
                'Тренировки создают нагрузку на мышцы. Белок даёт аминокислоты, которые помогают восстанавливать и поддерживать ткани.',
            bullets: [
              'Поддерживает восстановление после силовых.',
              'Помогает сохранять мышцы при снижении жира.',
              'Может дольше сохранять чувство сытости между приёмами пищи.',
            ],
          ),
          ArticleSection(
            title: 'Сколько стремиться получать',
            body: 'Большинству активных людей полезен стабильный дневной уровень, а не один огромный приём белка.',
            bullets: [
              'Частый диапазон — около 1,6–2,2 г на кг веса тела.',
              'Новичкам можно начать с нижней границы и корректировать по восстановлению и аппетиту.',
              'Распределяйте белок на три-четыре приёма пищи, когда это возможно.',
            ],
          ),
          ArticleSection(
            title: 'Простые источники белка',
            bullets: [
              'Яйца, греческий йогурт, творог и молоко.',
              'Курица, индейка, рыба и нежирная говядина.',
              'Тофу, чечевица, бобовые и белковые перекусы.',
            ],
          ),
          ArticleSection(
            title: 'Время приёма без лишнего стресса',
            body: 'Суточное количество белка обычно важнее точных минут до или после тренировки.',
            bullets: [
              'Добавляйте белок в течение нескольких часов до или после занятия.',
              'Включайте белок в завтрак, если утром его не хватает.',
              'Регулярность в течение недели важнее идеального тайминга.',
            ],
          ),
        ],
        takeaway:
            'Достигайте стабильной дневной нормы белка из простых продуктов. Регулярность важнее идеального времени приёма.',
      ),
    ),
    FitnessArticle(
      id: 'article_pre_workout_food',
      imageUrl: 'https://images.unsplash.com/photo-1494390248081-4e521b594110?w=900&q=80',
      english: ArticleContent(
        title: 'Pre-workout food',
        subtitle: 'What to eat before training for better energy.',
        category: 'Diet',
        readTime: '5 min read',
        intro:
            'What you eat before training should support energy, comfort, and focus — not leave you bloated or crashing mid-session. '
            'The right choice depends on how much time you have before you start.',
        sections: [
          ArticleSection(
            title: 'Two to three hours before training',
            body: 'With more time, a balanced meal gives steady energy.',
            bullets: [
              'Combine carbohydrates with moderate protein.',
              'Keep fats moderate so digestion feels comfortable.',
              'Examples: rice with chicken, oats with yogurt, whole-grain toast with eggs.',
            ],
          ),
          ArticleSection(
            title: 'Thirty to sixty minutes before training',
            body: 'Choose lighter options that digest quickly.',
            bullets: [
              'Banana, rice cakes, or a small bowl of oats.',
              'Low-fat yogurt or a protein shake with fruit.',
              'A little coffee can help focus if you tolerate caffeine well.',
            ],
          ),
          ArticleSection(
            title: 'If you train early in the morning',
            body: 'You do not always need a full meal, but some fuel often improves performance.',
            bullets: [
              'A banana or small snack may be enough for shorter sessions.',
              'Hydrate before you start.',
              'Save larger meals for after training if appetite is low early.',
            ],
          ),
          ArticleSection(
            title: 'After training',
            body: 'Post-workout nutrition helps refill energy and support recovery.',
            bullets: [
              'Pair protein with carbohydrates within a few hours.',
              'Rehydrate and include electrolytes if you sweat heavily.',
              'Keep choices simple and repeatable.',
            ],
          ),
        ],
        takeaway:
            'Match pre-workout food to your timing: balanced meals earlier, lighter carbs and protein closer to training.',
      ),
      russian: ArticleContent(
        title: 'Еда до тренировки',
        subtitle: 'Что есть перед занятием для большей энергии.',
        category: 'Диета',
        readTime: '5 мин чтения',
        takeawayHeading: 'Главный вывод',
        intro:
            'Питание перед тренировкой должно давать энергию, комфорт и концентрацию — без тяжести или спада сил посередине занятия. '
            'Выбор зависит от того, сколько времени осталось до начала.',
        sections: [
          ArticleSection(
            title: 'За два-три часа до тренировки',
            body: 'При большем запасе времени сбалансированный приём пищи даёт ровную энергию.',
            bullets: [
              'Сочетайте углеводы с умеренным количеством белка.',
              'Держите жиры в разумных пределах для комфортного переваривания.',
              'Примеры: рис с курицей, овсянка с йогуртом, цельнозерновой тост с яйцами.',
            ],
          ),
          ArticleSection(
            title: 'За тридцать-шестьдесят минут',
            body: 'Выбирайте лёгкие продукты, которые перевариваются быстрее.',
            bullets: [
              'Банан, рисовые хлебцы или небольшая порция овсянки.',
              'Нежирный йогурт или протеиновый коктейль с фруктами.',
              'Немного кофе может помочь с концентрацией, если кофеин вам подходит.',
            ],
          ),
          ArticleSection(
            title: 'Если тренируетесь рано утром',
            body: 'Полноценный завтрак не всегда обязателен, но немного еды часто улучшает работоспособность.',
            bullets: [
              'Банана или лёгкого перекуса может хватить для короткой сессии.',
              'Выпейте воду до начала.',
              'Более плотный приём пищи оставьте на после тренировки, если утром мало аппетита.',
            ],
          ),
          ArticleSection(
            title: 'После тренировки',
            body: 'Питание после занятия помогает восполнить энергию и поддержать восстановление.',
            bullets: [
              'Сочетайте белок и углеводы в течение нескольких часов.',
              'Пейте воду и добавляйте электролиты при сильном потоотделении.',
              'Делайте выбор простым и повторяемым.',
            ],
          ),
        ],
        takeaway:
            'Подбирайте еду под время до тренировки: сбалансированные приёмы заранее, лёгкие углеводы и белок ближе к занятию.',
      ),
    ),
    FitnessArticle(
      id: 'article_consistency',
      imageUrl: 'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=900&q=80',
      english: ArticleContent(
        title: 'Stay consistent',
        subtitle: 'Small habits that make training easier.',
        category: 'Habits',
        readTime: '4 min read',
        intro:
            'Motivation comes and goes, but systems keep you moving. '
            'Consistency grows when training feels planned, realistic, and easy to start on ordinary days.',
        sections: [
          ArticleSection(
            title: 'Reduce friction before each session',
            body: 'The easier it is to begin, the more likely you are to finish.',
            bullets: [
              'Prepare gym clothes, shoes, and water the night before.',
              'Choose a default workout time that fits your week.',
              'Keep your plan visible in a calendar or training log.',
            ],
          ),
          ArticleSection(
            title: 'Use realistic session lengths',
            body: 'A shorter completed workout beats a perfect plan you skip.',
            bullets: [
              'Start with thirty to forty-five minute sessions if time is tight.',
              'Focus on a few key exercises instead of doing everything.',
              'Add volume only when attendance is already steady.',
            ],
          ),
          ArticleSection(
            title: 'Track small wins',
            bullets: [
              'Count completed sessions, not only personal records.',
              'Celebrate showing up after stressful days.',
              'Review your week briefly and adjust one thing at a time.',
            ],
          ),
          ArticleSection(
            title: 'Recover from missed days without guilt',
            body: 'One missed workout does not erase progress.',
            bullets: [
              'Return with your next planned session instead of doubling volume.',
              'Keep identity-based habits: you are someone who trains regularly.',
              'Protect sleep and nutrition so busy weeks stay manageable.',
            ],
          ),
        ],
        takeaway:
            'Make training easy to start, keep sessions realistic, and return quickly after missed days. Small repeated actions build real consistency.',
      ),
      russian: ArticleContent(
        title: 'Будьте последовательны',
        subtitle: 'Небольшие привычки упрощают тренировки.',
        category: 'Привычки',
        readTime: '4 мин чтения',
        takeawayHeading: 'Главный вывод',
        intro:
            'Мотивация приходит и уходит, а системы помогают двигаться дальше. '
            'Последовательность растёт, когда тренировки запланированы, реалистичны и легко начинаются в обычные дни.',
        sections: [
          ArticleSection(
            title: 'Убирайте лишние препятствия перед занятием',
            body: 'Чем проще начать, тем выше шанс дойти до конца.',
            bullets: [
              'Готовьте форму, обувь и воду с вечера.',
              'Выберите удобное постоянное время для тренировок.',
              'Держите план на виду в календаре или дневнике.',
            ],
          ),
          ArticleSection(
            title: 'Выбирайте реалистичную длительность',
            body: 'Короткая завершённая тренировка лучше идеального плана, который вы пропустили.',
            bullets: [
              'Начните с тридцати-сорока пяти минут, если мало времени.',
              'Сосредоточьтесь на ключевых упражнениях, а не на всём сразу.',
              'Добавляйте объём только когда регулярность уже стабильна.',
            ],
          ),
          ArticleSection(
            title: 'Отмечайте маленькие победы',
            bullets: [
              'Считайте завершённые занятия, а не только рекорды.',
              'Цените то, что пришли после тяжёлых дней.',
              'Кратко подводите итог недели и меняйте по одному пункту.',
            ],
          ),
          ArticleSection(
            title: 'Возвращайтесь после пропусков без чувства вины',
            body: 'Одна пропущенная тренировка не стирает прогресс.',
            bullets: [
              'Возвращайтесь к следующему запланированному занятию, а не удваивайте нагрузку.',
              'Поддерживайте привычку: вы человек, который тренируется регулярно.',
              'Берегите сон и питание, чтобы загруженные недели оставались посильными.',
            ],
          ),
        ],
        takeaway:
            'Упростите старт, держите занятия реалистичными и быстро возвращайтесь после пропусков. Маленькие повторяемые действия создают настоящую регулярность.',
      ),
    ),
    FitnessArticle(
      id: 'article_cardio_strength',
      imageUrl: 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?w=900&q=80',
      english: ArticleContent(
        title: 'Cardio or strength?',
        subtitle: 'Choose the right balance for fat loss.',
        category: 'Training',
        readTime: '6 min read',
        intro:
            'Cardio and strength training support different goals, and both can help fat loss when used wisely. '
            'The best approach depends on your schedule, recovery, and what you can repeat every week.',
        sections: [
          ArticleSection(
            title: 'What strength training gives you',
            body: 'Resistance work helps preserve muscle and supports long-term performance.',
            bullets: [
              'Improves strength, joint stability, and movement quality.',
              'Helps maintain muscle during a calorie deficit.',
              'Raises daily energy expenditure through muscle and training volume.',
            ],
          ),
          ArticleSection(
            title: 'What cardio gives you',
            body: 'Cardio mainly improves heart health and adds extra calorie burn.',
            bullets: [
              'Supports endurance and work capacity.',
              'Can increase weekly energy output without heavy lifting every day.',
              'Low-intensity options like walking are easy to recover from.',
            ],
          ),
          ArticleSection(
            title: 'A practical fat-loss balance',
            body: 'For most people, strength should stay the foundation.',
            bullets: [
              'Train with weights two to four times per week.',
              'Add two or three moderate cardio sessions if recovery allows.',
              'Use walking on rest days to stay active without burnout.',
            ],
          ),
          ArticleSection(
            title: 'Avoid common mistakes',
            bullets: [
              'Replacing all strength work with long daily cardio.',
              'Doing high-intensity cardio before heavy leg sessions without fuel.',
              'Changing the plan every week instead of repeating what works.',
            ],
          ),
        ],
        takeaway:
            'Prioritize strength training for muscle and metabolism, then add moderate cardio you can sustain. Balance beats extremes.',
      ),
      russian: ArticleContent(
        title: 'Кардио или силовые?',
        subtitle: 'Выберите правильный баланс для снижения жира.',
        category: 'Тренировки',
        readTime: '6 мин чтения',
        takeawayHeading: 'Главный вывод',
        intro:
            'Кардио и силовые решают разные задачи, и оба формата могут помочь при снижении жира, если использовать их разумно. '
            'Лучший подход зависит от расписания, восстановления и того, что вы можете повторять каждую неделю.',
        sections: [
          ArticleSection(
            title: 'Что дают силовые',
            body: 'Работа с отягощениями помогает сохранять мышцы и поддерживать долгосрочный прогресс.',
            bullets: [
              'Улучшают силу, стабильность суставов и качество движений.',
              'Помогают удерживать мышцы при дефиците калорий.',
              'Повышают расход энергии за счёт мышечной массы и объёма тренировок.',
            ],
          ),
          ArticleSection(
            title: 'Что даёт кардио',
            body: 'Кардио в основном улучшает работу сердца и добавляет дополнительный расход калорий.',
            bullets: [
              'Поддерживает выносливость и работоспособность.',
              'Может увеличить недельный расход энергии без ежедневных тяжёлых подходов.',
              'Низкоинтенсивные варианты вроде ходьбы легко переносятся.',
            ],
          ),
          ArticleSection(
            title: 'Практичный баланс для снижения жира',
            body: 'Для большинства людей силовые остаются основой.',
            bullets: [
              'Тренируйтесь с весами два-четыре раза в неделю.',
              'Добавляйте два-три умеренных кардио-сессии, если восстановление позволяет.',
              'Используйте ходьбу в дни отдыха, чтобы оставаться активным без перегруза.',
            ],
          ),
          ArticleSection(
            title: 'Избегайте частых ошибок',
            bullets: [
              'Полной замены силовых длинным ежедневным кардио.',
              'Интенсивного кардио перед тяжёлой тренировкой ног без достаточной еды.',
              'Смены плана каждую неделю вместо повторения работающей схемы.',
            ],
          ),
        ],
        takeaway:
            'Делайте силовые основой для мышц и обмена веществ, затем добавляйте умеренное кардио, которое можете поддерживать. Баланс лучше крайностей.',
      ),
    ),
    FitnessArticle(
      id: 'article_recovery',
      imageUrl: 'https://images.unsplash.com/photo-154178324583-b3efe43eae27?w=900&q=80',
      english: ArticleContent(
        title: 'Sleep and recovery',
        subtitle: 'Why progress depends on rest too.',
        category: 'Recovery',
        readTime: '5 min read',
        intro:
            'Training provides the stimulus, but adaptation happens during recovery. '
            'Sleep, hydration, and easy movement between hard sessions often determine how well you progress.',
        sections: [
          ArticleSection(
            title: 'Why recovery matters',
            body: 'Muscles repair, energy systems refill, and coordination improves when you rest well.',
            bullets: [
              'Soreness is normal, but persistent fatigue is a signal to ease up.',
              'Rest days are part of training, not a break from progress.',
              'Better recovery usually improves strength and technique.',
            ],
          ),
          ArticleSection(
            title: 'Sleep basics',
            body: 'Sleep is one of the highest-impact recovery tools available.',
            bullets: [
              'Aim for seven to nine hours when your schedule allows.',
              'Keep a consistent bedtime and wake time.',
              'Limit late caffeine and bright screens if sleep quality is poor.',
            ],
          ),
          ArticleSection(
            title: 'Active recovery ideas',
            bullets: [
              'Ten to twenty minutes of light walking.',
              'Gentle mobility for hips, shoulders, and spine.',
              'Easy stretching after long sitting or heavy lower-body days.',
            ],
          ),
          ArticleSection(
            title: 'Hydration and daily habits',
            body: 'Small daily choices support tissue repair and training readiness.',
            bullets: [
              'Drink water regularly through the day.',
              'Eat enough total calories and protein to support your training load.',
              'Reduce back-to-back hard sessions when performance drops.',
            ],
          ),
        ],
        takeaway:
            'Treat sleep, hydration, and light recovery work as part of your training plan. Progress happens when you train hard and recover well.',
      ),
      russian: ArticleContent(
        title: 'Сон и восстановление',
        subtitle: 'Почему прогресс зависит и от отдыха.',
        category: 'Восстановление',
        readTime: '5 мин чтения',
        takeawayHeading: 'Главный вывод',
        intro:
            'Тренировка даёт стимул, а адаптация происходит во время восстановления. '
            'Сон, вода и лёгкое движение между тяжёлыми сессиями часто определяют, насколько хорошо вы прогрессируете.',
        sections: [
          ArticleSection(
            title: 'Почему важно восстановление',
            body: 'Мышцы восстанавливаются, энергия возвращается, а координация улучшается, когда вы хорошо отдыхаете.',
            bullets: [
              'Умеренная крепатура нормальна, но постоянная усталость — сигнал снизить нагрузку.',
              'Дни отдыха — часть тренировочного процесса, а не пауза в прогрессе.',
              'Лучшее восстановление обычно улучшает силу и технику.',
            ],
          ),
          ArticleSection(
            title: 'Основы сна',
            body: 'Сон — один из самых эффективных инструментов восстановления.',
            bullets: [
              'Стремитесь к семи-девяти часам, когда позволяет расписание.',
              'Ложитесь и вставайте в одно и то же время.',
              'Ограничьте поздний кофеин и яркие экраны, если сон неглубокий.',
            ],
          ),
          ArticleSection(
            title: 'Идеи для активного восстановления',
            bullets: [
              'Десять-двадцать минут лёгкой ходьбы.',
              'Мягкая мобильность для бёдер, плеч и позвоночника.',
              'Лёгкая растяжка после долгого сидения или тяжёлого дня на ноги.',
            ],
          ),
          ArticleSection(
            title: 'Гидратация и ежедневные привычки',
            body: 'Небольшие ежедневные решения поддерживают восстановление тканей и готовность к тренировкам.',
            bullets: [
              'Пейте воду регулярно в течение дня.',
              'Получайте достаточно калорий и белка под вашу нагрузку.',
              'Сокращайте тяжёлые сессии подряд, если падает результат.',
            ],
          ),
        ],
        takeaway:
            'Считайте сон, воду и лёгкое восстановление частью плана тренировок. Прогресс приходит, когда вы тренируетесь усердно и хорошо отдыхаете.',
      ),
    ),
    FitnessArticle(
      id: 'article_beginner_mistakes',
      imageUrl: 'https://images.unsplash.com/photo-1581009146145-b5ef050c149a?w=900&q=80',
      english: ArticleContent(
        title: 'Beginner gym mistakes',
        subtitle: 'Avoid the most common early training errors.',
        category: 'Guide',
        readTime: '5 min read',
        intro:
            'Early gym progress is less about perfect programming and more about learning safe movement, building habits, and recovering well. '
            'Avoiding a few common mistakes can save months of frustration.',
        sections: [
          ArticleSection(
            title: 'Skipping warm-ups and technique',
            body: 'Rushing into heavy work increases injury risk and poor movement patterns.',
            bullets: [
              'Spend five to ten minutes raising body temperature and moving joints.',
              'Practice lighter sets before working weight.',
              'Ask for guidance on form for squats, hinges, pushes, and pulls.',
            ],
          ),
          ArticleSection(
            title: 'Adding weight too quickly',
            body: 'Progress should be steady, not dramatic every session.',
            bullets: [
              'Increase load only when reps look controlled.',
              'Use small jumps on upper-body and lower-body lifts.',
              'Track sets so ego does not drive every decision.',
            ],
          ),
          ArticleSection(
            title: 'Copying advanced programs too early',
            bullets: [
              'High volume splits are hard to recover from as a beginner.',
              'Master basic full-body or upper-lower routines first.',
              'Add complexity only when attendance and form are consistent.',
            ],
          ),
          ArticleSection(
            title: 'Training hard every day',
            body: 'More is not always better when recovery is limited.',
            bullets: [
              'Schedule at least one to two lighter or rest days per week.',
              'Watch for poor sleep, sore joints, and falling performance.',
              'Consistency over months beats intensity for a few weeks.',
            ],
          ),
        ],
        takeaway:
            'Warm up, learn form, progress gradually, and recover between sessions. A sustainable beginner plan beats an aggressive one you cannot maintain.',
      ),
      russian: ArticleContent(
        title: 'Ошибки новичков в зале',
        subtitle: 'Избегайте самых частых ошибок в начале пути.',
        category: 'Гид',
        readTime: '5 мин чтения',
        takeawayHeading: 'Главный вывод',
        intro:
            'Ранний прогресс в зале зависит не от идеальной программы, а от безопасной техники, привычек и восстановления. '
            'Избегая нескольких типичных ошибок, можно сэкономить месяцы разочарований.',
        sections: [
          ArticleSection(
            title: 'Пропуск разминки и техники',
            body: 'Слишком быстрый переход к тяжёлым весам повышает риск травм и закрепляет плохие паттерны движения.',
            bullets: [
              'Уделяйте пять-десять минут разогреву и движению суставов.',
              'Делайте лёгкие подходы перед рабочим весом.',
              'Просите подсказки по технике приседов, тяг, жимов и тяг к себе.',
            ],
          ),
          ArticleSection(
            title: 'Слишком быстрый рост весов',
            body: 'Прогресс должен быть стабильным, а не драматичным на каждой тренировке.',
            bullets: [
              'Добавляйте вес только когда повторения выглядят контролируемыми.',
              'Используйте небольшие шаги в упражнениях на верх и низ тела.',
              'Ведите записи, чтобы решения не диктовало самолюбие.',
            ],
          ),
          ArticleSection(
            title: 'Копирование продвинутых программ слишком рано',
            bullets: [
              'Объёмные сплиты тяжело восстанавливать новичку.',
              'Сначала освойте простые full-body или upper-lower схемы.',
              'Усложняйте план только при стабильной регулярности и технике.',
            ],
          ),
          ArticleSection(
            title: 'Тренировки на пределе каждый день',
            body: 'Больше — не всегда лучше, когда восстановление ограничено.',
            bullets: [
              'Планируйте хотя бы один-два лёгких или полных дня отдыха в неделю.',
              'Следите за плохим сном, болью в суставах и падением результата.',
              'Регулярность месяцами важнее интенсивности на пару недель.',
            ],
          ),
        ],
        takeaway:
            'Разминайтесь, учите технику, прогрессируйте постепенно и восстанавливайтесь между занятиями. Устойчивый план для новичка лучше агрессивного, который невозможно поддерживать.',
      ),
    ),
  ];
}
