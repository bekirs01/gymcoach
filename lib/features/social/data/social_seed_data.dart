import '../../feed/domain/feed_story.dart';
import '../../profile/domain/profile_defaults.dart';
import '../../profile/domain/profile_media_filter.dart';
import '../../profile/domain/user_profile.dart';
import '../domain/feed_comment.dart';
import '../domain/feed_media.dart';
import '../domain/feed_post.dart';
import '../domain/social_profile.dart';

class SeededSocialUser {
  const SeededSocialUser({
    required this.id,
    required this.displayName,
    required this.username,
    required this.avatarUrl,
    required this.coverUrl,
    required this.bio,
    required this.trainingFocus,
    required this.city,
    required this.photoUrls,
    required this.storySlideUrls,
    this.experience = '',
    this.goal = '',
    this.age = 0,
    this.joinedLabel = '',
    this.weeklyTarget = '',
    this.favoriteTrainingType = '',
  });

  final String id;
  final String displayName;
  final String username;
  final String avatarUrl;
  final String coverUrl;
  final String bio;
  final String trainingFocus;
  final String city;
  final List<String> photoUrls;
  final List<String> storySlideUrls;
  final String experience;
  final String goal;
  final int age;
  final String joinedLabel;
  final String weeklyTarget;
  final String favoriteTrainingType;

  int get postCount => SocialSeedRepository.postsForUser(id).length;
  int get storyCount => storySlideUrls.length;

  SocialProfile toSocialProfile() {
    return SocialProfile(
      userId: id,
      displayName: displayName,
      bio: bio,
      privateNotes: '',
      avatarUrl: avatarUrl,
      coverUrl: coverUrl,
      isPublic: true,
    );
  }
}

abstract final class SocialSeedRepository {
  static const currentUserId = 'seed_current';

  static const _currentUserGallery = [
    'https://images.unsplash.com/photo-1581009146145-b5ef050c2a1e?w=900&q=80',
    'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?w=900&q=80',
    'https://images.unsplash.com/photo-1583454158554-84aa2aa0b2d8?w=900&q=80',
    'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=900&q=80',
    'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=900&q=80',
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=900&q=80',
    'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=900&q=80',
  ];

  static const _gymImages = [
    'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=900&q=80',
    'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=900&q=80',
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=900&q=80',
    'https://images.unsplash.com/photo-1476480862128-209b5b09368a?w=900&q=80',
    'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=900&q=80',
    'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=900&q=80',
    'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=900&q=80',
    'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=900&q=80',
    'https://images.unsplash.com/photo-1434682881908-43dc4f88398c?w=900&q=80',
    'https://images.unsplash.com/photo-1517963879433-be23c640131e?w=900&q=80',
    'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?w=900&q=80',
    'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=900&q=80',
  ];

  static const _covers = [
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=1200&q=80',
    'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=1200&q=80',
    'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=1200&q=80',
    'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=1200&q=80',
    'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=1200&q=80',
    'https://images.unsplash.com/photo-1476480862128-209b5b09368a?w=1200&q=80',
    'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=1200&q=80',
    'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=1200&q=80',
  ];

