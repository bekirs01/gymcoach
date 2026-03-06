import '../../domain/models/meal.dart';

/// Mock данные питания по целям
List<Meal> getMockMealsForGoal(String goalKey) {
  switch (goalKey) {
    case 'loseWeight':
      return mockMealsLoseWeight;
    case 'gainMuscle':
      return mockMealsGainMuscle;
    default:
      return mockMealsStayFit;
  }
}

/// Примеры приёмов пищи для похудения
final mockMealsLoseWeight = [
  const Meal(
    type: MealType.breakfast,
    name: 'Овсянка с фруктами',
    description: 'Овсянка, банан, миндаль, корица. Низкокалорийно, надолго насыщает.',
    calories: 350,
    protein: 12,
    carbs: 55,
    fat: 8,
  ),
  const Meal(
    type: MealType.lunch,
    name: 'Салат с курицей гриль',
    description: 'Салат, огурец, помидор, курица гриль, оливковое масло.',
    calories: 400,
    protein: 35,
    carbs: 20,
    fat: 18,
  ),
  const Meal(
    type: MealType.dinner,
    name: 'Рыба на пару с овощами',
    description: 'Сибас, брокколи, морковь. Лёгкое и питательное.',
    calories: 380,
    protein: 40,
    carbs: 25,
    fat: 12,
  ),
  const Meal(
    type: MealType.snack,
    name: 'Йогурт и грецкие орехи',
    description: 'Натуральный йогурт, 5-6 орехов. Белок и полезные жиры.',
    calories: 200,
    protein: 15,
    carbs: 10,
    fat: 12,
  ),
];

/// Примеры приёмов пищи для набора массы
final mockMealsGainMuscle = [
  const Meal(
    type: MealType.breakfast,
    name: 'Белковый завтрак',
    description: 'Яйца (3 шт.), цельнозерновой хлеб, авокадо, сыр.',
    calories: 550,
    protein: 35,
    carbs: 45,
    fat: 25,
  ),
  const Meal(
    type: MealType.lunch,
    name: 'Курица с рисом',
    description: 'Куриная грудка гриль, рис, салат, хумус.',
    calories: 650,
    protein: 50,
    carbs: 70,
    fat: 15,
  ),
  const Meal(
    type: MealType.dinner,
    name: 'Лосось и батат',
    description: 'Лосось гриль, запечённый батат, шпинат.',
    calories: 600,
    protein: 45,
    carbs: 55,
    fat: 22,
  ),
  const Meal(
    type: MealType.snack,
    name: 'Протеиновый коктейль и банан',
    description: 'Сывороточный протеин, банан, молоко, арахисовая паста.',
    calories: 400,
    protein: 35,
    carbs: 45,
    fat: 10,
  ),
];

/// Примеры приёмов пищи для поддержания формы
final mockMealsStayFit = [
  const Meal(
    type: MealType.breakfast,
    name: 'Сбалансированный завтрак',
    description: 'Яйца, цельнозерновой хлеб, помидор, огурец, оливки.',
    calories: 450,
    protein: 25,
    carbs: 50,
    fat: 18,
  ),
  const Meal(
    type: MealType.lunch,
    name: 'Куриный wrap',
    description: 'Цельнозерновая лепёшка, курица, зелень, хумус.',
    calories: 500,
    protein: 35,
    carbs: 45,
    fat: 20,
  ),
  const Meal(
    type: MealType.dinner,
    name: 'Говядина с овощами',
    description: 'Говядина гриль, картофель, сезонные овощи.',
    calories: 550,
    protein: 45,
    carbs: 40,
    fat: 22,
  ),
  const Meal(
    type: MealType.snack,
    name: 'Фрукты и миндаль',
    description: 'Яблоко, груша, 10-15 миндальных орехов.',
    calories: 250,
    protein: 8,
    carbs: 35,
    fat: 12,
  ),
];

/// Чего избегать (по целям)
Map<String, List<String>> mockFoodsToAvoid = {
  'loseWeight': [
    'Сладкие напитки',
    'Фастфуд',
    'Обработанные снеки',
    'Белый хлеб',
    'Сладости и выпечка',
  ],
  'gainMuscle': [
    'Алкоголь',
    'Пустые калории',
    'Избыток сахара',
    'Обработанное мясо',
  ],
  'stayFit': [
    'Избыток сахара',
    'Обработанные продукты',
    'Трансжиры',
  ],
};

/// Рекомендуемые продукты (по целям)
Map<String, List<String>> mockRecommendedFoods = {
  'loseWeight': [
    'Листовые овощи',
    'Куриная грудка',
    'Яйца',
    'Овсянка',
    'Фрукты',
    'Орехи (в меру)',
  ],
  'gainMuscle': [
    'Курица, рыба, красное мясо',
    'Яйца',
    'Молочные продукты',
    'Рис, макароны',
    'Орехи',
    'Фрукты и овощи',
  ],
  'stayFit': [
    'Цельнозерновые',
    'Постный белок',
    'Фрукты и овощи',
    'Полезные жиры',
    'Бобовые',
  ],
};
