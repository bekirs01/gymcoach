import '../../domain/models/guide_article.dart';
import '../mock/mock_guide_articles.dart';
import 'guide_repository.dart';

/// Mock rehber repository
class GuideRepositoryImpl implements GuideRepository {
  @override
  Future<List<GuideArticle>> getAllArticles() async {
    return mockGuideArticles;
  }

  @override
  Future<GuideArticle?> getArticleById(String id) async {
    try {
      return mockGuideArticles.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
