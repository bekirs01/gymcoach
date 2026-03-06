import '../../domain/models/guide_article.dart';

/// Rehber/makale repository arayüzü
abstract class GuideRepository {
  Future<List<GuideArticle>> getAllArticles();
  Future<GuideArticle?> getArticleById(String id);
}
