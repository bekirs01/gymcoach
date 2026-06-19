import '../../social/data/social_seed_data.dart';
import '../domain/feed_story.dart';

abstract final class FeedDemoData {
  static List<FeedStory> demoStories() => SocialSeedRepository.demoStories();
}
