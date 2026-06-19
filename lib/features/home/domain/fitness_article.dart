class ArticleSection {
  const ArticleSection({
    required this.title,
    this.body = '',
    this.bullets = const [],
  });

  final String title;
  final String body;
  final List<String> bullets;
}

class ArticleContent {
  const ArticleContent({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.readTime,
    required this.intro,
    required this.sections,
    required this.takeaway,
    this.takeawayHeading = 'Key takeaway',
  });

  final String title;
  final String subtitle;
  final String category;
  final String readTime;
  final String intro;
  final List<ArticleSection> sections;
  final String takeaway;
  final String takeawayHeading;
}

class FitnessArticle {
  const FitnessArticle({
    required this.id,
    required this.imageUrl,
    required this.english,
    required this.russian,
  });

  final String id;
  final String imageUrl;
  final ArticleContent english;
  final ArticleContent russian;

  ArticleContent contentFor(String languageCode) {
    return languageCode == 'ru' ? russian : english;
  }
}