  static final List<SeededSocialUser> socialUsers = [
    SeededSocialUser(
      id: 'seed_alexey',
      displayName: 'Алексей',
      username: 'alexey_fit',
      avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      coverUrl: _covers[0],
      bio: 'Strength training, early sessions, clean routine.',
      trainingFocus: 'Strength & push/pull',
      city: 'Moscow',
      photoUrls: [_gymImages[0], _gymImages[1], _gymImages[8]],
      storySlideUrls: [_gymImages[0], _gymImages[1]],
    ),
    SeededSocialUser(
      id: 'seed_dmitry',
      displayName: 'Дмитрий',
      username: 'dmitry_lifts',
      avatarUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
      coverUrl: _covers[1],
      bio: 'Gym, recovery, discipline.',
      trainingFocus: 'Back & posterior chain',
      city: 'Saint Petersburg',
      photoUrls: [_gymImages[2], _gymImages[3], _gymImages[9]],
      storySlideUrls: [_gymImages[2]],
    ),
    SeededSocialUser(
      id: 'seed_anastasia',
      displayName: 'Анастасия',
      username: 'anastasia_moves',
      avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      coverUrl: _covers[2],
      bio: 'Building consistency one session at a time.',
      trainingFocus: 'Pilates & strength',
      city: 'Kazan',
      photoUrls: [_gymImages[4], _gymImages[5], _gymImages[10]],
      storySlideUrls: [_gymImages[4], _gymImages[5]],
    ),
    SeededSocialUser(
      id: 'seed_ekaterina',
      displayName: 'Екатерина',
      username: 'ekaterina_run',
      avatarUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
      coverUrl: _covers[3],
      bio: 'Lifting, mobility, and better habits.',
      trainingFocus: 'Cardio & conditioning',
      city: 'Moscow',
      photoUrls: [_gymImages[6], _gymImages[7], _gymImages[11]],
      storySlideUrls: [_gymImages[6]],
    ),
    SeededSocialUser(
      id: 'seed_maxim',
      displayName: 'Максим',
      username: 'maxim_power',
      avatarUrl: 'https://randomuser.me/api/portraits/men/46.jpg',
      coverUrl: _covers[4],
      bio: 'Heavy sets, calm mind, steady progress.',
      trainingFocus: 'Powerlifting',
      city: 'Novosibirsk',
      photoUrls: [_gymImages[1], _gymImages[2], _gymImages[3]],
      storySlideUrls: [_gymImages[1], _gymImages[3]],
    ),
    SeededSocialUser(
      id: 'seed_sofia',
      displayName: 'София',
      username: 'sofia_balance',
      avatarUrl: 'https://randomuser.me/api/portraits/women/28.jpg',
      coverUrl: _covers[5],
      bio: 'Recovery days matter as much as training days.',
      trainingFocus: 'Mobility & core',
      city: 'Sochi',
      photoUrls: [_gymImages[5], _gymImages[7], _gymImages[8]],
      storySlideUrls: [_gymImages[5], _gymImages[11]],
    ),
    SeededSocialUser(
      id: 'seed_maria',
      displayName: 'Мария',
      username: 'maria_steady',
      avatarUrl: 'https://randomuser.me/api/portraits/women/12.jpg',
      coverUrl: _covers[6],
      bio: 'Small wins, every week.',
      trainingFocus: 'Full-body & legs',
      city: 'Moscow',
      photoUrls: [_gymImages[7], _gymImages[0], _gymImages[4]],
      storySlideUrls: [_gymImages[7], _gymImages[0]],
    ),
    SeededSocialUser(
      id: 'seed_ivan',
      displayName: 'Иван',
      username: 'ivan_train',
      avatarUrl: 'https://randomuser.me/api/portraits/men/52.jpg',
      coverUrl: _covers[7],
      bio: 'Early sessions, steady gains.',
      trainingFocus: 'Functional strength',
      city: 'Yekaterinburg',
      photoUrls: [_gymImages[10], _gymImages[11], _gymImages[2]],
      storySlideUrls: [_gymImages[10]],
    ),
  ];

  static const _storyRowOrder = [
    'seed_sofia',
    'seed_maria',
    'seed_anastasia',
    'seed_ekaterina',
    'seed_alexey',
    'seed_dmitry',
    'seed_maxim',
    'seed_ivan',
  ];

  static bool isSeededUser(String userId) {
    return userId == currentUserId || socialUsers.any((u) => u.id == userId);
  }

  static SeededSocialUser? userById(String userId) {
    if (userId == currentUserId) return null;
    for (final user in socialUsers) {
      if (user.id == userId) return user;
    }
    return null;
  }

