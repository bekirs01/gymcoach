class ArticleContent {
  const ArticleContent({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.readTime,
    required this.body,
  });

  final String title;
  final String subtitle;
  final String category;
  final String readTime;
  final String body;
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