  static SeededSocialUser currentUserSeed(UserProfile profile) {
    final displayName = ProfileDefaults.normalizeDisplayName(profile.displayName);
    final bio = profile.publicBio.trim().isNotEmpty
        ? profile.publicBio.trim()
        : ProfileDefaults.publicBio;
    final avatar = profile.avatarUrl.trim();
    final cover = profile.coverUrl.trim();
    final trainingFocus = profile.trainingFocus.trim().isNotEmpty
        ? profile.trainingFocus.trim()
        : ProfileDefaults.trainingFocus;
    final city = profile.locationText.trim().isNotEmpty
        ? profile.locationText.trim()
        : ProfileDefaults.locationText;
    final experience = profile.experienceLevel.trim().isNotEmpty
        ? _titleCase(profile.experienceLevel.trim())
        : _titleCase(ProfileDefaults.experienceLevel);
    return SeededSocialUser(
      id: currentUserId,
      displayName: displayName,
      username: profile.username.trim().isNotEmpty ? profile.username.trim() : ProfileDefaults.username,
      avatarUrl: avatar,
      coverUrl: cover,
      bio: bio,
      trainingFocus: trainingFocus,
      city: city,
      photoUrls: _currentUserGallery,
      storySlideUrls: [
        _currentUserGallery[0],
        _currentUserGallery[1],
        _currentUserGallery[4],
      ],
      experience: experience,
      goal: profile.fitnessGoal.trim().isNotEmpty ? profile.fitnessGoal.trim() : ProfileDefaults.fitnessGoal,
      age: 24,
      joinedLabel: 'June 2026',
      weeklyTarget: ProfileDefaults.weeklyTargetLabel(profile.weeklyWorkoutTarget),
      favoriteTrainingType: 'Strength + mobility',
    );
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  static SocialProfile socialProfileFor(String userId, {UserProfile? currentProfile}) {
    if (userId == currentUserId && currentProfile != null) {
      final seed = currentUserSeed(currentProfile);
      return seed.toSocialProfile();
    }
    final user = userById(userId);
    if (user != null) return user.toSocialProfile();
    return const SocialProfile(
      userId: '',
      displayName: '',
      bio: '',
      privateNotes: '',
      avatarUrl: '',
      coverUrl: '',
      isPublic: true,
    );
  }

  static SeededSocialUser? seededUserFor(String userId, {UserProfile? currentProfile}) {
    if (userId == currentUserId && currentProfile != null) {
      return currentUserSeed(currentProfile);
    }
    return userById(userId);
  }

  static List<FeedStory> demoStories() {
    return _storyRowOrder.map((userId) {
      final user = socialUsers.firstWhere((entry) => entry.id == userId);
      return FeedStory(
        id: 'story_${user.id}',
        user: StoryUser(
          id: user.id,
          displayName: user.displayName,
          avatarUrl: user.avatarUrl,
        ),
        slides: user.storySlideUrls.map((url) => FeedStorySlide(imageUrl: url)).toList(),
      );
    }).toList();
  }

  static StoryUser ownStoryUser(UserProfile profile, {String? userId, String? avatarUrlOverride}) {
    final seed = currentUserSeed(profile);
    final displayName = profile.displayName.trim().isEmpty ? seed.displayName : profile.displayName.trim();
    final override = avatarUrlOverride?.trim() ?? '';
    final avatar = ProfileMediaFilter.resolveImageUrl(
      primary: override.isNotEmpty ? override : profile.avatarUrl,
      fallback: seed.avatarUrl,
    );
    return StoryUser(
      id: userId ?? currentUserId,
      displayName: 'Your story',
      avatarUrl: avatar,
      fallbackName: displayName,
      isCurrentUser: true,
    );
  }

  static List<FeedPost> allFeedPosts({UserProfile? currentProfile}) {
    return _seedPostDefinitions(currentProfile: currentProfile)
        .map((p) => _toFeedPost(p, currentProfile: currentProfile))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<FeedPost> mergeWithApiPosts(
    List<FeedPost> apiPosts, {
    UserProfile? currentProfile,
  }) {
    final byId = <String, FeedPost>{};
    for (final post in allFeedPosts(currentProfile: currentProfile)) {
      byId[post.id] = post;
    }
    for (final post in apiPosts) {
      if (post.id.isEmpty || byId.containsKey(post.id)) continue;
      byId[post.id] = post;
    }
    return byId.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<FeedPost> postsForUser(String userId, {UserProfile? currentProfile}) {
    return allFeedPosts(currentProfile: currentProfile).where((p) => p.userId == userId).toList();
  }

  static List<FeedMedia> photosForUser(String userId, {UserProfile? currentProfile}) {
    final user = seededUserFor(userId, currentProfile: currentProfile);
    if (user == null) return const [];
    final postMedia = postsForUser(userId, currentProfile: currentProfile).expand((p) => p.media);
    final gallery = user.photoUrls.asMap().entries.map(
          (e) => FeedMedia(
            id: '${userId}_photo_${e.key}',
            postId: '',
            url: e.value,
            path: '',
            sortOrder: e.key,
          ),
        );
    return ProfileMediaFilter.profileGallery(
      apiMedia: postMedia.toList(),
      seedMedia: gallery.toList(),
      minPhotos: userId == currentUserId ? 3 : 1,
    );
  }

  static FeedPost _toFeedPost(_SeedPostDef def, {UserProfile? currentProfile}) {
    final comments = _seedCommentsForPost(def, currentProfile: currentProfile);
    return FeedPost(
      id: def.id,
      userId: def.userId,
      caption: def.caption,
      createdAt: def.createdAt,
      author: socialProfileFor(def.userId, currentProfile: currentProfile),
      media: [
        FeedMedia(
          id: '${def.id}_media_0',
          postId: def.id,
          url: def.imageUrl,
          path: '',
          sortOrder: 0,
        ),
      ],
      comments: comments,
      likeCount: def.likeCount,
      commentCount: comments.length,
      likedByMe: false,
    );
  }

  static List<FeedComment> _seedCommentsForPost(
    _SeedPostDef def, {
    UserProfile? currentProfile,
  }) {
    final templates = _commentTemplates[def.id] ?? const [];
    return templates.asMap().entries.map((entry) {
      final index = entry.key;
      final template = entry.value;
      return FeedComment(
        id: '${def.id}_comment_$index',
        postId: def.id,
        userId: template.userId,
        body: template.body,
        createdAt: def.createdAt.subtract(Duration(minutes: (index + 1) * 3)),
        author: socialProfileFor(template.userId, currentProfile: currentProfile),
      );
    }).toList();
  }

  static const _commentTemplates = <String, List<_CommentTemplate>>{
    'seed_post_sofia_1': [
      _CommentTemplate(userId: 'seed_maria', body: 'Love this energy!'),
      _CommentTemplate(userId: 'seed_anastasia', body: 'Morning sessions hit different'),
      _CommentTemplate(userId: 'seed_ekaterina', body: 'Сильная работа!'),
      _CommentTemplate(userId: 'seed_alexey', body: 'Consistency is showing'),
      _CommentTemplate(userId: 'seed_dmitry', body: 'Keep it up'),
    ],
    'seed_post_maria_1': [
      _CommentTemplate(userId: 'seed_sofia', body: 'Small wins add up'),
      _CommentTemplate(userId: 'seed_ivan', body: 'Nice progress'),
      _CommentTemplate(userId: 'seed_maxim', body: 'Solid routine'),
      _CommentTemplate(userId: 'seed_anastasia', body: 'Молодец!'),
    ],
    'seed_post_anastasia_1': [
      _CommentTemplate(userId: 'seed_ekaterina', body: 'Stretching is underrated'),
      _CommentTemplate(userId: 'seed_sofia', body: 'Recovery looks good'),
      _CommentTemplate(userId: 'seed_maria', body: 'Great form'),
    ],
    'seed_post_ekaterina_1': [
      _CommentTemplate(userId: 'seed_maxim', body: 'Leg day never gets easier'),
      _CommentTemplate(userId: 'seed_dmitry', body: 'Strong finish'),
      _CommentTemplate(userId: 'seed_alexey', body: 'Отличная тренировка'),
      _CommentTemplate(userId: 'seed_ivan', body: 'Respect the grind'),
      _CommentTemplate(userId: 'seed_sofia', body: 'You crushed it'),
      _CommentTemplate(userId: 'seed_maria', body: 'Inspiring session'),
    ],
    'seed_post_alexey_1': [
      _CommentTemplate(userId: 'seed_dmitry', body: 'Back day gains'),
      _CommentTemplate(userId: 'seed_maxim', body: 'Looking strong'),
      _CommentTemplate(userId: 'seed_ivan', body: 'Clean reps'),
      _CommentTemplate(userId: 'seed_anastasia', body: 'Great work today'),
    ],
    'seed_post_dmitry_1': [
      _CommentTemplate(userId: 'seed_alexey', body: 'Facts'),
      _CommentTemplate(userId: 'seed_maxim', body: 'Motivation follows action'),
      _CommentTemplate(userId: 'seed_sofia', body: 'Needed this reminder'),
      _CommentTemplate(userId: 'seed_maria', body: 'Discipline wins'),
      _CommentTemplate(userId: 'seed_ekaterina', body: 'Согласна полностью'),
      _CommentTemplate(userId: 'seed_ivan', body: 'Steady progress'),
      _CommentTemplate(userId: 'seed_anastasia', body: 'Well said'),
    ],
    'seed_post_maxim_1': [
      _CommentTemplate(userId: 'seed_ivan', body: 'Evening cardio hits different'),
      _CommentTemplate(userId: 'seed_sofia', body: 'Nice pace'),
      _CommentTemplate(userId: 'seed_maria', body: 'Keep going'),
    ],
    'seed_post_ivan_1': [
      _CommentTemplate(userId: 'seed_maxim', body: 'Clean session'),
      _CommentTemplate(userId: 'seed_dmitry', body: 'One more rep mentality'),
      _CommentTemplate(userId: 'seed_alexey', body: 'Solid work'),
      _CommentTemplate(userId: 'seed_ekaterina', body: 'Хорошая работа'),
      _CommentTemplate(userId: 'seed_anastasia', body: 'Consistency pays off'),
    ],
  };

  static final DateTime _seedAnchor = DateTime.utc(2026, 6, 1, 12, 0);

  static List<_SeedPostDef> _seedPostDefinitions({UserProfile? currentProfile}) {
    final now = _seedAnchor;
    SeededSocialUser user(String id) => socialUsers.firstWhere((u) => u.id == id);
    final currentSeed = currentProfile != null ? currentUserSeed(currentProfile) : null;

    return [
      if (currentSeed != null)
        _SeedPostDef(
          id: 'seed_post_current_1',
          userId: currentUserId,
          userName: currentSeed.displayName,
          avatarUrl: currentSeed.avatarUrl,
          imageUrl: _currentUserGallery[1],
          caption: 'Battle ropes before the commute — short and sharp.',
          timeLabel: '18m ago',
          createdAt: now.subtract(const Duration(minutes: 18)),
          likeCount: 19,
          commentCount: 2,
        ),
      if (currentSeed != null)
        _SeedPostDef(
          id: 'seed_post_current_2',
          userId: currentUserId,
          userName: currentSeed.displayName,
          avatarUrl: currentSeed.avatarUrl,
          imageUrl: _currentUserGallery[3],
          caption: 'Mirror check after upper body. Small wins stack up.',
          timeLabel: '1d ago',
          createdAt: now.subtract(const Duration(days: 1)),
          likeCount: 27,
          commentCount: 3,
        ),
      if (currentSeed != null)
        _SeedPostDef(
          id: 'seed_post_current_3',
          userId: currentUserId,
          userName: currentSeed.displayName,
          avatarUrl: currentSeed.avatarUrl,
          imageUrl: _currentUserGallery[4],
          caption: 'Recovery stretch night. Mobility keeps the streak alive.',
          timeLabel: '2d ago',
          createdAt: now.subtract(const Duration(days: 2)),
          likeCount: 15,
          commentCount: 1,
        ),
      _SeedPostDef(
        id: 'seed_post_sofia_1',
        userId: user('seed_sofia').id,
        userName: user('seed_sofia').displayName,
        avatarUrl: user('seed_sofia').avatarUrl,
        imageUrl: _gymImages[5],
        caption: 'morning training done',
        timeLabel: '4m ago',
        createdAt: now.subtract(const Duration(minutes: 4)),
        likeCount: 32,
        commentCount: 5,
      ),
      _SeedPostDef(
        id: 'seed_post_maria_1',
        userId: user('seed_maria').id,
        userName: user('seed_maria').displayName,
        avatarUrl: user('seed_maria').avatarUrl,
        imageUrl: _gymImages[7],
        caption: 'small progress every day',
        timeLabel: '11m ago',
        createdAt: now.subtract(const Duration(minutes: 11)),
        likeCount: 28,
        commentCount: 4,
      ),
      _SeedPostDef(
        id: 'seed_post_anastasia_1',
        userId: user('seed_anastasia').id,
        userName: user('seed_anastasia').displayName,
        avatarUrl: user('seed_anastasia').avatarUrl,
        imageUrl: _gymImages[4],
        caption: 'post-workout stretch',
        timeLabel: '26m ago',
        createdAt: now.subtract(const Duration(minutes: 26)),
        likeCount: 21,
        commentCount: 3,
      ),
      _SeedPostDef(
        id: 'seed_post_ekaterina_1',
        userId: user('seed_ekaterina').id,
        userName: user('seed_ekaterina').displayName,
        avatarUrl: user('seed_ekaterina').avatarUrl,
        imageUrl: _gymImages[6],
        caption: 'leg day complete',
        timeLabel: '38m ago',
        createdAt: now.subtract(const Duration(minutes: 38)),
        likeCount: 24,
        commentCount: 6,
      ),
      _SeedPostDef(
        id: 'seed_post_alexey_1',
        userId: user('seed_alexey').id,
        userName: user('seed_alexey').displayName,
        avatarUrl: user('seed_alexey').avatarUrl,
        imageUrl: _gymImages[1],
        caption: 'back day felt great',
        timeLabel: '52m ago',
        createdAt: now.subtract(const Duration(minutes: 52)),
        likeCount: 31,
        commentCount: 4,
      ),
      _SeedPostDef(
        id: 'seed_post_dmitry_1',
        userId: user('seed_dmitry').id,
        userName: user('seed_dmitry').displayName,
        avatarUrl: user('seed_dmitry').avatarUrl,
        imageUrl: _gymImages[2],
        caption: 'consistency beats motivation',
        timeLabel: '1h ago',
        createdAt: now.subtract(const Duration(hours: 1)),
        likeCount: 42,
        commentCount: 7,
      ),
      _SeedPostDef(
        id: 'seed_post_maxim_1',
        userId: user('seed_maxim').id,
        userName: user('seed_maxim').displayName,
        avatarUrl: user('seed_maxim').avatarUrl,
        imageUrl: _gymImages[3],
        caption: 'evening cardio',
        timeLabel: '2h ago',
        createdAt: now.subtract(const Duration(hours: 2)),
        likeCount: 18,
        commentCount: 3,
      ),
      _SeedPostDef(
        id: 'seed_post_ivan_1',
        userId: user('seed_ivan').id,
        userName: user('seed_ivan').displayName,
        avatarUrl: user('seed_ivan').avatarUrl,
        imageUrl: _gymImages[10],
        caption: 'one more clean session',
        timeLabel: '3h ago',
        createdAt: now.subtract(const Duration(hours: 3)),
        likeCount: 24,
        commentCount: 5,
      ),
    ];
  }
}

class _CommentTemplate {
  const _CommentTemplate({
    required this.userId,
    required this.body,
  });

  final String userId;
  final String body;
}

class _SeedPostDef {
  const _SeedPostDef({
    required this.id,
    required this.userId,
    required this.userName,
    required this.avatarUrl,
    required this.imageUrl,
    required this.caption,
    required this.timeLabel,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
  });

  final String id;
  final String userId;
  final String userName;
  final String avatarUrl;
  final String imageUrl;
  final String caption;
  final String timeLabel;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
}
